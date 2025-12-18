Atlas project assets live here. The runnable Atlas-Interactive app stack lives under `Projects/Atlas/Atlas-Interactive/`; see root `README.md` and `docs/project_digest_for_chatgpt.md`.

- Atlas-Interactive app (Flutter + FastAPI + static UI): `Atlas-Interactive/`
- Oji agents and prompts: `Oji/`, `Oji_2/`
- UI prototypes (historical copy): `ui/oji_chat_ui/` (canonical static UI is under `Atlas-Interactive/references/atlas_website_design/`)
- Additional docs and tests: `docs/`, `tests/`

Operational notes:
- n8n workflow exports live at repo root: `Oji_N8N_Backend.json` (current) and `Oji_Patch.json` (guardrails to prevent `session_id`-null collisions).
- Session/id + ChatHistories contract: `docs/chat_histories_contract.md`.
- Mongo index migration guide: `mongodb/chat_histories_index_migration.md`.
