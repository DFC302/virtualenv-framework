# Python Virtual Environment Framework

A bash shell function framework for easily managing Python virtual environments with centralized storage.

## Features

- Create, activate, deactivate, and delete virtual environments
- Switch between virtual environments seamlessly
- Centralized storage in `~/.venvs/` directory
- List all available virtual environments
- List available Python versions for virtual environment creation
- View detailed information about any virtual environment
- Delete all virtual environments at once
- Safety confirmations for destructive operations
- Works from any directory

## Installation

### Quick Install

Run the installation script:
```bash
./install.sh
```

This will automatically add venvframework to your shell configuration.

### Manual Install

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

### Switch to a different virtual environment
```bash
virtualenv-switch otherproject
```

This will deactivate the current virtual environment (if any) and activate the specified one.

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

### List available Python versions
```bash
virtualenv-python-versions
```

This shows all Python installations in your PATH that can create virtual environments.

### Delete a virtual environment
```bash
# With confirmation prompt
virtualenv-delete myproject

# Without confirmation
virtualenv-delete myproject --force
```

### Delete all virtual environments
```bash
virtualenv-delete-all
```

This will delete all virtual environments with a safety confirmation. The `--force` flag does NOT work with this command - you must always confirm manually.

**Note:** You cannot delete virtual environments while one is active. Deactivate first.

### Show help
```bash
virtualenv-help
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `virtualenv-create <name>` | Create a new virtual environment |
| `virtualenv-activate <name>` | Activate a virtual environment |
| `virtualenv-switch <name>` | Switch to a different virtual environment |
| `virtualenv-deactivate` | Deactivate the current virtual environment |
| `virtualenv-delete <name> [--force]` | Delete a virtual environment |
| `virtualenv-delete-all` | Delete all virtual environments (always requires confirmation) |
| `virtualenv-list` | List all virtual environments |
| `virtualenv-info <name>` | Show detailed information about a virtual environment |
| `virtualenv-python-versions` | List available Python versions for virtual environments |
| `virtualenv-help` | Display help message |

## Storage

All virtual environments are stored in `~/.venvs/`. This directory is automatically created when you source the script.

## Requirements

- Bash or Zsh shell
- Python 3.3+ (with venv module)

## License

Public Domain
