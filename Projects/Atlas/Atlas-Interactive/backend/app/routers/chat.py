from fastapi import APIRouter
from pydantic import BaseModel, ConfigDict, Field, field_validator
from typing import Any
from typing import Optional

from app import database
from app.identifiers import ensure_session_id


class ChatRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True, extra="allow")

    message: str
    session_id: Optional[str] = Field(default=None, alias="sessionId")

    @field_validator("session_id", mode="before")
    @classmethod
    def _strip_session_id(cls, value: Any) -> Any:
        if isinstance(value, str):
            return value.strip()
        return value


class ChatResponse(BaseModel):
    reply: str
    session_id: str


router = APIRouter(prefix="/chat", tags=["chat"])


@router.post("/", response_model=ChatResponse)
async def chat_endpoint(payload: ChatRequest) -> ChatResponse:
    _ = database.get_database()
    session = ensure_session_id(payload.session_id)
    # Placeholder echo response until LLM/vector search is wired up.
    reply = f"Echo from Atlas: {payload.message}"
    return ChatResponse(reply=reply, session_id=session)
