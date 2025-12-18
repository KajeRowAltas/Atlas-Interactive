from __future__ import annotations

import asyncio
import logging
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from typing import Any, Callable, Optional

from app.services.trading.models import IndicatorSettings

logger = logging.getLogger("app")


@dataclass(frozen=True)
class BotConfig:
    bot_id: str
    symbol: str
    market_type: str
    dry_run: bool
    enable_analysis: bool
    poll_interval_s: float
    leverage: Optional[int]
    indicator_settings: IndicatorSettings


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class TradingBot:
    def __init__(
        self,
        *,
        exchange: Any,
        config: BotConfig,
        stop_event: asyncio.Event,
        publish: Callable[[dict[str, Any]], None],
    ) -> None:
        self._exchange = exchange
        self._config = config
        self._stop_event = stop_event
        self._publish = publish
        self._analysis_last_fetch_monotonic: dict[str, float] = {}
        self._analysis_last_payload: dict[str, dict[str, Any]] = {}
        from app.services.trading.strategy import NoopStrategy

        self._strategy = NoopStrategy()

    async def run(self) -> None:
        logger.info(f"Bot {self._config.bot_id} starting")
        self._publish(
            {
                "type": "status",
                "bot_id": self._config.bot_id,
                "state": "starting",
                "timestamp": utc_now().isoformat(),
                "dry_run": self._config.dry_run,
                "symbol": self._config.symbol,
                "market_type": self._config.market_type,
                "leverage": self._config.leverage,
            }
        )

        try:
            await self._exchange.load_markets()

            if self._config.leverage is not None and not self._config.dry_run:
                try:
                    await self._exchange.set_leverage(
                        self._config.leverage, self._config.symbol
                    )
                except Exception as exc:  # noqa: BLE001
                    logger.exception("Failed to set leverage")
                    self._publish(
                        {
                            "type": "log",
                            "level": "warning",
                            "bot_id": self._config.bot_id,
                            "timestamp": utc_now().isoformat(),
                            "message": f"Failed to set leverage: {exc}",
                        }
                    )

            logger.info(f"Bot {self._config.bot_id} running")
            self._publish(
                {
                    "type": "status",
                    "bot_id": self._config.bot_id,
                    "state": "running",
                    "timestamp": utc_now().isoformat(),
                }
            )

            while not self._stop_event.is_set():
                try:
                    ticker = await self._exchange.fetch_ticker(self._config.symbol)
                    last_price = None
                    if isinstance(ticker, dict):
                        last_price = ticker.get("last") or ticker.get("close")
                    self._publish(
                        {
                            "type": "tick",
                            "bot_id": self._config.bot_id,
                            "timestamp": utc_now().isoformat(),
                            "symbol": self._config.symbol,
                            "last_price": last_price,
                            "dry_run": self._config.dry_run,
                        }
                    )

                    if self._config.enable_analysis:
                        await self._publish_analysis()
                except Exception as exc:  # noqa: BLE001
                    logger.exception("Error in bot run loop")
                    self._publish(
                        {
                            "type": "error",
                            "bot_id": self._config.bot_id,
                            "timestamp": utc_now().isoformat(),
                            "message": str(exc),
                        }
                    )
                    await asyncio.sleep(min(self._config.poll_interval_s, 5.0))
                    continue

                await asyncio.sleep(self._config.poll_interval_s)
        finally:
            logger.info(f"Bot {self._config.bot_id} stopping")
            try:
                await self._exchange.close()
            except Exception:  # noqa: BLE001
                logger.exception("Error closing exchange")

            self._publish(
                {
                    "type": "status",
                    "bot_id": self._config.bot_id,
                    "state": "stopped",
                    "timestamp": utc_now().isoformat(),
                }
            )
            logger.info(f"Bot {self._config.bot_id} stopped")

    async def _publish_analysis(self) -> None:
        from app.services.trading.indicators import bollinger_bands, rsi
        from app.services.trading.market_structure import market_structure

        timeframes: list[tuple[str, int, float]] = [
            ("15m", 200, 60.0),
            ("3m", 200, 20.0),
            ("1m", 200, 10.0),
        ]
        analysis: dict[str, dict[str, Any]] = {}

        now_mono = asyncio.get_running_loop().time()
        for tf, limit, refresh_s in timeframes:
            last_fetch = self._analysis_last_fetch_monotonic.get(tf)
            if last_fetch is not None and (now_mono - last_fetch) < refresh_s:
                cached = self._analysis_last_payload.get(tf)
                if cached is not None:
                    analysis[tf] = cached
                continue

            try:
                ohlcv = await self._exchange.fetch_ohlcv(
                    self._config.symbol, timeframe=tf, limit=limit
                )
            except Exception as exc:  # noqa: BLE001
                logger.exception(f"fetch_ohlcv failed ({tf})")
                self._publish(
                    {
                        "type": "log",
                        "level": "warning",
                        "bot_id": self._config.bot_id,
                        "timestamp": utc_now().isoformat(),
                        "message": f"fetch_ohlcv failed ({tf}): {exc}",
                    }
                )
                continue

            if not ohlcv:
                continue

            closes = [float(c[4]) for c in ohlcv if c and len(c) >= 5]
            highs = [float(c[2]) for c in ohlcv if c and len(c) >= 3]
            lows = [float(c[3]) for c in ohlcv if c and len(c) >= 4]
            if not closes or not highs or not lows:
                continue

            bb = bollinger_bands(
                closes,
                period=self._config.indicator_settings.bbands.period,
                stdevs=self._config.indicator_settings.bbands.std_dev,
            )
            rs = rsi(closes, period=self._config.indicator_settings.rsi.period)
            ms = market_structure(
                highs,
                lows,
                closes,
                pivot_lookback=self._config.indicator_settings.market_structure.swing_points,
            )

            payload = {
                "close": closes[-1],
                "rsi": rs,
                "bbands": asdict(bb) if bb is not None else None,
                "market_structure": asdict(ms) if ms is not None else None,
            }
            self._analysis_last_fetch_monotonic[tf] = now_mono
            self._analysis_last_payload[tf] = payload
            analysis[tf] = payload

        if analysis:
            signal = None
            try:
                signal = self._strategy.evaluate(analysis)
            except Exception as exc:  # noqa: BLE001
                logger.exception("strategy evaluate failed")
                self._publish(
                    {
                        "type": "log",
                        "level": "warning",
                        "bot_id": self._config.bot_id,
                        "timestamp": utc_now().isoformat(),
                        "message": f"strategy evaluate failed: {exc}",
                    }
                )

            self._publish(
                {
                    "type": "analysis",
                    "bot_id": self._config.bot_id,
                    "timestamp": utc_now().isoformat(),
                    "symbol": self._config.symbol,
                    "timeframes": analysis,
                }
            )

            if signal is not None:
                self._publish(
                    {
                        "type": "signal",
                        "bot_id": self._config.bot_id,
                        "timestamp": utc_now().isoformat(),
                        "symbol": self._config.symbol,
                        "signal": {
                            "side": signal.side,
                            "reason": signal.reason,
                            "meta": signal.meta,
                        },
                    }
                )
