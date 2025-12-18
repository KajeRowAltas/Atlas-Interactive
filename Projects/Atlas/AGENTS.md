# Repository Guidelines

## Project Structure & Module Organization
- Root holds docs (`docs/` agent prompts, `mongodb/` notes), prototype UI under `ui/`, and the main app in `Atlas-Interactive/`.
- `Atlas-Interactive/atlas_dashboard/`: Flutter desktop/web shell for Oracle, Terminal, Dashboard, Markets.
- `Atlas-Interactive/backend/`: FastAPI + Mongo service; routers live in `app/routers/`, shared DB config in `app/database.py`, helper scripts in `backend/scripts/`.
- `Atlas-Interactive/references/atlas_website_design/`: Canonical static UI; shared design tokens in `styles.css` and `dark.css`.
- `Atlas-Interactive/docker-compose.yml`: Spins up backend + MongoDB 7 (named volume `mongo-data`).

## Build, Test, and Development Commands
- Backend env + deps: `cd Atlas-Interactive/backend && python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`.
- Run API locally: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000` (requires `.env` with `MONGODB_URI`/`DB_NAME`; pair with Mongo via `docker-compose up` from `Atlas-Interactive/`).
- Quick checks: `python scripts/test_setup.py` (library versions) and `python scripts/database_check.py` (Mongo connectivity).
- Flutter app: `cd Atlas-Interactive/atlas_dashboard && flutter pub get && flutter run -d macos` (or `-d chrome`).
- Lint/Test Flutter: `flutter analyze` and `flutter test` (widget tests live in `atlas_dashboard/test/`).

## Coding Style & Naming Conventions
- Python: favor async FastAPI handlers, type hints, and PEP 8; keep routers small in `app/routers/`; snake_case files/functions; do not commit `.env`.
- Dart: Flutter lints from `analysis_options.yaml`; run `dart format .` before commits; PascalCase widgets, snake_case files and directories.
- Frontend tokens: keep shared colors/spacing in `styles.css`/`dark.css` and mirror updates in Flutter theming.

## Testing Guidelines
- Extend Flutter coverage with descriptive `*_test.dart` names mirroring the widget; assert nav/render behavior as in `atlas_dashboard/test/widget_test.dart`.
- Backend automated tests are minimal; add new ones alongside endpoints (e.g., `backend/tests/test_chat.py`) and exercise websocket handlers with async clients.

## Commit & Pull Request Guidelines
- Commits use short, present-tense subjects (e.g., `Add trading websocket stream`, `Update docker compose envs`); group related changes.
- PRs should include a brief summary, commands run (tests/lint), screenshots or terminal output for UI/API changes, and linked issues/tasks. Update docs when setup steps or APIs change.

## Configuration & Security
- Keep secrets in `Atlas-Interactive/backend/.env`; never commit API keys. If adding new external services (LLMs, exchanges), gate them behind env vars and document defaults.
- For Docker users, ensure Mongo volume `mongo-data` can be pruned safely before destructive testing.

## Trading Bot (Bitget) Notes
- Trading endpoints are protected by `ATLAS_TRADING_TOKEN` (sent as `X-Atlas-Token` header; WS supports `?token=...`).
- If you hit `401 Unauthorized`, first verify the backend is loading the intended `backend/.env` (start uvicorn from `Atlas-Interactive/backend/`) and validate with: `curl -i -H "X-Atlas-Token: <token>" http://127.0.0.1:8000/trading/status`.
- Optional debugging: set `ATLAS_TRADING_DEBUG=true` in `backend/.env` to get more specific 401 details (still no secrets).

## Next UI Work (Crypto Tab)
- Goal: a clear Crypto dashboard to view/adjust bot parameters (symbol, leverage, dry-run/live gate, risk limits, indicator settings) and see live status/events from `/trading/ws`.
- Prefer a single “Bot Settings” model in Flutter that maps 1:1 to the backend `POST /trading/start` payload, plus a read-only “Bot Status” panel bound to `GET /trading/status`.

## Handoff Notes (Mongo `session_id` fix)
- Symptom: `E11000 duplicate key error ... ChatHistories index: session_id_1 dup key: { session_id: null }` happens when any writer inserts docs missing `session_id` while a unique index exists.
- Canonical contract + n8n guidance: `docs/chat_histories_contract.md`.
- n8n exports: `Oji_N8N_Backend.json` (current) and `Oji_Patch.json` (adds `session_id` guardrail and moves LangChain chat memory to `LangchainChatMemory`).
- Backend append endpoint (upsert + $push): `Atlas-Interactive/backend/app/routers/chat_history.py`.
- Production-safe Mongo index migration (partial unique index): `mongodb/chat_histories_index_migration.md` and script `Atlas-Interactive/backend/scripts/migrate_chat_histories_session_id.py`.
- Quick verification script: `Atlas-Interactive/backend/scripts/verify_chat_histories_session_id.py`.
