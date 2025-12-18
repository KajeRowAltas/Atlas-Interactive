# Atlas Project

This document provides a comprehensive overview of the Atlas project, its structure, and how to run it.

## Project Overview

The Atlas project is an interactive, AI-powered dashboard. It is a "mission control" style interface with a focus on chat functionality. The application is built with Flutter for the frontend, and a Python FastAPI service for the backend, which interacts with a MongoDB Atlas cluster for data persistence and AI memory.

The project is divided into several key components:

*   **Atlas-Interactive:** The main application stack, which is a Flutter-based frontend.
*   **UI Prototypes:** The `ui/` directory contains historical UI prototypes, with the canonical static UI located in `Atlas-Interactive/references/atlas_website_design/`.

### Technologies Used

*   **Frontend (Atlas-Interactive/atlas_dashboard):**
        *   Flutter
        *   Dependencies: `http`, `webview_flutter`, `uuid`
    *   **Backend (Atlas-Interactive/backend):**
        *   Python FastAPI
        *   MongoDB Atlas (for data persistence and AI memory)
        *   Key databases: `OjiDB` (main), `Oji-AI` (prototype/legacy)
## Building and Running

### Frontend (Flutter)

To run the Flutter frontend:

1.  Navigate to the `Atlas-Interactive/atlas_dashboard` directory.
2.  Install dependencies: `flutter pub get`
3.  Run the application on macOS: `flutter run -d macos`
4.  Run the application on Chrome: `flutter run -d chrome`

## Development Conventions

*   All changes to the Atlas-Interactive application should be kept within the `Atlas-Interactive` directory to maintain a single source of truth.
*   The project uses a Flutter application for the main interface, and a FastAPI backend service (Python) for chat, AI memory, and other functionalities, leveraging MongoDB Atlas. For details on the MongoDB architecture, refer to `mongodb/layout.md`.
*   The `docs/` directory contains additional documentation, which should be consulted for more in-depth information.