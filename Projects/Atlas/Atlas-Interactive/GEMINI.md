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

### Logging

The `start_dev.sh` script is configured to capture logs for both the backend and frontend in the `backend/logs` directory.

*   `backend.log`: Contains logs for the FastAPI backend.
*   `frontend.log`: Contains logs for the Flutter frontend.

The logging for the backend is configured in `app/main.py`. The logging for the frontend is configured in `app/view/crypto_view.dart`.

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

## Known Issues

### Bitget "Classic Account" Incompatibility

The trading bot is currently not functional due to an incompatibility with Bitget's "Classic Account" type. The investigation has revealed the following issues:

1.  **Bitget API v1 Decommissioned**: The `ccxt` library, even after being updated to the latest version (`4.5.27`), appears to still be making some calls to the Bitget v1 API. This results in the following error:
    ```
    ccxt.base.errors.BadSymbol: bitget {"code":"30032","msg":"The V1 API has been decommissioned. Please migrate to a newer version."}
    ```
2.  **Classic Account Incompatibility**: When attempting to use the Bitget v2/v3 API with a "Classic Account", the API returns the following error:
    ```
    {"code":"40084","msg":"You are in Classic Account mode, and the Unified Account API is not supported at this time"}
    ```
3.  **Lack of `ccxt` documentation for Classic Accounts**: There is no clear documentation on how to configure `ccxt` to work with Bitget "Classic Accounts".

**Recommendation:**

The recommended solution is to upgrade the Bitget account from a "Classic Account" to a "Unified Account". This will ensure compatibility with the latest Bitget APIs and the `ccxt` library.

**Upgrade Instructions:**

You can find instructions on how to upgrade your account here: https://www.bitget.com/academy/en/article/An-Introduction-to-Bitget-s-Unified-Trading-Account
