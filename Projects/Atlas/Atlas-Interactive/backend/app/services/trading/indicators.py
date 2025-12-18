from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Optional, Sequence


@dataclass(frozen=True)
class BollingerBands:
    middle: float
    upper: float
    lower: float
    stdev: float


def bollinger_bands(
    closes: Sequence[float],
    *,
    period: int = 20,
    stdevs: float = 2.0,
) -> Optional[BollingerBands]:
    if len(closes) < period or period <= 1:
        return None
    window = list(closes[-period:])
    mean = sum(window) / period
    var = sum((x - mean) ** 2 for x in window) / period
    stdev = math.sqrt(var)
    return BollingerBands(
        middle=mean,
        upper=mean + stdevs * stdev,
        lower=mean - stdevs * stdev,
        stdev=stdev,
    )


def rsi(closes: Sequence[float], *, period: int = 14) -> Optional[float]:
    if len(closes) < period + 1 or period <= 1:
        return None

    gains = 0.0
    losses = 0.0
    for i in range(-period, 0):
        change = closes[i] - closes[i - 1]
        if change >= 0:
            gains += change
        else:
            losses -= change

    avg_gain = gains / period
    avg_loss = losses / period
    if avg_loss == 0:
        return 100.0
    rs = avg_gain / avg_loss
    return 100.0 - (100.0 / (1.0 + rs))
