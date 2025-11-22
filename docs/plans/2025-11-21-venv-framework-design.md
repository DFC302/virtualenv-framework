# Python Virtual Environment Framework Design

## Overview

A bash shell function framework for managing Python virtual environments with centralized storage at `~/.venvs/`.

## Architecture

**File Structure:**
- Main script: `venvframework.sh` (bash functions to source)
- Storage location: `~/.venvs/` (created automatically on script load)
- Each venv stored as: `~/.venvs/<venv-name>/`

**Installation:**
Users add to their `.bashrc` or `.zshrc`:
```bash
source /path/to/venvframework.sh
```

**Initialization:**
- When sourced, script checks for `~/.venvs/` directory
- Creates it with `mkdir -p ~/.venvs/` if it doesn't exist
- Shows warning if creation fails, but doesn't block script loading

## Commands

### virtualenv-create <name>
- Creates venv at `~/.venvs/<name>` using `python3 -m venv`
- Checks if name already exists first (error if it does)
- Reports success with path to created venv
- Uses system default python3

**Example:**
```bash
virtualenv-create myproject
```

### virtualenv-activate <name>
- Checks if `~/.venvs/<name>` exists (error if not)
- Sources the activation script: `~/.venvs/<name>/bin/activate`
- Shell prompt updates to show active venv

**Example:**
```bash
virtualenv-activate myproject
```

### virtualenv-deactivate
- Calls the `deactivate` function (provided by venv itself)
- No arguments needed - deactivates current venv
- Safe to call even if no venv is active

**Example:**
```bash
virtualenv-deactivate
```

### virtualenv-delete <name> [--force]
- Without `--force`: Prompts "Delete virtual environment 'name'? (y/n)"
- With `--force`: Deletes immediately without confirmation
- Checks if venv exists first (error if not)
- Cannot delete currently active venv (safety check)

**Examples:**
```bash
virtualenv-delete myproject
virtualenv-delete myproject --force
```

### virtualenv-list
- Lists all virtual environments in `~/.venvs/`
- Shows venv names, one per line
- Indicates which one is currently active with `*` marker
- If no venvs exist, prints: "No virtual environments found in ~/.venvs/"

**Example:**
```bash
virtualenv-list
```

### virtualenv-info <name>
- Shows detailed information about a specific venv:
  - Python version (from `python --version`)
  - Location path (`~/.venvs/<name>`)
  - Installed packages count (from `pip list`)
  - Created date (from directory timestamp)
- Checks if venv exists first (error if not)

**Example:**
```bash
virtualenv-info myproject
```

### virtualenv-help
- Displays usage information for all commands
- Shows examples and storage location

**Example:**
```bash
virtualenv-help
```

## Error Handling

**Error Cases:**
- Command called without required argument → Show usage message
- Venv already exists (create) → "Virtual environment 'name' already exists"
- Venv doesn't exist (activate/delete/info) → "Virtual environment 'name' not found"
- Trying to delete active venv → "Cannot delete active virtual environment. Deactivate first."
- `~/.venvs/` not writable → Warning on script load

**Success Messages:**
- Create: "Created virtual environment 'name' at ~/.venvs/name"
- Activate: "Activated virtual environment 'name'"
- Deactivate: "Deactivated virtual environment"
- Delete: "Deleted virtual environment 'name'"

**Output Format:**
- Plain text only (no colors)
- Ensures compatibility across all terminals

## Technical Implementation

**Internal Helper:**
- `virtualenv-exists <name>` - Returns 0 if venv exists, 1 if not
- Used internally by other commands for validation
- Can be used standalone for scripting

**Compatibility:**
- Bash and Zsh compatible
- Uses standard POSIX commands where possible
- Relies on Python 3's built-in venv module

## Design Decisions

1. **Centralized storage** - All venvs in `~/.venvs/` for clean project directories and access from anywhere
2. **Full command names** - `virtualenv-*` prefix prevents conflicts with other tools
3. **Plain text output** - Maximum compatibility across terminal environments
4. **Immediate initialization** - Create `~/.venvs/` on script load to fail fast
5. **System Python only** - Use default `python3` for simplicity
6. **Delete confirmation** - Default to safe (confirm), allow `--force` for automation
