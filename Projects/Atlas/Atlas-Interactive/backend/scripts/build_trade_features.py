from __future__ import annotations

import argparse
import asyncio
import csv
from pathlib import Path

from app.services.trading.ccxt_bitget import (
    create_ccxt_bitget_exchange,
    load_bitget_credentials_from_env,
)
from app.services.trading.feature_builder import build_position_features
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


async def _run(repo_root: Path, out_csv: Path) -> None:
    paths = default_2025_history_paths(str(repo_root))
    positions = load_bitget_futures_position_history(paths.position_history_xlsx)

    exchange = create_ccxt_bitget_exchange(
        creds=load_bitget_credentials_from_env(),
        market_type="swap",
    )

    fieldnames = [
        "symbol",
        "open_time_utc",
        "close_time_utc",
        "direction",
        "realized_pnl",
        "fee",
        "tf",
        "close",
        "rsi",
        "bb_middle",
        "bb_upper",
        "bb_lower",
        "ms_trend",
        "ms_bos",
        "ms_choch",
    ]

    try:
        with out_csv.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()

            for idx, pos in enumerate(positions, start=1):
                feat = await build_position_features(exchange, pos)
                if feat is None:
                    continue
                for tf, tf_feat in feat.features.items():
                    if not tf_feat:
                        continue
                    writer.writerow(
                        {
                            "symbol": feat.symbol,
                            "open_time_utc": feat.open_time_utc.isoformat(),
                            "close_time_utc": feat.close_time_utc.isoformat()
                            if feat.close_time_utc
                            else "",
                            "direction": feat.direction,
                            "realized_pnl": f"{feat.realized_pnl:.10f}",
                            "fee": f"{feat.fee:.10f}",
                            "tf": tf,
                            **{k: tf_feat.get(k) for k in fieldnames if k in tf_feat},
                        }
                    )

                if idx % 25 == 0:
                    print(f"Processed {idx}/{len(positions)} positions...")
    finally:
        await exchange.close()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build a feature CSV from Bitget position history (fetches public OHLCV)."
    )
    parser.add_argument(
        "--repo-root",
        default=None,
        help="Path containing Crypto/ and Atlas/ (defaults to auto-detect).",
    )
    parser.add_argument(
        "--out",
        default="trade_features.csv",
        help="Output CSV path (relative to backend/ by default).",
    )
    args = parser.parse_args()

    repo_root = (
        Path(args.repo_root).expanduser().resolve()
        if args.repo_root
        else _find_repo_root(Path(__file__).resolve())
    )
    out_csv = Path(args.out).expanduser().resolve()

    asyncio.run(_run(repo_root, out_csv))
    print(f"Wrote {out_csv}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
