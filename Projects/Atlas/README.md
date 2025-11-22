# Atlas Interactive

VR-centric Atlas experience workspace combining UI assets, prompts, and research materials referenced in the MongoDB project catalog.

## Structure
- `ui/oji_chat_ui/Website/` — Static HTML/CSS/JS chat interface for Atlas–Oji interactions.
- `docs/personality/` — Personality configuration artifacts and prompts.
- `docs/query_categorisation/` — Early categorisation notes for emotional states and activities.
- `tests/` — Legacy test artefacts preserved from the original drop.

## Setup
1. Clone the repo and install a simple static server (Python is fine).
2. Serve the chat UI from the project root:
   ```bash
   cd Projects/Atlas/ui/oji_chat_ui/Website
   python -m http.server 8080
   ```
3. Open `http://localhost:8080/index.html` to explore the interface.

## Data
Shared MongoDB exports (OjiDB architecture, project definitions, and memory collections) live in `../../Shared_Resources/Mongodb/` for reference when wiring backend services.

## Contributing
Add new Atlas features under feature-specific folders (e.g., `ui/`, `services/`, `data/`), and document changes in this README to keep the workspace navigable.
