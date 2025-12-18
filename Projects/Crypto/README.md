# Crypto Trading

Workspace for the crypto trading initiative listed in the MongoDB exports.

## Structure
- `docs/` — Imported materials and new research notes (currently contains the original empty README placeholder).
- `strategies/` — Add algorithmic or discretionary playbooks here.
- `data/` — Use for market data samples, backtests, and configuration files.

## Setup
1. Create a Python virtual environment for analytics and install your dependencies (e.g., `pip install -r requirements.txt`).
2. Store secrets (API keys, webhooks) in a `.env` file and keep it out of version control.
3. When connecting to Atlas data, reference the schemas in `../../Shared_Resources/Mongodb/` to align entities across projects.

## Next steps
- Add notebooks for signal research.
- Wire up a task runner (e.g., `make`, `nox`, or `invoke`) as the codebase grows.
