# Virtual Environment Framework Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a bash shell function framework for managing Python virtual environments with centralized storage at `~/.venvs/`.

**Architecture:** Single bash script (`venvframework.sh`) containing 7 shell functions that users source into their shell. All virtual environments stored centrally in `~/.venvs/` directory. Functions handle creation, activation, deactivation, deletion, listing, info display, and help.

**Tech Stack:** Bash shell scripting, Python 3 venv module, standard Unix utilities (mkdir, rm, ls)

---

## Task 1: Create Basic Script Structure with Initialization

**Files:**
- Create: `venvframework.sh`

**Step 1: Create the script file with header and initialization**

Create `venvframework.sh` with:

```bash
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
```

**Step 2: Test initialization**

Run:
```bash
rm -rf ~/.venvs
source venvframework.sh
```

Expected output: "Created virtual environments directory at /home/vailsec/.venvs"

Verify:
```bash
ls -ld ~/.venvs
```

Expected: Directory exists with proper permissions

**Step 3: Test initialization when directory exists**

Run:
```bash
source venvframework.sh
```

Expected: No output (directory already exists, silent success)

**Step 4: Commit**

```bash
git init
git add venvframework.sh
git commit -m "feat: add script initialization and venvs directory creation"
```

---

## Task 2: Implement virtualenv-exists Helper Function

**Files:**
- Modify: `venvframework.sh`

**Step 1: Add virtualenv-exists function**

Append to `venvframework.sh`:

```bash

# Helper function to check if a virtual environment exists
virtualenv-exists() {
    local name="$1"
    if [ -z "$name" ]; then
        return 1
    fi
    [ -d "$VENVS_DIR/$name" ] && [ -f "$VENVS_DIR/$name/bin/activate" ]
}
```

**Step 2: Test virtualenv-exists with non-existent venv**

Run:
```bash
source venvframework.sh
virtualenv-exists testvenv
echo $?
```

Expected output: `1` (failure - venv doesn't exist)

**Step 3: Test virtualenv-exists with existing venv**

Create a test venv manually:
```bash
python3 -m venv ~/.venvs/testvenv
virtualenv-exists testvenv
echo $?
```

Expected output: `0` (success - venv exists)

Clean up:
```bash
rm -rf ~/.venvs/testvenv
```

**Step 4: Commit**

```bash
git add venvframework.sh
git commit -m "feat: add virtualenv-exists helper function"
```

---

## Task 3: Implement virtualenv-create Command

**Files:**
- Modify: `venvframework.sh`

**Step 1: Add virtualenv-create function**

Append to `venvframework.sh`:

```bash

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
```

**Step 2: Test create without arguments**

Run:
```bash
source venvframework.sh
virtualenv-create
```

Expected output:
```
Error: Missing virtual environment name
Usage: virtualenv-create <name>
```

**Step 3: Test create with new venv name**

Run:
```bash
virtualenv-create testenv
```

Expected output: `Created virtual environment 'testenv' at /home/vailsec/.venvs/testenv`

Verify:
```bash
ls ~/.venvs/testenv/bin/activate
```

Expected: File exists

**Step 4: Test create with existing venv name**

Run:
```bash
virtualenv-create testenv
```

Expected output: `Error: Virtual environment 'testenv' already exists`

**Step 5: Clean up and commit**

```bash
rm -rf ~/.venvs/testenv
git add venvframework.sh
git commit -m "feat: add virtualenv-create command"
```

---

## Task 4: Implement virtualenv-activate Command

**Files:**
- Modify: `venvframework.sh`

**Step 1: Add virtualenv-activate function**

Append to `venvframework.sh`:

```bash

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
```

**Step 2: Test activate without arguments**

Run:
```bash
source venvframework.sh
virtualenv-activate
```

Expected output:
```
Error: Missing virtual environment name
Usage: virtualenv-activate <name>
```

**Step 3: Test activate with non-existent venv**

Run:
```bash
virtualenv-activate nonexistent
```

Expected output: `Error: Virtual environment 'nonexistent' not found`

**Step 4: Test activate with existing venv**

Run:
```bash
virtualenv-create testenv
virtualenv-activate testenv
```

Expected output: `Activated virtual environment 'testenv'`

Verify:
```bash
which python
```

Expected: Shows path like `/home/vailsec/.venvs/testenv/bin/python`

**Step 5: Deactivate and commit**

```bash
deactivate
git add venvframework.sh
git commit -m "feat: add virtualenv-activate command"
```

---

## Task 5: Implement virtualenv-deactivate Command

**Files:**
- Modify: `venvframework.sh`

**Step 1: Add virtualenv-deactivate function**

Append to `venvframework.sh`:

```bash

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
```

**Step 2: Test deactivate with no active venv**

Run:
```bash
source venvframework.sh
virtualenv-deactivate
```

Expected output: `No virtual environment is currently active`

**Step 3: Test deactivate with active venv**

Run:
```bash
virtualenv-activate testenv
virtualenv-deactivate
```

Expected output: `Deactivated virtual environment`

Verify:
```bash
which python
```

Expected: Shows system python, not venv python

**Step 4: Commit**

```bash
git add venvframework.sh
git commit -m "feat: add virtualenv-deactivate command"
```

---

## Task 6: Implement virtualenv-delete Command

**Files:**
- Modify: `venvframework.sh`

**Step 1: Add virtualenv-delete function**

Append to `venvframework.sh`:

```bash

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
```

**Step 2: Test delete without arguments**

Run:
```bash
source venvframework.sh
virtualenv-delete
```

Expected output:
```
Error: Missing virtual environment name
Usage: virtualenv-delete <name> [--force]
```

**Step 3: Test delete with non-existent venv**

Run:
```bash
virtualenv-delete nonexistent
```

Expected output: `Error: Virtual environment 'nonexistent' not found`

**Step 4: Test delete with active venv (should fail)**

Run:
```bash
virtualenv-activate testenv
virtualenv-delete testenv
```

Expected output: `Error: Cannot delete active virtual environment. Deactivate first.`

Deactivate:
```bash
virtualenv-deactivate
```

**Step 5: Test delete with confirmation (cancel)**

Run:
```bash
virtualenv-delete testenv
```

When prompted, type `n` and press Enter.

Expected output: `Deletion cancelled`

Verify venv still exists:
```bash
ls ~/.venvs/testenv
```

**Step 6: Test delete with --force flag**

Run:
```bash
virtualenv-delete testenv --force
```

Expected output: `Deleted virtual environment 'testenv'`

Verify venv is gone:
```bash
ls ~/.venvs/testenv
```

Expected: "No such file or directory"

**Step 7: Commit**

```bash
git add venvframework.sh
git commit -m "feat: add virtualenv-delete command with confirmation"
```

---

## Task 7: Implement virtualenv-list Command

**Files:**
- Modify: `venvframework.sh`

**Step 1: Add virtualenv-list function**

Append to `venvframework.sh`:

```bash

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
```

**Step 2: Test list with no venvs**

Run:
```bash
source venvframework.sh
rm -rf ~/.venvs/*
virtualenv-list
```

Expected output: `No virtual environments found in /home/vailsec/.venvs`

**Step 3: Test list with multiple venvs (none active)**

Run:
```bash
virtualenv-create env1
virtualenv-create env2
virtualenv-create env3
virtualenv-list
```

Expected output:
```
  env1
  env2
  env3
```

**Step 4: Test list with active venv**

Run:
```bash
virtualenv-activate env2
virtualenv-list
```

Expected output:
```
  env1
* env2 (active)
  env3
```

**Step 5: Clean up and commit**

```bash
virtualenv-deactivate
virtualenv-delete env1 --force
virtualenv-delete env2 --force
virtualenv-delete env3 --force
git add venvframework.sh
git commit -m "feat: add virtualenv-list command"
```

---

## Task 8: Implement virtualenv-info Command

**Files:**
- Modify: `venvframework.sh`

**Step 1: Add virtualenv-info function**

Append to `venvframework.sh`:

```bash

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
    local package_count=$("$venv_path/bin/pip" list 2>/dev/null | tail -n +3 | wc -l | tr -d ' ')
    echo "Installed Packages: $package_count"
}
```

**Step 2: Test info without arguments**

Run:
```bash
source venvframework.sh
virtualenv-info
```

Expected output:
```
Error: Missing virtual environment name
Usage: virtualenv-info <name>
```

**Step 3: Test info with non-existent venv**

Run:
```bash
virtualenv-info nonexistent
```

Expected output: `Error: Virtual environment 'nonexistent' not found`

**Step 4: Test info with existing venv**

Run:
```bash
virtualenv-create infotest
virtualenv-info infotest
```

Expected output (format):
```
Virtual Environment: infotest
Location: /home/vailsec/.venvs/infotest
Python Version: Python 3.x.x
Created: 2025-11-21
Installed Packages: 0
```

**Step 5: Test info with packages installed**

Run:
```bash
~/.venvs/infotest/bin/pip install requests >/dev/null 2>&1
virtualenv-info infotest
```

Expected: "Installed Packages" shows a number greater than 0

**Step 6: Clean up and commit**

```bash
virtualenv-delete infotest --force
git add venvframework.sh
git commit -m "feat: add virtualenv-info command"
```

---

## Task 9: Implement virtualenv-help Command

**Files:**
- Modify: `venvframework.sh`

**Step 1: Add virtualenv-help function**

Append to `venvframework.sh`:

```bash

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
```

**Step 2: Test help command**

Run:
```bash
source venvframework.sh
virtualenv-help
```

Expected output: Full help text with all commands, examples, and installation instructions

**Step 3: Commit**

```bash
git add venvframework.sh
git commit -m "feat: add virtualenv-help command"
```

---

## Task 10: Create README Documentation

**Files:**
- Create: `README.md`

**Step 1: Create README with installation and usage**

Create `README.md`:

```markdown
# Python Virtual Environment Framework

A bash shell function framework for easily managing Python virtual environments with centralized storage.

## Features

- Create, activate, deactivate, and delete virtual environments
- Centralized storage in `~/.venvs/` directory
- List all available virtual environments
- View detailed information about any virtual environment
- Safety confirmations for destructive operations
- Works from any directory

## Installation

1. Clone or download `venvframework.sh`

2. Add to your shell configuration:

   For bash (`~/.bashrc`):
   ```bash
   source /path/to/venvframework.sh
   ```

   For zsh (`~/.zshrc`):
   ```bash
   source /path/to/venvframework.sh
   ```

3. Reload your shell:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

## Usage

### Create a virtual environment
```bash
virtualenv-create myproject
```

### Activate a virtual environment
```bash
virtualenv-activate myproject
```

### Deactivate current virtual environment
```bash
virtualenv-deactivate
```

### List all virtual environments
```bash
virtualenv-list
```

### Show information about a virtual environment
```bash
virtualenv-info myproject
```

### Delete a virtual environment
```bash
# With confirmation prompt
virtualenv-delete myproject

# Without confirmation
virtualenv-delete myproject --force
```

### Show help
```bash
virtualenv-help
```

## Storage

All virtual environments are stored in `~/.venvs/`. This directory is automatically created when you source the script.

## Requirements

- Bash or Zsh shell
- Python 3.3+ (with venv module)

## License

Public Domain
```

**Step 2: Verify README renders correctly**

Run:
```bash
cat README.md
```

Expected: Properly formatted markdown content

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add README with installation and usage instructions"
```

---

## Task 11: Final Integration Testing

**Files:**
- None (testing only)

**Step 1: Clean environment and test full workflow**

Run:
```bash
# Clean up
rm -rf ~/.venvs
unset VIRTUAL_ENV

# Source the script
source venvframework.sh
```

Expected: Message about creating ~/.venvs directory

**Step 2: Test create → activate → deactivate → delete workflow**

Run:
```bash
virtualenv-create testproject
virtualenv-list
virtualenv-activate testproject
which python
virtualenv-info testproject
virtualenv-deactivate
virtualenv-delete testproject --force
virtualenv-list
```

Expected: All commands work without errors, proper output at each step

**Step 3: Test error cases**

Run:
```bash
# Try to activate non-existent venv
virtualenv-activate nonexistent

# Try to create duplicate
virtualenv-create testdup
virtualenv-create testdup

# Try to delete active venv
virtualenv-activate testdup
virtualenv-delete testdup

# Clean up
virtualenv-deactivate
virtualenv-delete testdup --force
```

Expected: Appropriate error messages for each case

**Step 4: Test help command**

Run:
```bash
virtualenv-help
```

Expected: Complete help text displays correctly

**Step 5: Final commit**

```bash
git add -A
git commit -m "test: verify full integration of all commands"
```

---

## Task 12: Create Installation Script (Optional Enhancement)

**Files:**
- Create: `install.sh`

**Step 1: Create installation helper script**

Create `install.sh`:

```bash
#!/bin/bash
# Installation helper for venvframework

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENVFRAMEWORK_PATH="$SCRIPT_DIR/venvframework.sh"

echo "Python Virtual Environment Framework - Installation"
echo "=================================================="
echo ""

# Detect shell
if [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    SHELL_NAME="bash"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    SHELL_NAME="zsh"
else
    echo "Unsupported shell. Please add the following line manually to your shell config:"
    echo "  source $VENVFRAMEWORK_PATH"
    exit 1
fi

echo "Detected shell: $SHELL_NAME"
echo "Config file: $SHELL_CONFIG"
echo ""

# Check if already installed
if grep -q "venvframework.sh" "$SHELL_CONFIG" 2>/dev/null; then
    echo "venvframework appears to already be installed in $SHELL_CONFIG"
    echo "Skipping installation."
    exit 0
fi

# Add to shell config
echo "# Python Virtual Environment Framework" >> "$SHELL_CONFIG"
echo "source $VENVFRAMEWORK_PATH" >> "$SHELL_CONFIG"

echo "Installation complete!"
echo ""
echo "To start using the framework, either:"
echo "  1. Restart your terminal, or"
echo "  2. Run: source $SHELL_CONFIG"
echo ""
echo "Then run 'virtualenv-help' to see available commands."
```

**Step 2: Make install script executable**

Run:
```bash
chmod +x install.sh
```

**Step 3: Test install script (dry run check)**

Run:
```bash
# Backup current config
cp ~/.bashrc ~/.bashrc.backup 2>/dev/null || true

# Check what would be added
tail -n 2 ~/.bashrc 2>/dev/null || echo "No bashrc yet"
```

**Step 4: Update README with install script**

Add to `README.md` after "## Installation":

```markdown
### Quick Install

Run the installation script:
```bash
./install.sh
```

This will automatically add venvframework to your shell configuration.

### Manual Install
```

**Step 5: Commit**

```bash
git add install.sh README.md
git commit -m "feat: add automated installation script"
```

---

## Completion Checklist

- [ ] Script initializes ~/.venvs directory on load
- [ ] virtualenv-exists helper works correctly
- [ ] virtualenv-create creates new venvs
- [ ] virtualenv-activate activates venvs
- [ ] virtualenv-deactivate deactivates current venv
- [ ] virtualenv-delete removes venvs with confirmation
- [ ] virtualenv-list shows all venvs with active marker
- [ ] virtualenv-info displays venv details
- [ ] virtualenv-help shows usage information
- [ ] README documents all features
- [ ] All error cases handled properly
- [ ] Full workflow tested end-to-end
- [ ] Installation script created (optional)

## Next Steps After Implementation

1. Test on different systems (Linux, macOS, WSL)
2. Test with both bash and zsh
3. Consider adding bash completion
4. Consider adding ability to specify Python version
5. Consider adding venv activation on cd (optional advanced feature)
