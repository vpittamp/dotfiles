#!/bin/bash

# DevSpace container-specific dotfiles installation script
# This script is designed to work in the DevSpace container where HOME=/app

set -e

echo "🚀 Installing dotfiles in DevSpace container..."

# Install stow if not present
if ! command -v stow &> /dev/null; then
    echo "📦 Installing GNU Stow..."
    apt-get update && apt-get install -y stow
fi

# Navigate to dotfiles directory
cd "$(dirname "$0")"

echo "🔗 Creating symlinks with stow in /app..."

# Use /app as the target directory for stow
# This ensures configs go to /app/.bashrc, /app/.config/, etc.
STOW_TARGET="/app"

# Stow configurations to /app
stow -t $STOW_TARGET -v bash 2>/dev/null || echo "bash: already linked or conflicts"
stow -t $STOW_TARGET -v git 2>/dev/null || echo "git: already linked or conflicts"
stow -t $STOW_TARGET -v zsh 2>/dev/null || echo "zsh: already linked or conflicts"
stow -t $STOW_TARGET -v yarn 2>/dev/null || echo "yarn: already linked or conflicts"
stow -t $STOW_TARGET -v tmux 2>/dev/null || echo "tmux: already linked or conflicts"
stow -t $STOW_TARGET -v neovim 2>/dev/null || echo "neovim: already linked or conflicts"
stow -t $STOW_TARGET -v fish 2>/dev/null || echo "fish: already linked or conflicts"
stow -t $STOW_TARGET -v ghostty 2>/dev/null || echo "ghostty: already linked or conflicts"
stow -t $STOW_TARGET -v git-config 2>/dev/null || echo "git-config: already linked or conflicts"

# Install TPM if not present and we have tmux
if command -v tmux &> /dev/null; then
    if [ ! -d "$STOW_TARGET/.config/tmux/plugins/tpm" ]; then
        echo "📦 Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm $STOW_TARGET/.config/tmux/plugins/tpm
    fi
    echo "💡 Remember to press 'prefix + I' in tmux to install plugins"
fi

# Fix zoxide path in bashrc if needed (use container paths)
if [ -f "$STOW_TARGET/.bashrc" ]; then
    # Check if zoxide is available in container
    if command -v zoxide &> /dev/null; then
        sed -i 's|~/.local/bin/zoxide|zoxide|g' $STOW_TARGET/.bashrc
    else
        echo "⚠️  zoxide not found, you may want to install it"
    fi
fi

echo "✅ Dotfiles installed successfully in DevSpace container!"
echo ""
echo "To apply bash configuration, run: source /app/.bashrc"