import asyncio
import json
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect

from app.security import require_trading_auth, require_trading_auth_ws
from app.services.trading.manager import trading_bot_manager
from app.services.trading.models import (
    IndicatorSettings,
    TradingStartRequest,
    TradingStatusResponse,
    TradingStopRequest,
)

router = APIRouter(
    prefix="/trading",
    tags=["trading"],
    dependencies=[Depends(require_trading_auth)],
)

INDICATOR_SETTINGS_FILE = Path("indicator_settings.json")


@router.get("/status", response_model=TradingStatusResponse)
async def trading_status() -> TradingStatusResponse:
    return trading_bot_manager.status()


@router.post("/start", response_model=TradingStatusResponse)
async def trading_start(payload: TradingStartRequest) -> TradingStatusResponse:
    try:
        await trading_bot_manager.start(payload)
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    return trading_bot_manager.status()


@router.post("/stop", response_model=TradingStatusResponse)
async def trading_stop(payload: TradingStopRequest) -> TradingStatusResponse:
    try:
        await trading_bot_manager.stop()
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    return trading_bot_manager.status()


@router.get("/indicator-settings", response_model=IndicatorSettings)
async def get_indicator_settings() -> IndicatorSettings:
    if not INDICATOR_SETTINGS_FILE.exists():
        return IndicatorSettings()
    with open(INDICATOR_SETTINGS_FILE, "r") as f:
        return IndicatorSettings.model_validate(json.load(f))


@router.post("/indicator-settings", response_model=IndicatorSettings)
async def set_indicator_settings(settings: IndicatorSettings) -> IndicatorSettings:
    with open(INDICATOR_SETTINGS_FILE, "w") as f:
        json.dump(settings.model_dump(mode="json"), f, indent=2)
    return settings


@router.websocket("/ws")
async def trading_stream(websocket: WebSocket) -> None:
    if not await require_trading_auth_ws(websocket):
        return
    await websocket.accept()
    queue = trading_bot_manager.subscribe()
    try:
        while True:
            try:
                event = await asyncio.wait_for(queue.get(), timeout=10)
                await websocket.send_json(event)
            except asyncio.TimeoutError:
                await websocket.send_json(
                    {
                        "type": "heartbeat",
                        "status": trading_bot_manager.status().model_dump(mode="json"),
                    }
                )
    except WebSocketDisconnect:
        return
    finally:
        trading_bot_manager.unsubscribe(queue)
