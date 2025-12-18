from __future__ import annotations

from typing import Optional


def bitget_export_symbol_to_ccxt_swap(symbol: str) -> Optional[str]:
    """
    Best-effort mapping from Bitget export symbol (e.g., BTCUSDT) to ccxt swap symbol.

    Examples:
    - BTCUSDT -> BTC/USDT:USDT
    - DOGEUSDC -> DOGE/USDC:USDC
    - BTCUSD -> BTC/USD:USD (if present)
    """
    s = (symbol or "").strip().upper()
    if not s:
        return None

    for quote in ("USDT", "USDC", "USD"):
        if s.endswith(quote) and len(s) > len(quote):
            base = s[: -len(quote)]
            if not base.isalnum():
                return None
            return f"{base}/{quote}:{quote}"
    return None
