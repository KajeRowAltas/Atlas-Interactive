from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Literal
from typing import Optional

from fastapi import APIRouter
from pydantic import BaseModel, ConfigDict, Field, field_validator

from app import database


router = APIRouter(prefix="/chat/history", tags=["chat_history"])


class ChatHistoryAppendRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True, extra="allow")

    session_id: str = Field(alias="sessionId", min_length=1)
    trace_id: Optional[str] = Field(default=None, alias="traceId")
    turn_id: Optional[int] = Field(default=None, alias="turnId", ge=1)

    agent: str = Field(min_length=1)
    role: Literal["user", "assistant", "system", "tool"]
    content: str = Field(min_length=1)
    meta: Optional[dict[str, Any]] = None

    @field_validator("session_id", mode="before")
    @classmethod
    def _strip_session_id(cls, value: Any) -> Any:
        if isinstance(value, str):
            return value.strip()
        return value

    @field_validator("agent", "role", "content", mode="before")
    @classmethod
    def _strip_strings(cls, value: Any) -> Any:
        if isinstance(value, str):
            return value.strip()
        return value


class ChatHistoryAppendResponse(BaseModel):
    ok: bool
    session_id: str
    upserted_id: Optional[str] = None


@router.post("/append", response_model=ChatHistoryAppendResponse)
async def append_chat_history(payload: ChatHistoryAppendRequest) -> ChatHistoryAppendResponse:
    now = datetime.now(timezone.utc)
    db = database.get_database()

    message: dict[str, Any] = {
        "ts": now,
        "agent": payload.agent,
        "role": payload.role,
        "content": payload.content,
    }
    if payload.trace_id:
        message["trace_id"] = payload.trace_id
    if payload.turn_id is not None:
        message["turn_id"] = payload.turn_id
    if payload.meta:
        message["meta"] = payload.meta

    update = {
        "$setOnInsert": {
            "created_at": now,
            "session_id": payload.session_id,
            "sessionId": payload.session_id,  # Back-compat for legacy readers.
        },
        "$set": {"updated_at": now},
        "$push": {"messages": message},
    }

    result = await db["ChatHistories"].update_one(
        {"session_id": payload.session_id},
        update,
        upsert=True,
    )

    return ChatHistoryAppendResponse(
        ok=True,
        session_id=payload.session_id,
        upserted_id=str(result.upserted_id) if result.upserted_id else None,
    )
