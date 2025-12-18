from __future__ import annotations

import argparse
from collections import defaultdict
from datetime import timedelta
from pathlib import Path

from app.services.trading.history_bitget import (
    default_2025_history_paths,
    load_bitget_futures_position_history,
)


def _find_repo_root(start: Path) -> Path:
    cur = start
    for _ in range(8):
        if (cur / "Crypto").exists() and (cur / "Atlas").exists():
            return cur
        cur = cur.parent
    raise RuntimeError("Could not locate repo root (expected Crypto/ and Atlas/).")


def _fmt_duration(td: timedelta | None) -> str:
    if td is None:
        return "n/a"
    total = int(td.total_seconds())
    minutes = total // 60
    if minutes < 60:
        return f"{minutes}m"
    hours = minutes // 60
    minutes = minutes % 60
    return f"{hours}h{minutes:02d}m"


def main() -> int:
    parser = argparse.ArgumentParser(description="Analyze Bitget futures history exports.")
    parser.add_argument(
        "--repo-root",
        default=None,
        help="Path containing Crypto/ and Atlas/ (defaults to auto-detect).",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).expanduser().resolve() if args.repo_root else _find_repo_root(Path(__file__).resolve())
    paths = default_2025_history_paths(str(repo_root))
    positions = load_bitget_futures_position_history(paths.position_history_xlsx)

    if not positions:
        print("No positions found.")
        return 0

    totals = {
        "positions": 0,
        "wins": 0,
        "losses": 0,
        "pnl": 0.0,
        "fees": 0.0,
        "durations": [],
    }
    by_symbol: dict[str, dict] = defaultdict(lambda: {"positions": 0, "wins": 0, "losses": 0, "pnl": 0.0, "fees": 0.0, "durations": []})

    for p in positions:
        totals["positions"] += 1
        by_symbol[p.symbol]["positions"] += 1

        pnl = p.realized_pnl or 0.0
        fee = p.fee or 0.0
        totals["pnl"] += pnl
        totals["fees"] += fee
        by_symbol[p.symbol]["pnl"] += pnl
        by_symbol[p.symbol]["fees"] += fee

        if pnl > 0:
            totals["wins"] += 1
            by_symbol[p.symbol]["wins"] += 1
        elif pnl < 0:
            totals["losses"] += 1
            by_symbol[p.symbol]["losses"] += 1

        if p.open_time_utc and p.close_time_utc and p.close_time_utc > p.open_time_utc:
            dur = p.close_time_utc - p.open_time_utc
            totals["durations"].append(dur)
            by_symbol[p.symbol]["durations"].append(dur)

    def avg_duration(durations: list[timedelta]) -> timedelta | None:
        if not durations:
            return None
        return sum(durations, timedelta()) / len(durations)

    win_rate = (totals["wins"] / totals["positions"]) * 100.0
    print(f"Positions: {totals['positions']} | Win rate: {win_rate:.1f}%")
    print(f"Realized PnL (numeric): {totals['pnl']:.6f} | Fees (numeric): {totals['fees']:.6f}")
    print(f"Avg duration: {_fmt_duration(avg_duration(totals['durations']))}")
    print("")
    print("By symbol:")
    for sym, s in sorted(by_symbol.items(), key=lambda kv: abs(kv[1]['pnl']), reverse=True):
        positions_n = s["positions"]
        wr = (s["wins"] / positions_n) * 100.0 if positions_n else 0.0
        print(
            f"- {sym}: positions={positions_n}, win_rate={wr:.1f}%, pnl={s['pnl']:.6f}, fees={s['fees']:.6f}, avg_dur={_fmt_duration(avg_duration(s['durations']))}"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

