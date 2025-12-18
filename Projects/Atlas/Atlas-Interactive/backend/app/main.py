from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware

from app.routers import chat, trading


def create_app() -> FastAPI:
    app = FastAPI(title="Atlas Interactive Backend", version="0.1.0")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(chat.router)
    app.include_router(trading.router)

    @app.get("/health")
    async def health() -> dict[str, str]:
        return {"status": "ok"}

    return app


app = create_app()


@app.websocket("/ws/health")
async def websocket_health(websocket: WebSocket) -> None:
    await websocket.accept()
    await websocket.send_json({"status": "ok"})
    await websocket.close()
