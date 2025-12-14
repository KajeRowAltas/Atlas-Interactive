from __future__ import annotations

import asyncio
import os
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Optional

from app.services.trading.bot import BotConfig, TradingBot
from app.services.trading.ccxt_bitget import (
    create_ccxt_bitget_exchange,
    load_bitget_credentials_from_env,
)
from app.services.trading.models import (
    IndicatorSettings,
    TradingStartRequest,
    TradingStatusResponse,
)


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


@dataclass
class _RuntimeState:
    state: str = "stopped"
    dry_run: bool = True
    enable_analysis: bool = True
    symbol: Optional[str] = None
    market_type: Optional[str] = None
    leverage: Optional[int] = None
    started_at: Optional[datetime] = None
    last_heartbeat_at: Optional[datetime] = None
    last_tick_at: Optional[datetime] = None
    last_price: Optional[float] = None
    last_error: Optional[str] = None


class TradingBotManager:
    def __init__(self) -> None:
        self._lock = asyncio.Lock()
        self._task: Optional[asyncio.Task] = None
        self._stop_event: Optional[asyncio.Event] = None
        self._subscribers: set[asyncio.Queue] = set()
        self._runtime = _RuntimeState()
        self._bot_id: str = "alpha"

    def status(self) -> TradingStatusResponse:
        return TradingStatusResponse(
            bot_id=self._bot_id,
            state=self._runtime.state,  # type: ignore[arg-type]
            dry_run=self._runtime.dry_run,
            enable_analysis=self._runtime.enable_analysis,
            symbol=self._runtime.symbol,
            market_type=self._runtime.market_type,  # type: ignore[arg-type]
            leverage=self._runtime.leverage,
            started_at=self._runtime.started_at,
            last_heartbeat_at=self._runtime.last_heartbeat_at,
            last_tick_at=self._runtime.last_tick_at,
            last_price=self._runtime.last_price,
            last_error=self._runtime.last_error,
        )

    def subscribe(self) -> asyncio.Queue:
        queue: asyncio.Queue = asyncio.Queue(maxsize=250)
        self._subscribers.add(queue)
        return queue

    def unsubscribe(self, queue: asyncio.Queue) -> None:
        self._subscribers.discard(queue)

    def _publish(self, event: dict[str, Any]) -> None:
        self._runtime.last_heartbeat_at = utc_now()
        event_type = event.get("type")
        if event_type == "tick":
            self._runtime.last_tick_at = utc_now()
            last_price = event.get("last_price")
            if isinstance(last_price, (int, float)):
                self._runtime.last_price = float(last_price)
        if event_type == "error":
            message = event.get("message")
            if isinstance(message, str):
                self._runtime.last_error = message
                if self._runtime.state in {"starting"}:
                    self._runtime.state = "error"
        if event_type == "status":
            state = event.get("state")
            if isinstance(state, str):
                self._runtime.state = state

        dead: list[asyncio.Queue] = []
        for subscriber in self._subscribers:
            try:
                subscriber.put_nowait(event)
            except asyncio.QueueFull:
                dead.append(subscriber)
        for subscriber in dead:
            self._subscribers.discard(subscriber)

    def _ensure_live_trading_allowed(self) -> None:
        if os.getenv("ATLAS_TRADING_LIVE", "").lower() not in {"1", "true", "yes"}:
            raise RuntimeError(
                "Live trading blocked: set ATLAS_TRADING_LIVE=true to allow live orders."
            )

    async def start(self, request: TradingStartRequest) -> None:
        async with self._lock:
            if self._task is not None and not self._task.done():
                raise RuntimeError("Bot already running.")

            self._bot_id = request.bot_id

            if request.dry_run is False:
                self._ensure_live_trading_allowed()

            creds = load_bitget_credentials_from_env()
            if request.dry_run is False and not (
                creds.api_key and creds.secret_key and creds.passphrase
            ):
                raise RuntimeError(
                    "Missing Bitget credentials in env: BITGET_API_KEY, BITGET_SECRET_KEY, BITGET_PASSPHRASE."
                )

            exchange = create_ccxt_bitget_exchange(
                creds=creds,
                market_type=request.market_type,
            )

            self._stop_event = asyncio.Event()
            self._runtime = _RuntimeState(
                state="starting",
                dry_run=request.dry_run,
                enable_analysis=request.enable_analysis,
                symbol=request.symbol,
                market_type=request.market_type,
                leverage=request.leverage,
                started_at=utc_now(),
                last_heartbeat_at=utc_now(),
            )

            config = BotConfig(
                bot_id=request.bot_id,
                symbol=request.symbol,
                market_type=request.market_type,
                dry_run=request.dry_run,
                enable_analysis=request.enable_analysis,
                poll_interval_s=request.poll_interval_s,
                leverage=request.leverage,
                indicator_settings=request.indicator_settings
                if request.indicator_settings is not None
                else IndicatorSettings(),
            )
            bot = TradingBot(
                exchange=exchange,
                config=config,
                stop_event=self._stop_event,
                publish=self._publish,
            )

            self._task = asyncio.create_task(bot.run())
            self._publish(
                {
                    "type": "status",
                    "bot_id": request.bot_id,
                    "state": "starting",
                    "timestamp": utc_now().isoformat(),
                }
            )

    async def stop(self) -> None:
        async with self._lock:
            if self._task is None or self._task.done():
                self._runtime.state = "stopped"
                return

            self._runtime.state = "stopping"
            if self._stop_event is not None:
                self._stop_event.set()

            task = self._task

        try:
            await asyncio.wait_for(task, timeout=15)
        except asyncio.TimeoutError:
            self._runtime.last_error = "Timed out while stopping bot."
            self._runtime.state = "error"


trading_bot_manager = TradingBotManager()
