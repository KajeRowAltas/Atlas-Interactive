from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Optional, Protocol


@dataclass(frozen=True)
class StrategySignal:
    side: str  # long | short
    reason: str
    meta: Optional[dict[str, Any]] = None


class Strategy(Protocol):
    def evaluate(
        self, analysis_by_timeframe: dict[str, dict[str, Any]]
    ) -> Optional[StrategySignal]: ...


class NoopStrategy:
    def evaluate(
        self, analysis_by_timeframe: dict[str, dict[str, Any]]
    ) -> Optional[StrategySignal]:
        return None
