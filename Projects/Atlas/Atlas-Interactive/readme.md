## Atlas-Interactive Application (Project Root)

This directory is the canonical home for the Atlas-Interactive app stack.

### What’s here
- `atlas_dashboard/` — Flutter desktop/web shell (Oracle chat, Terminal, Dashboard, Markets) with Atlas theming.
- `backend/` — FastAPI service (chat + trading websocket), MongoDB integration, Dockerfile, scripts.
- `docker-compose.yml` — Spins up backend + MongoDB 7 for local development.
- `styles.css`, `dark.css` — Design tokens shared across static UI and Flutter theme mapping.
- `references/atlas_website_design/` — Canonical static Atlas/Oji UI (HTML/CSS/JS).

### How to run
- Flutter: `cd atlas_dashboard && flutter pub get && flutter run -d macos` (or `-d chrome`)
- Backend: `cd backend && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt && uvicorn app.main:app --reload`
- Docker: `cd . && docker-compose up` (from this directory)

### Trading bot (Bitget futures)
- Control endpoints: `GET /trading/status`, `POST /trading/start`, `POST /trading/stop`, and websocket `GET /trading/ws`.
- Env vars live in `backend/.env` (see `backend/.env.example`); calls require `ATLAS_TRADING_TOKEN`; live orders require `ATLAS_TRADING_LIVE=true`.
- Current behavior: streams futures ticker updates; strategy/order logic plugs in next.
- Atlas Dashboard: open the Crypto screen, paste `ATLAS_TRADING_TOKEN`, then start `PEPE/USDT:USDT` in dry-run mode.
- Quick setup:
  - Generate token: `cd backend && python -m scripts.generate_trading_token`
  - Put it in `backend/.env` as `ATLAS_TRADING_TOKEN=...`
  - Run backend: `cd backend && python -m uvicorn app.main:app --reload --port 8000`
- Troubleshooting 401: run `curl -i -H "X-Atlas-Token: $ATLAS_TRADING_TOKEN" http://127.0.0.1:8000/trading/status` from the same shell you started the backend in.
- History analysis (from the workspace exports in `Crypto/Trading History/2025`): `cd backend && python -m scripts.analyze_bitget_history`.
- History feature export (downloads public OHLCV; needs network): `cd backend && python -m scripts.build_trade_features --out trade_features.csv`.

### Docs
- Canonical digest: `../../docs/project_digest_for_chatgpt.md` (repo root)
- Root overview: `../../README.md`
- Chat history + session id contract: `../../docs/chat_histories_contract.md`
- Mongo index migration for `ChatHistories.session_id`: `../../mongodb/chat_histories_index_migration.md`

Keep all Atlas-Interactive changes within this directory to maintain the single source of truth.
