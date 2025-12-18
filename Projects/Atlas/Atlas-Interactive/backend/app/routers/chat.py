from fastapi import APIRouter
from pydantic import BaseModel

from app import database


class ChatRequest(BaseModel):
    message: str
    session_id: str | None = None


class ChatResponse(BaseModel):
    reply: str
    session_id: str


router = APIRouter(prefix="/chat", tags=["chat"])


@router.post("/", response_model=ChatResponse)
async def chat_endpoint(payload: ChatRequest) -> ChatResponse:
    _ = database.get_database()
    session = payload.session_id or "session-001"
    # Placeholder echo response until LLM/vector search is wired up.
    reply = f"Echo from Atlas: {payload.message}"
    return ChatResponse(reply=reply, session_id=session)
