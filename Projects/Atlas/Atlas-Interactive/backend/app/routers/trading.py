import asyncio
from datetime import datetime, timezone
from random import random

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

router = APIRouter(prefix="/trading", tags=["trading"])


@router.websocket("/ws")
async def trading_stream(websocket: WebSocket) -> None:
    await websocket.accept()
    try:
        while True:
            await asyncio.sleep(1)
            await websocket.send_json(
                {
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "bot": "alpha",
                    "status": "running",
                    "pnl": round(random() * 10 - 5, 2),
                }
            )
    except WebSocketDisconnect:
        return
