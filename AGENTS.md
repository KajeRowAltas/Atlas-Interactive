# Repository Guidelines

## Project Structure & Module Organization
- Flutter mission-control dashboard: `Projects/Atlas/Atlas-Interactive/atlas_dashboard/` (widgets, services, tests).
- FastAPI backend: `Projects/Atlas/Atlas-Interactive/backend/` (chat and trading routers; env-driven config).
- Docker + shared styling: `Projects/Atlas/Atlas-Interactive/docker-compose.yml`, `styles.css`, `dark.css`.
- Canonical static UI: `Projects/Atlas/Atlas-Interactive/references/atlas_website_design/`.
- Oji agent workflows and prompts: `Projects/Atlas/Oji` and `Projects/Atlas/Oji_2`; MongoDB blueprints in `Shared_Resources/Mongodb/`.
- Docs: `docs/project_digest_for_chatgpt.md` for the latest high-level map; more per-feature docs under `docs/` and `Projects/Atlas/Oji*/README*.md`.

## Build, Test, and Development Commands
- Flutter: `cd Projects/Atlas/Atlas-Interactive/atlas_dashboard && flutter pub get && flutter run -d macos` (use `-d chrome` for web). Run tests with `flutter test`.
- Backend: `cd Projects/Atlas/Atlas-Interactive/backend && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt && uvicorn app.main:app --reload`.
- Full stack (backend + MongoDB): `cd Projects/Atlas/Atlas-Interactive && docker-compose up`.
- Static UI preview: open `Projects/Atlas/Atlas-Interactive/references/atlas_website_design/index.html` in a browser or serve via a simple `python -m http.server`.

## Coding Style & Naming Conventions
- Dart: use `dart format .`/`flutter format` and `flutter analyze`; 2-space indentation; prefer clear widget naming (`AtlasCard`, `TerminalPanel`).
- Python: PEP 8 with type hints; 4-space indentation; keep FastAPI routers lean and push logic into services where practical.
- Config files: keep `.env.example` updated when adding new environment keys; avoid hard-coded secrets.

## Testing Guidelines
- Primary coverage exists in `atlas_dashboard/test`; add widget/service tests alongside features and keep them hermetic (stub network/DB).
- Backend tests are minimal; if adding, place them under `backend/tests/` and prefer `pytest` with mock clients instead of live exchanges or OpenAI.
- For integration checks, spin up `docker-compose` and hit FastAPI routes (chat/trading) with sample payloads before merging.

## Commit & Pull Request Guidelines
- Follow Conventional Commit prefixes observed here (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`).
- Keep commits scoped and buildable; avoid mixing Flutter UI, backend, and workflow changes unless necessary.
- PRs should include: concise summary, test notes (`flutter test`, manual steps, or API calls exercised), screenshots/GIFs for UI changes, and call out any config/env updates required for deploys.

## Security & Configuration Tips
- Do not commit real API keys (OpenAI, exchanges) or Mongo connection strings; use local `.env` and keep credential JSON files placeholder-only.
- When sharing datasets or exports, place them in `Shared_Resources/` and document provenance; scrub PII before upload.
