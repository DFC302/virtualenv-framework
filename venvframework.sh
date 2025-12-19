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
    local name=""
    local python_cmd="python3"

    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --python)
                if [ -z "$2" ]; then
                    echo "Error: --python requires a Python executable argument"
                    echo "Usage: virtualenv-create <name> [--python <python_executable>]"
                    return 1
                fi
                python_cmd="$2"
                shift 2
                ;;
            *)
                if [ -z "$name" ]; then
                    name="$1"
                    shift
                else
                    echo "Error: Unexpected argument '$1'"
                    echo "Usage: virtualenv-create <name> [--python <python_executable>]"
                    return 1
                fi
                ;;
        esac
    done

    # Check if name argument is provided
    if [ -z "$name" ]; then
        echo "Error: Missing virtual environment name"
        echo "Usage: virtualenv-create <name> [--python <python_executable>]"
        return 1
    fi

    # Check if Python executable exists
    if ! command -v "$python_cmd" >/dev/null 2>&1; then
        echo "Error: Python executable '$python_cmd' not found"
        echo "Available Python versions:"
        ls -1 /usr/bin/python* 2>/dev/null | grep -E 'python[0-9.]*$' | sed 's/^/  /'
        return 1
    fi

    # Check if venv already exists
    if virtualenv-exists "$name"; then
        echo "Error: Virtual environment '$name' already exists"
        return 1
    fi

    # Create the virtual environment
    "$python_cmd" -m venv "$VENVS_DIR/$name"

    if [ $? -eq 0 ]; then
        local version=$("$VENVS_DIR/$name/bin/python" --version 2>&1)
        echo "Created virtual environment '$name' with $version at $VENVS_DIR/$name"
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

# Switch from current virtual environment to another
virtualenv-switch() {
    local name="$1"

    # Check if name argument is provided
    if [ -z "$name" ]; then
        echo "Error: Missing virtual environment name"
        echo "Usage: virtualenv-switch <name>"
        return 1
    fi

    # Check if target venv exists
    if ! virtualenv-exists "$name"; then
        echo "Error: Virtual environment '$name' not found"
        return 1
    fi

    # Deactivate current venv if one is active
    if [ -n "$VIRTUAL_ENV" ]; then
        local current_venv=$(basename "$VIRTUAL_ENV")
        if type deactivate >/dev/null 2>&1; then
            deactivate
            echo "Deactivated virtual environment '$current_venv'"
        fi
    fi

    # Activate the new virtual environment
    source "$VENVS_DIR/$name/bin/activate"

    if [ $? -eq 0 ]; then
        echo "Activated virtual environment '$name'"
        return 0
    else
        echo "Error: Failed to activate virtual environment '$name'"
        return 1
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
        printf "Delete virtual environment '$name'? (y/n) "
        read -r REPLY
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

# Delete all virtual environments
virtualenv-delete-all() {
    # Check if venvs directory has any subdirectories
    if [ ! -d "$VENVS_DIR" ] || [ -z "$(ls -A "$VENVS_DIR" 2>/dev/null)" ]; then
        echo "No virtual environments found in $VENVS_DIR"
        return 0
    fi

    # Count virtual environments
    local venv_count=0
    for venv in "$VENVS_DIR"/*; do
        if [ -d "$venv" ]; then
            venv_count=$((venv_count + 1))
        fi
    done

    # Check if any venv is currently active
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "Error: A virtual environment is currently active. Deactivate first."
        return 1
    fi

    # Display warning and prompt for confirmation (--force flag is ignored)
    echo "WARNING: This will delete ALL $venv_count virtual environment(s):"
    for venv in "$VENVS_DIR"/*; do
        if [ -d "$venv" ]; then
            echo "  - $(basename "$venv")"
        fi
    done
    echo ""
    printf "Are you sure you want to delete all virtual environments? (Y/N) "
    read -r REPLY
    echo

    # Check response (case insensitive)
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deletion cancelled"
        return 0
    fi

    # Delete all virtual environments
    local deleted_count=0
    local failed_count=0
    for venv in "$VENVS_DIR"/*; do
        if [ -d "$venv" ]; then
            local venv_name=$(basename "$venv")
            rm -rf "$venv"
            if [ $? -eq 0 ]; then
                echo "Deleted virtual environment '$venv_name'"
                deleted_count=$((deleted_count + 1))
            else
                echo "Error: Failed to delete virtual environment '$venv_name'"
                failed_count=$((failed_count + 1))
            fi
        fi
    done

    # Summary
    echo ""
    echo "Deletion complete: $deleted_count deleted, $failed_count failed"
    return 0
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

# List available Python versions that can create virtual environments
virtualenv-python-versions() {
    # Enable null_glob for zsh compatibility (ignored in bash)
    # This prevents errors when python* glob doesn't match any files
    if [ -n "$ZSH_VERSION" ]; then
        setopt local_options null_glob
    fi

    # Check if PATH is set
    if [ -z "$PATH" ]; then
        echo "Error: PATH environment variable is not set"
        return 1
    fi

    # Store found Python executables
    local pythons=()
    local seen=()

    # Search through PATH directories
    # Use process substitution with tr for bash/zsh compatibility
    while IFS= read -r dir; do
        # Skip if directory doesn't exist
        [ ! -d "$dir" ] && continue

        # Find all python* executables in this directory
        for python_path in "$dir"/python*; do
            # Skip if not a file or not executable
            [ ! -f "$python_path" ] && continue
            [ ! -x "$python_path" ] && continue

            # Get just the executable name
            local python_name=$(basename "$python_path")

            # Skip if already seen (deduplication)
            local already_seen=false
            for seen_name in "${seen[@]}"; do
                if [ "$seen_name" = "$python_name" ]; then
                    already_seen=true
                    break
                fi
            done
            [ "$already_seen" = true ] && continue

            # Check if this Python has venv module
            if "$python_path" -m venv --help >/dev/null 2>&1; then
                pythons+=("$python_name")
                seen+=("$python_name")
            fi
        done
    done < <(echo "$PATH" | tr ':' '\n')

    # Check if any Python versions found
    if [ ${#pythons[@]} -eq 0 ]; then
        echo "No Python installations found in PATH"
        echo "Install Python or check your PATH environment variable"
        return 0
    fi

    # Sort Python versions intelligently (newest first)
    # Use version sort if available, otherwise regular sort
    local sorted_pythons
    if command -v sort >/dev/null 2>&1; then
        sorted_pythons=($(printf '%s\n' "${pythons[@]}" | sort -V -r 2>/dev/null || printf '%s\n' "${pythons[@]}" | sort -r))
    else
        sorted_pythons=("${pythons[@]}")
    fi

    # Display results
    echo "Available Python versions:"
    for python in "${sorted_pythons[@]}"; do
        echo "  $python"
    done
    echo ""
    echo "Use with: virtualenv-create <name> --python <version>"
}

# Display help information
virtualenv-help() {
    cat << 'EOF'
Python Virtual Environment Framework

Commands:
  virtualenv-create <name> [--python <executable>]
                                        Create a new virtual environment
                                        Use --python to specify Python version (e.g., python3.10)
  virtualenv-activate <name>            Activate a virtual environment
  virtualenv-switch <name>              Switch to a different virtual environment
  virtualenv-deactivate                 Deactivate current virtual environment
  virtualenv-delete <name> [--force]    Delete a virtual environment
  virtualenv-delete-all                 Delete all virtual environments (requires confirmation)
  virtualenv-list                       List all virtual environments
  virtualenv-info <name>                Show details about a virtual environment
  virtualenv-python-versions            List available Python versions
  virtualenv-help                       Show this help message

Storage location: ~/.venvs/

Examples:
  virtualenv-create myproject
  virtualenv-create myproject --python python3.13
  virtualenv-create legacy --python python2.7
  virtualenv-activate myproject
  virtualenv-switch otherproject
  virtualenv-deactivate
  virtualenv-delete myproject
  virtualenv-delete myproject --force
  virtualenv-delete-all
  virtualenv-list
  virtualenv-info myproject
  virtualenv-python-versions

Installation:
  Add this line to your .bashrc or .zshrc:
    source /path/to/venvframework.sh
EOF
}
