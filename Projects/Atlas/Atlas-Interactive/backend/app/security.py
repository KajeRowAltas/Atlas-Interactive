from __future__ import annotations

import hmac
import os
from typing import Optional

from fastapi import Header, HTTPException, WebSocket


def _required_trading_token() -> str:
    token = os.getenv("ATLAS_TRADING_TOKEN")
    if not token:
        raise HTTPException(
            status_code=500,
            detail="Server misconfigured: ATLAS_TRADING_TOKEN is not set.",
        )
    return token.strip()


def _extract_bearer_token(authorization: Optional[str]) -> Optional[str]:
    if not authorization:
        return None
    parts = authorization.split(" ", 1)
    if len(parts) != 2:
        return None
    scheme, value = parts[0].strip(), parts[1].strip()
    if scheme.lower() != "bearer" or not value:
        return None
    return value


def require_trading_auth(
    authorization: Optional[str] = Header(default=None),
    x_atlas_token: Optional[str] = Header(default=None),
) -> None:
    required = _required_trading_token()
    provided = (x_atlas_token or _extract_bearer_token(authorization) or "").strip()
    if not provided or not hmac.compare_digest(provided, required):
        detail = "Unauthorized."
        if os.getenv("ATLAS_TRADING_DEBUG", "").lower() in {"1", "true", "yes"}:
            detail = (
                "Unauthorized (missing token)."
                if not provided
                else "Unauthorized (token mismatch)."
            )
        raise HTTPException(status_code=401, detail=detail)


async def require_trading_auth_ws(websocket: WebSocket) -> bool:
    token = os.getenv("ATLAS_TRADING_TOKEN")
    if not token:
        await websocket.close(code=1011)
        return False
    token = token.strip()

    provided = (websocket.query_params.get("token") or "").strip()
    if not provided:
        provided = (
            _extract_bearer_token(websocket.headers.get("authorization")) or ""
        ).strip()
    if not provided:
        provided = (websocket.headers.get("x-atlas-token") or "").strip()

    if not provided or not hmac.compare_digest(provided, token):
        await websocket.close(code=4401)
        return False

    return True
