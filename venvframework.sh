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
    if [ ! -d "$VENVS_DIR" ] || [ -z "$(ls -A "$VENVS_DIR" 2>/dev/null)" ]; then
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

# Show detailed information about a virtual environment
virtualenv-info() {
    local name="$1"

    # Check if name argument is provided
    if [ -z "$name" ]; then
        echo "Error: Missing virtual environment name"
        echo "Usage: virtualenv-info <name>"
        return 1
    fi

    # Check if venv exists
    if ! virtualenv-exists "$name"; then
        echo "Error: Virtual environment '$name' not found"
        return 1
    fi

    local venv_path="$VENVS_DIR/$name"

    # Display information
    echo "Virtual Environment: $name"
    echo "Location: $venv_path"

    # Get Python version
    local python_version=$("$venv_path/bin/python" --version 2>&1)
    echo "Python Version: $python_version"

    # Get created date
    if [ -d "$venv_path" ]; then
        local created_date=$(stat -c %y "$venv_path" 2>/dev/null | cut -d' ' -f1)
        if [ -z "$created_date" ]; then
            # macOS fallback
            created_date=$(stat -f %Sm -t %Y-%m-%d "$venv_path" 2>/dev/null)
        fi
        echo "Created: $created_date"
    fi

    # Get package count
    local package_count=$("$venv_path/bin/pip" freeze 2>/dev/null | wc -l | tr -d ' ')
    echo "Installed Packages: $package_count"
}

# Display help information
virtualenv-help() {
    cat << 'EOF'
Python Virtual Environment Framework

Commands:
  virtualenv-create <name>              Create a new virtual environment
  virtualenv-activate <name>            Activate a virtual environment
  virtualenv-deactivate                 Deactivate current virtual environment
  virtualenv-delete <name> [--force]    Delete a virtual environment
  virtualenv-list                       List all virtual environments
  virtualenv-info <name>                Show details about a virtual environment
  virtualenv-help                       Show this help message

Storage location: ~/.venvs/

Examples:
  virtualenv-create myproject
  virtualenv-activate myproject
  virtualenv-deactivate
  virtualenv-delete myproject
  virtualenv-delete myproject --force
  virtualenv-list
  virtualenv-info myproject

Installation:
  Add this line to your .bashrc or .zshrc:
    source /path/to/venvframework.sh
EOF
}
