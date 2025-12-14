#!/bin/bash

# Get the absolute path of the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Start the backend
osascript -e "tell app \"Terminal\" to do script \"cd '$SCRIPT_DIR/backend' && source .venv/bin/activate && uvicorn app.main:app --reload\""

# Start the frontend
osascript -e "tell app \"Terminal\" to do script \"cd '$SCRIPT_DIR/atlas_dashboard' && flutter run -d macos\""
