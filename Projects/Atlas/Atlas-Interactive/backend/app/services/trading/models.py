from __future__ import annotations

from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, Field

BotState = Literal["stopped", "starting", "running", "stopping", "error"]
MarketType = Literal["swap"]


class RsiSettings(BaseModel):
    period: int = Field(default=14, ge=2, le=100)


class BollingerBandsSettings(BaseModel):
    period: int = Field(default=20, ge=2, le=100)
    std_dev: float = Field(default=2.0, ge=0.1, le=5.0)


class MarketStructureSettings(BaseModel):
    swing_points: int = Field(default=10, ge=2, le=50)


class IndicatorSettings(BaseModel):
    rsi: RsiSettings = Field(default_factory=RsiSettings)
    bbands: BollingerBandsSettings = Field(default_factory=BollingerBandsSettings)
    market_structure: MarketStructureSettings = Field(
        default_factory=MarketStructureSettings
    )


class TradingStartRequest(BaseModel):
    bot_id: str = Field(default="alpha", min_length=1)
    symbol: str = Field(default="BTC/USDT:USDT", min_length=1)
    market_type: MarketType = Field(default="swap")
    dry_run: bool = Field(default=True)
    enable_analysis: bool = Field(default=True)
    poll_interval_s: float = Field(default=2.0, ge=0.2, le=60.0)
    leverage: Optional[int] = Field(default=None, ge=1, le=125)
    indicator_settings: Optional[IndicatorSettings] = None


class TradingStopRequest(BaseModel):
    bot_id: str = Field(default="alpha", min_length=1)


class TradingStatusResponse(BaseModel):
    bot_id: str
    state: BotState
    dry_run: bool
    enable_analysis: bool = True
    symbol: Optional[str] = None
    market_type: Optional[MarketType] = None
    leverage: Optional[int] = None

    started_at: Optional[datetime] = None
    last_heartbeat_at: Optional[datetime] = None
    last_tick_at: Optional[datetime] = None
    last_price: Optional[float] = None
    last_error: Optional[str] = None


class OpenTrade(BaseModel):
    model_config = ConfigDict(extra="allow")

    symbol: str
    type: str
    side: str
    amount: float
    price: float
    datetime: str
    status: str
