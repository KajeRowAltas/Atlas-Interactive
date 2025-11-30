# Atlas Interactive – Source of Truth

This repository is the canonical home for the Atlas Interactive app stack: the Flutter mission-control dashboard, FastAPI backend, n8n Oji agents, MongoDB schemas/blueprints (OjiDB), and static design assets.

## Stack overview
- `Projects/Atlas/Atlas-Interactive/atlas_dashboard/` — Flutter desktop/web shell with CommandController + MainShell (Oracle chat, Terminal, Dashboard, Markets).
- `Projects/Atlas/Atlas-Interactive/backend/` — FastAPI service with chat and trading websocket routes; Dockerfile + scripts for local runs.
- `Projects/Atlas/Atlas-Interactive/docker-compose.yml` — Boots backend + MongoDB 7 for local development.
- `Projects/Atlas/Atlas-Interactive/styles.css`, `Projects/Atlas/Atlas-Interactive/dark.css` — Brand tokens mirrored by the Flutter theme.
- `Projects/Atlas/Atlas-Interactive/references/atlas_website_design/` — Canonical static Atlas/Oji UI (HTML/CSS/JS) used by design + theme mapping.
- `Projects/Atlas/Oji` and `Projects/Atlas/Oji_2` — n8n workflows, prompts, and OjiDB blueprints/indexes.
- `Projects/Atlas/ui/oji_chat_ui/` — Historical static site copy (see README in that folder).
- `Shared_Resources/Mongodb/` — OjiDB architecture exports and collection/index metadata.
- `docs/project_digest_for_chatgpt.md` — Canonical high-level digest (read this first).

## Getting started
1) Install Flutter, Python 3.11, and Docker/Docker Compose.
2) From `Projects/Atlas/Atlas-Interactive/atlas_dashboard/`: `flutter pub get` then `flutter run -d macos` (or `-d chrome`).
3) From `Projects/Atlas/Atlas-Interactive/backend/`: `python -m venv venv && source venv/bin/activate && pip install -r requirements.txt && uvicorn app.main:app --reload`.
4) From `Projects/Atlas/Atlas-Interactive/`: `docker-compose up` to run backend + MongoDB.

## Docs
- Digest: `docs/project_digest_for_chatgpt.md` (mirrors the latest project summary and layout).
- Oji agent guides: `Projects/Atlas/Oji/README.md`, `Projects/Atlas/Oji_2/README_BEGINNER_GUIDE.md`.
- OjiDB architecture: `Shared_Resources/Mongodb/Readme.md`.

## Contributing
- Treat this repo as the single source of truth; add new assets here before deploying anywhere else (for Atlas-Interactive, place code under `Projects/Atlas/Atlas-Interactive/`).
- Keep secrets out of git (`backend/.env`, n8n credential files). Use `.env.example` for placeholders.
- Prefer incremental changes: keep app building, backend tests passing, and workflows importable.
