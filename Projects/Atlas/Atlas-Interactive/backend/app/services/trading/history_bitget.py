from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Optional

from app.services.trading.xlsx_table import iter_rows


_BITGET_EXPORT_TZ = timezone(timedelta(hours=1))


def _parse_time_utc(value: Optional[str]) -> Optional[datetime]:
    if not value:
        return None
    # Bitget export example: "2025-12-13 16:19:11" labelled as UTC+01:00.
    try:
        dt = datetime.strptime(value.strip(), "%Y-%m-%d %H:%M:%S")
        return dt.replace(tzinfo=_BITGET_EXPORT_TZ).astimezone(timezone.utc)
    except ValueError:
        return None


def _parse_float_prefix(value: Optional[str]) -> Optional[float]:
    if value is None:
        return None
    s = str(value).strip()
    if s == "":
        return None
    num = []
    for ch in s:
        if ch.isdigit() or ch in {".", "-", "+"}:
            num.append(ch)
        else:
            break
    try:
        return float("".join(num))
    except ValueError:
        return None


@dataclass(frozen=True)
class BitgetFuturesPosition:
    symbol: str
    direction: str
    open_time_utc: Optional[datetime]
    close_time_utc: Optional[datetime]
    avg_entry_price: Optional[float]
    avg_close_price: Optional[float]
    closing_qty_cont: Optional[float]
    fee: Optional[float]
    realized_pnl: Optional[float]
    status: Optional[str]


def load_bitget_futures_position_history(path: str) -> list[BitgetFuturesPosition]:
    positions: list[BitgetFuturesPosition] = []
    for row in iter_rows(path):
        positions.append(
            BitgetFuturesPosition(
                symbol=(row.get("Futures") or "").strip(),
                direction=(row.get("Direction") or "").strip(),
                open_time_utc=_parse_time_utc(row.get("Open Time(UTC+01:00)")),
                close_time_utc=_parse_time_utc(row.get("Close Time")),
                avg_entry_price=_parse_float_prefix(row.get("Avg Entry Price")),
                avg_close_price=_parse_float_prefix(row.get("Avg Close Price")),
                closing_qty_cont=_parse_float_prefix(row.get("Closing Qty (Cont.)")),
                fee=_parse_float_prefix(row.get("Fee")),
                realized_pnl=_parse_float_prefix(row.get("Realized PNL")),
                status=row.get("Status"),
            )
        )
    return [p for p in positions if p.symbol]


@dataclass(frozen=True)
class HistoryPaths:
    trade_history_xlsx: str
    order_history_xlsx: str
    position_history_xlsx: str
    capital_flow_xlsx: str


def default_2025_history_paths(repo_root: str) -> HistoryPaths:
    base = Path(repo_root) / "Crypto" / "Trading History" / "2025"
    return HistoryPaths(
        trade_history_xlsx=str(
            next(base.glob("Futures-Futures Trade History-*.xlsx"))
        ),
        order_history_xlsx=str(
            next(base.glob("Futures-Futures Order History-*.xlsx"))
        ),
        position_history_xlsx=str(
            next(base.glob("Futures-Futures Position History-*.xlsx"))
        ),
        capital_flow_xlsx=str(next(base.glob("Futures-Futures Capital Flow-*.xlsx"))),
    )
