from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class BitgetCredentials:
    api_key: Optional[str]
    secret_key: Optional[str]
    passphrase: Optional[str]


def load_bitget_credentials_from_env() -> BitgetCredentials:
    return BitgetCredentials(
        api_key=os.getenv("BITGET_API_KEY"),
        secret_key=os.getenv("BITGET_SECRET_KEY"),
        passphrase=os.getenv("BITGET_PASSPHRASE"),
    )


def create_ccxt_bitget_exchange(
    *,
    creds: BitgetCredentials,
    market_type: str,
):
    import ccxt.async_support as ccxt

    config: dict = {
        "enableRateLimit": True,
        "options": {
            "defaultType": market_type,
            "urls": {
                "api": {
                    "public": "https://api.bitget.com/api/v2",
                    "private": "https://api.bitget.com/api/v2",
                }
            },
        },
        "version": "v2",
    }

    if creds.api_key and creds.secret_key and creds.passphrase:
        config.update(
            {
                "apiKey": creds.api_key,
                "secret": creds.secret_key,
                "password": creds.passphrase,
            }
        )

    return ccxt.bitget(config)
