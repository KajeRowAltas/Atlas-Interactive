from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Sequence


@dataclass(frozen=True)
class MarketStructure:
    trend: str  # bullish | bearish | ranging
    last_pivot_high: Optional[float]
    last_pivot_low: Optional[float]
    bos: Optional[str]  # bullish | bearish
    choch: Optional[str]  # bullish | bearish


def _pivot_highs(highs: Sequence[float], lookback: int) -> list[tuple[int, float]]:
    pivots: list[tuple[int, float]] = []
    for i in range(lookback, len(highs) - lookback):
        left = highs[i - lookback : i]
        right = highs[i + 1 : i + 1 + lookback]
        if highs[i] > max(left) and highs[i] >= max(right):
            pivots.append((i, highs[i]))
    return pivots


def _pivot_lows(lows: Sequence[float], lookback: int) -> list[tuple[int, float]]:
    pivots: list[tuple[int, float]] = []
    for i in range(lookback, len(lows) - lookback):
        left = lows[i - lookback : i]
        right = lows[i + 1 : i + 1 + lookback]
        if lows[i] < min(left) and lows[i] <= min(right):
            pivots.append((i, lows[i]))
    return pivots


def market_structure(
    highs: Sequence[float],
    lows: Sequence[float],
    closes: Sequence[float],
    *,
    pivot_lookback: int = 3,
) -> Optional[MarketStructure]:
    if not highs or not lows or not closes:
        return None
    if len(highs) != len(lows) or len(lows) != len(closes):
        return None
    if len(closes) < pivot_lookback * 3 + 2:
        return None

    ph = _pivot_highs(highs, pivot_lookback)
    pl = _pivot_lows(lows, pivot_lookback)
    last_ph = ph[-1][1] if ph else None
    prev_ph = ph[-2][1] if len(ph) >= 2 else None
    last_pl = pl[-1][1] if pl else None
    prev_pl = pl[-2][1] if len(pl) >= 2 else None

    trend = "ranging"
    if last_ph is not None and prev_ph is not None and last_pl is not None and prev_pl is not None:
        if last_ph > prev_ph and last_pl > prev_pl:
            trend = "bullish"
        elif last_ph < prev_ph and last_pl < prev_pl:
            trend = "bearish"

    close = closes[-1]
    bos = None
    if last_ph is not None and close > last_ph:
        bos = "bullish"
    if last_pl is not None and close < last_pl:
        bos = "bearish"

    choch = None
    if trend == "bullish" and last_pl is not None and close < last_pl:
        choch = "bearish"
    if trend == "bearish" and last_ph is not None and close > last_ph:
        choch = "bullish"

    return MarketStructure(
        trend=trend,
        last_pivot_high=last_ph,
        last_pivot_low=last_pl,
        bos=bos,
        choch=choch,
    )
