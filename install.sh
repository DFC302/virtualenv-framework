#!/bin/bash
# Installation helper for venvframework

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENVFRAMEWORK_PATH="$SCRIPT_DIR/venvframework.sh"

echo "Python Virtual Environment Framework - Installation"
echo "=================================================="
echo ""

# Detect user's login shell
USER_SHELL=$(basename "$SHELL")

case "$USER_SHELL" in
    bash)
        SHELL_CONFIG="$HOME/.bashrc"
        SHELL_NAME="bash"
        ;;
    zsh)
        SHELL_CONFIG="$HOME/.zshrc"
        SHELL_NAME="zsh"
        ;;
    *)
        echo "Unsupported shell: $USER_SHELL"
        echo "Please add the following line manually to your shell config:"
        echo "  source $VENVFRAMEWORK_PATH"
        exit 1
        ;;
esac

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
