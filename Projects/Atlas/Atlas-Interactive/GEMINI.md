# Atlas Project

This document provides a comprehensive overview of the Atlas project, its structure, and how to run it.

## Project Overview

The Atlas project is an interactive, AI-powered dashboard. It is a "mission control" style interface with a focus on chat functionality. The application is built with Flutter for the frontend, and a Python FastAPI service for the backend, leveraging a MongoDB Atlas cluster for data persistence and AI memory. For a detailed architectural overview of the MongoDB databases, refer to `mongodb/layout.md`.

The project is divided into several key components:

*   **atlas_dashboard:** The main application stack, which is a Flutter-based frontend.
*   **backend:** A Python FastAPI service for the backend.
*   **references/atlas_website_design/:** Canonical static Atlas/Oji UI (HTML/CSS/JS).

### Technologies Used

*   **Frontend (atlas_dashboard):**
    *   Flutter
    *   Dependencies: `google_fonts`, `xterm`, `flutter_pty`, `http`, `webview_flutter`
*   **Backend:**
        *   Python
        *   FastAPI
        *   MongoDB Atlas (via `motor` and `pymongo`)
        *   Key databases: `OjiDB` (main AI memory and project management), `Oji-AI` (prototype/legacy)
        *   `websockets` for real-time communication
        *   `ccxt` for cryptocurrency trading
        *   `openai` for chat functionality
## Building and Running

### Development Shortcut

To start both the frontend and backend services with a single command, you can use the `start_dev.sh` script.

1.  Navigate to the `Atlas-Interactive` directory.
2.  Run the script: `./start_dev.sh`

This will open two new terminal windows: one for the backend and one for the frontend.

### Frontend (Flutter)

To run the Flutter frontend:

1.  Navigate to the `atlas_dashboard` directory.
2.  Install dependencies: `flutter pub get`
3.  Run the application on macOS: `flutter run -d macos`
4.  Run the application on Chrome: `flutter run -d chrome`

### Backend (Python/FastAPI)

To run the backend:

1.  Navigate to the `backend` directory.
2.  Create a virtual environment: `python -m venv venv`
3.  Activate the virtual environment: `source venv/bin/activate`
4.  Install dependencies: `pip install -r requirements.txt`
5.  Run the application: `uvicorn app.main:app --reload`

### Docker

A `docker-compose.yml` file is provided to orchestrate the backend and a MongoDB instance for local development.

To run with Docker:

1.  Navigate to the project root.
2.  Run docker-compose: `docker-compose up`

## Development Conventions

*   All changes to the Atlas-Interactive application should be kept within this directory to maintain a single source of truth.
*   The project uses a Flutter application for the main interface and a FastAPI backend for chat, AI memory, trading, and other services, utilizing MongoDB Atlas. For detailed MongoDB architecture, refer to `mongodb/layout.md`.
