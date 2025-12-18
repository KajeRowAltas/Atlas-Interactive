from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Any, Optional

from app.services.trading.history_bitget import BitgetFuturesPosition
from app.services.trading.indicators import bollinger_bands, rsi
from app.services.trading.market_structure import market_structure
from app.services.trading.symbols import bitget_export_symbol_to_ccxt_swap


@dataclass(frozen=True)
class PositionFeatures:
    symbol: str
    open_time_utc: datetime
    close_time_utc: Optional[datetime]
    direction: str
    realized_pnl: float
    fee: float
    features: dict[str, Any]


async def _fetch_ohlcv_for_entry(
    exchange: Any,
    *,
    symbol: str,
    timeframe: str,
    entry_time_utc: datetime,
    limit: int = 250,
) -> list[list[float]]:
    entry_ms = int(entry_time_utc.timestamp() * 1000)
    tf_ms = 60_000
    if timeframe.endswith("m"):
        tf_ms = int(timeframe[:-1]) * 60_000
    elif timeframe.endswith("h"):
        tf_ms = int(timeframe[:-1]) * 3_600_000
    since = entry_ms - tf_ms * limit
    return await exchange.fetch_ohlcv(
        symbol, timeframe=timeframe, since=since, limit=limit
    )


def _compute_tf_features(ohlcv: list[list[float]]) -> Optional[dict[str, Any]]:
    if not ohlcv:
        return None
    closes = [float(c[4]) for c in ohlcv if c and len(c) >= 5]
    highs = [float(c[2]) for c in ohlcv if c and len(c) >= 3]
    lows = [float(c[3]) for c in ohlcv if c and len(c) >= 4]
    if not closes or not highs or not lows:
        return None

    bb = bollinger_bands(closes)
    rs = rsi(closes)
    ms = market_structure(highs, lows, closes)
    return {
        "close": closes[-1],
        "rsi": rs,
        "bb_middle": bb.middle if bb else None,
        "bb_upper": bb.upper if bb else None,
        "bb_lower": bb.lower if bb else None,
        "ms_trend": ms.trend if ms else None,
        "ms_bos": ms.bos if ms else None,
        "ms_choch": ms.choch if ms else None,
    }


async def build_position_features(
    exchange: Any,
    position: BitgetFuturesPosition,
    *,
    timeframes: tuple[str, ...] = ("15m", "3m", "1m"),
) -> Optional[PositionFeatures]:
    ccxt_symbol = bitget_export_symbol_to_ccxt_swap(position.symbol)
    if ccxt_symbol is None:
        return None
    if position.open_time_utc is None:
        return None

    features: dict[str, Any] = {}
    for tf in timeframes:
        ohlcv = await _fetch_ohlcv_for_entry(
            exchange,
            symbol=ccxt_symbol,
            timeframe=tf,
            entry_time_utc=position.open_time_utc,
        )
        tf_features = _compute_tf_features(ohlcv)
        features[tf] = tf_features

    return PositionFeatures(
        symbol=ccxt_symbol,
        open_time_utc=position.open_time_utc,
        close_time_utc=position.close_time_utc,
        direction=position.direction,
        realized_pnl=position.realized_pnl or 0.0,
        fee=position.fee or 0.0,
        features=features,
    )
