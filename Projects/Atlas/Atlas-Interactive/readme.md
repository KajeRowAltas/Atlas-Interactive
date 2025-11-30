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

### Docs
- Canonical digest: `../../docs/project_digest_for_chatgpt.md` (repo root)
- Root overview: `../../README.md`

Keep all Atlas-Interactive changes within this directory to maintain the single source of truth.
