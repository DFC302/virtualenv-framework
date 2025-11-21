#!/bin/bash
# Python Virtual Environment Framework
# Manages virtual environments in ~/.venvs/

# Initialize venvs directory on script load
VENVS_DIR="$HOME/.venvs"

if [ ! -d "$VENVS_DIR" ]; then
    mkdir -p "$VENVS_DIR" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Created virtual environments directory at $VENVS_DIR"
    else
        echo "Warning: Failed to create $VENVS_DIR - check permissions"
    fi
fi

# Helper function to check if a virtual environment exists
virtualenv-exists() {
    local name="$1"
    if [ -z "$name" ]; then
        return 1
    fi
    [ -d "$VENVS_DIR/$name" ] && [ -f "$VENVS_DIR/$name/bin/activate" ]
}
