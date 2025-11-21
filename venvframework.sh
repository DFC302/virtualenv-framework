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

# Create a new virtual environment
virtualenv-create() {
    local name="$1"

    # Check if name argument is provided
    if [ -z "$name" ]; then
        echo "Error: Missing virtual environment name"
        echo "Usage: virtualenv-create <name>"
        return 1
    fi

    # Check if venv already exists
    if virtualenv-exists "$name"; then
        echo "Error: Virtual environment '$name' already exists"
        return 1
    fi

    # Create the virtual environment
    python3 -m venv "$VENVS_DIR/$name"

    if [ $? -eq 0 ]; then
        echo "Created virtual environment '$name' at $VENVS_DIR/$name"
        return 0
    else
        echo "Error: Failed to create virtual environment '$name'"
        return 1
    fi
}

# Activate a virtual environment
virtualenv-activate() {
    local name="$1"

    # Check if name argument is provided
    if [ -z "$name" ]; then
        echo "Error: Missing virtual environment name"
        echo "Usage: virtualenv-activate <name>"
        return 1
    fi

    # Check if venv exists
    if ! virtualenv-exists "$name"; then
        echo "Error: Virtual environment '$name' not found"
        return 1
    fi

    # Activate the virtual environment
    source "$VENVS_DIR/$name/bin/activate"

    if [ $? -eq 0 ]; then
        echo "Activated virtual environment '$name'"
        return 0
    else
        echo "Error: Failed to activate virtual environment '$name'"
        return 1
    fi
}
