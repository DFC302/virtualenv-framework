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

# Deactivate the current virtual environment
virtualenv-deactivate() {
    # Check if deactivate function exists (means a venv is active)
    if type deactivate >/dev/null 2>&1; then
        deactivate
        echo "Deactivated virtual environment"
        return 0
    else
        echo "No virtual environment is currently active"
        return 0
    fi
}

# Delete a virtual environment
virtualenv-delete() {
    local name="$1"
    local force=false

    # Check for --force flag
    if [ "$2" = "--force" ] || [ "$1" = "--force" ]; then
        force=true
        if [ "$1" = "--force" ]; then
            name="$2"
        fi
    fi

    # Check if name argument is provided
    if [ -z "$name" ]; then
        echo "Error: Missing virtual environment name"
        echo "Usage: virtualenv-delete <name> [--force]"
        return 1
    fi

    # Check if venv exists
    if ! virtualenv-exists "$name"; then
        echo "Error: Virtual environment '$name' not found"
        return 1
    fi

    # Check if trying to delete active venv
    if [ -n "$VIRTUAL_ENV" ] && [ "$VIRTUAL_ENV" = "$VENVS_DIR/$name" ]; then
        echo "Error: Cannot delete active virtual environment. Deactivate first."
        return 1
    fi

    # Prompt for confirmation unless --force is used
    if [ "$force" = false ]; then
        read -p "Delete virtual environment '$name'? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Deletion cancelled"
            return 0
        fi
    fi

    # Delete the virtual environment
    rm -rf "$VENVS_DIR/$name"

    if [ $? -eq 0 ]; then
        echo "Deleted virtual environment '$name'"
        return 0
    else
        echo "Error: Failed to delete virtual environment '$name'"
        return 1
    fi
}

# List all virtual environments
virtualenv-list() {
    # Check if venvs directory has any subdirectories
    if [ ! -d "$VENVS_DIR" ] || [ -z "$(ls -A $VENVS_DIR 2>/dev/null)" ]; then
        echo "No virtual environments found in $VENVS_DIR"
        return 0
    fi

    # List all venvs, marking the active one
    for venv in "$VENVS_DIR"/*; do
        if [ -d "$venv" ]; then
            local venv_name=$(basename "$venv")

            # Check if this venv is currently active
            if [ -n "$VIRTUAL_ENV" ] && [ "$VIRTUAL_ENV" = "$venv" ]; then
                echo "* $venv_name (active)"
            else
                echo "  $venv_name"
            fi
        fi
    done
}
