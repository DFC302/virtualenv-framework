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
