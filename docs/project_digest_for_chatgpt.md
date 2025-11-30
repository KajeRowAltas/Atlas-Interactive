# Project Digest for ChatGPT

## 1. Project Summary
Atlas Interactive is a multi-surface AI workspace that blends a Flutter-based mission control dashboard, a FastAPI backend, and n8n agent workflows for the Oji conversational assistant. The stack includes design system assets (HTML/CSS prototypes and Flutter theme mappings), MongoDB schemas/blueprints for OjiDB, and Docker tooling to run the API with Mongo locally. Primary use cases center on chatting with Oji, monitoring trading/ops signals, issuing commands through an embedded terminal, and iterating on the assistant’s memory and prompt architecture.

## 2. Repository Structure & Key Files
- Root workspace (Git root hosts docs and project directories)
  - `Projects/Atlas/Atlas-Interactive/atlas_dashboard/` — Flutter desktop/web shell for Atlas with Atlas-branded theming.
  - `Projects/Atlas/Atlas-Interactive/backend/` — FastAPI service with chat and trading websocket endpoints backed by Mongo.
  - `Projects/Atlas/Atlas-Interactive/docker-compose.yml` — Spins up the backend plus MongoDB 7 with a named volume.
  - `Projects/Atlas/Atlas-Interactive/references/atlas_website_design/` — Static Atlas/Oji web UI prototype (HTML/CSS/JS), canonical design source.
  - `Projects/Atlas/Atlas-Interactive/styles.css`, `Projects/Atlas/Atlas-Interactive/dark.css` — Brand tokens/gradients mirrored by the Flutter theme helpers.
  - `Projects/Atlas/Oji`, `Projects/Atlas/Oji_2` — Oji agent assets, Mongo schemas, and docs.
  - `Shared_Resources/Mongodb/` — OjiDB architecture and collection schema JSON dumps.

- Frontend (Flutter)
  - `atlas_dashboard/lib/main.dart` — Entry point; `CommandController` + `MainShell` navigation for Oracle chat, Terminal logs, Dashboard cards, and Markets placeholder with command parsing (`/nav`, `/panic`).
  - `atlas_dashboard/lib/services/backend_service.dart` — HTTP helper to POST chat messages to the backend.
  - `atlas_dashboard/lib/theme/atlas_theme_data.dart` — Atlas palette/typography/gradients/surfaces mapped from CSS tokens.
  - `atlas_dashboard/lib/widgets/terminal_panel.dart` — Embedded shell using `flutter_pty` + `xterm` inside an Atlas-styled card.
  - `atlas_dashboard/lib/widgets/atlas_webview.dart` — Card-wrapped WebView with reload control.
  - `atlas_dashboard/pubspec.yaml` — Flutter app metadata, dependencies, and asset declarations (Atlas logo, Shared Drive background).

- Backend (FastAPI)
  - `backend/app/main.py` — FastAPI factory with CORS, health routes, and websocket health; mounts chat/trading routers.
  - `backend/app/routers/chat.py` — `/chat` POST placeholder echoing replies while reserving DB hook; returns session IDs.
  - `backend/app/routers/trading.py` — WebSocket streaming timestamped bot status with random PnL for the Markets tab.
  - `backend/app/database.py` — MongoDB sync/async client helpers driven by `MONGODB_URI`/`DB_NAME` env vars.
  - `backend/requirements.txt` — Dependency pins (FastAPI, Motor, Pydantic v2, CCXT, OpenAI SDK, etc.).
  - `backend/Dockerfile` — Python 3.11-slim image installing requirements and launching uvicorn.
  - `backend/.env` — Runtime secrets for Mongo ([SECRET REDACTED]).
  - `backend/scripts/database_check.py` — Connectivity check against Mongo Atlas with friendly logging.
  - `backend/scripts/setup_env.sh` — Creates venv and installs requirements.
  - `backend/scripts/test_setup.py` — Prints versions of core libraries (ccxt, pymongo, fastapi).

- Monorepo highlights (`Atlas-Interactive/`)
  - `Projects/Atlas/Oji/` — n8n three-agent workflow exports (main + reflection flows), prompts, Mongo blueprint/index definitions, beginner guide, and credential placeholders for OpenAI/Mongo ([SECRETS REDACTED]).
  - `Projects/Atlas/Oji_2/` — Second iteration of Oji workflows/prompts/config with quick-start guide and test fixtures; credential placeholders.
  - `Projects/Atlas/ui/oji_chat_ui/WebsitePrompt` — Prompt describing desired Atlas/Oji web UI structure and assets for static site generation.
  - `Projects/Atlas/docs/` — Reference datasets for query categorisation and personality/TELOS profiles.
  - `Projects/_review_needed/.github/workflows/deploy.yml` — Legacy GitHub Actions FTP deploy to Hostinger.
  - `Shared_Resources/Mongodb/` — OjiDB architecture blueprint/indexes and collection schema JSON dumps.

- Reference site assets
  - `Projects/Atlas/Atlas-Interactive/references/atlas_website_design/index.html` (plus `login.html`, `dashboard.html`, `settings.html`, `project-panel.html`, `admin.html`) — Canonical static Atlas/Oji UI mock pages.
  - `Projects/Atlas/Atlas-Interactive/references/atlas_website_design/css/styles.css` and `css/dark.css` — Theme tokens and dark overrides reused by Flutter theme mapping.
  - `Projects/Atlas/Atlas-Interactive/references/atlas_website_design/js/*.js` — Modular JS for chat UI, webhook API integration, commands, dashboard/settings/project/admin interactions.
  - Historical copy preserved at `Projects/Atlas/ui/oji_chat_ui/Website` (do not edit; reference only).

## 3. Domain Concepts & Terminology
- Atlas — Overall mission-control brand for the workspace; used across Flutter UI tabs and site prototypes (`atlas_dashboard/lib/main.dart`, `references/atlas_website_design`).
- Oji — Conversational AI agent orchestrated through n8n workflows and Mongo memory (`Projects/Atlas/Oji`, `Oji_2`).
- OjiDB — MongoDB schema for Oji’s cognition/memory (blueprints and collection JSON under `Shared_Resources/Mongodb` and `Projects/Atlas/Oji*/config`).
- Oracle — Chat surface in the Flutter app (`OracleChat` in `atlas_dashboard/lib/main.dart`).
- CommandController/MainShell — Dual-control navigation and command bus in the Flutter shell (`atlas_dashboard/lib/main.dart`).
- Reflection / Query Analysis / Response Agents — n8n agent workflows for understanding, responding, and self-learning (`Projects/Atlas/Oji*`).
- Shared Drive / Dashboard — Dashboard tab themed as shared workspace using `Shared_Drive_Theme.png` (`atlas_dashboard/lib/main.dart`).
- Markets / Trading stream — WebSocket-driven placeholder for market telemetry (`backend/app/routers/trading.py`).

## 4. Tech Stack & Tooling
- **Languages:** Dart, Python 3.11, JavaScript/HTML/CSS; JSON configs for n8n/Mongo.
- **Frameworks/Libraries:** Flutter (Material), FastAPI, Motor/PyMongo, CCXT, OpenAI SDK, xterm + flutter_pty, webview_flutter, Google Fonts.
- **Build / Package:** Flutter SDK, pip/venv, Docker/Docker Compose.
- **CI/CD:** Legacy GitHub Actions FTP deploy workflow (`Projects/_review_needed/.github/workflows/deploy.yml`).
- **External Services / Integrations:** MongoDB Atlas, OpenAI API, n8n webhook endpoint, WebSockets, potential TradingView embedding.

## 5. Main Logic Centers ("Brains" of the App)
- `atlas_dashboard/lib/main.dart` — Houses the CommandController and MainShell that unify navigation, command parsing (`/nav`, `/panic`), theming, and the four primary panes (Oracle chat, Terminal logs, Dashboard cards, Markets placeholder). OracleChat simulates AI replies and forwards slash-commands to the shell; TerminalPane shows stylized logs; DashboardPane overlays status cards on a shared-drive background; MarketsPane is ready for a webview/trading feed.
- `atlas_dashboard/lib/theme/atlas_theme_data.dart` — Encodes the Atlas design language (palette, gradients, radii, typography, glass/grain effects) so screens can mirror the reference CSS; also defines light/dark ThemeData and reusable surface helpers.
- FastAPI backend (`backend/app/main.py` + routers) — Creates the API surface with permissive CORS, health checks, `/chat` (echo stub reserving DB access) and `/trading/ws` streaming random bot telemetry over WebSockets. `database.py` centralizes Mongo client setup via env vars for future persistence and vector search wiring.
- n8n agent workflows (`Projects/Atlas/Oji*`) — JSON exports for the multi-agent Oji pipeline: Query Analysis → Knowledge/Tooling RAG → Response Agent → Reflection (async). Prompt files and Mongo blueprints live alongside, providing import-ready assets to stand up the assistant with memory and self-improvement.
- Data/memory schemata (`Shared_Resources/Mongodb`) — Defines OjiDB collections for identity, memories (semantic/knowledge/procedural/short-term), emotions, projects/tasks, and vector slots plus indexes, enabling consistent persistence across backend and workflow tooling.
