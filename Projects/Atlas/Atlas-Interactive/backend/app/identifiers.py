import uuid
from typing import Optional


def normalize_optional_id(value: Optional[str]) -> Optional[str]:
    if value is None:
        return None
    trimmed = value.strip()
    return trimmed or None


def ensure_session_id(value: Optional[str]) -> str:
    normalized = normalize_optional_id(value)
    return normalized or str(uuid.uuid4())


def ensure_trace_id(value: Optional[str]) -> str:
    normalized = normalize_optional_id(value)
    return normalized or str(uuid.uuid4())
