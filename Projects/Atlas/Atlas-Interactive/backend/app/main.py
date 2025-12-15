import logging
from logging.handlers import RotatingFileHandler

from dotenv import load_dotenv
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware

from app.routers import chat, chat_history, trading
from app.services.trading.manager import trading_bot_manager


def create_app() -> FastAPI:
    load_dotenv()

    # Configure logging
    log_dir = "logs"
    log_file = f"{log_dir}/backend.log"
    # Create log directory if it does not exist
    import os
    os.makedirs(log_dir, exist_ok=True)
    
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] [%(name)s] %(message)s",
        handlers=[
            RotatingFileHandler(log_file, maxBytes=1000000, backupCount=1),
            logging.StreamHandler(),
        ],
    )

    app = FastAPI(title="Atlas Interactive Backend", version="0.1.0")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(chat.router)
    app.include_router(chat_history.router)
    app.include_router(trading.router)

    @app.get("/health")
    async def health() -> dict[str, str]:
        return {"status": "ok"}

    @app.on_event("shutdown")
    async def _shutdown_trading_bot() -> None:
        await trading_bot_manager.stop()

    return app


app = create_app()


@app.websocket("/ws/health")
async def websocket_health(websocket: WebSocket) -> None:
    await websocket.accept()
    await websocket.send_json({"status": "ok"})
    await websocket.close()
