#!/bin/bash

# Dotfiles installation script for VSCode/Codespaces/DevContainers
set -e

echo "🚀 Installing dotfiles..."

# Install stow if not present
if ! command -v stow &> /dev/null; then
    echo "📦 Installing GNU Stow..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y stow
    elif command -v yum &> /dev/null; then
        sudo yum install -y stow
    elif command -v brew &> /dev/null; then
        brew install stow
    else
        echo "❌ Could not install stow. Please install it manually."
        exit 1
    fi
fi

# Navigate to dotfiles directory
cd "$(dirname "$0")"

echo "🔗 Creating symlinks with stow..."

# Stow all configurations
stow -v bash
stow -v git
stow -v tmux

# Install TPM if not present and we have tmux
if command -v tmux &> /dev/null; then
    if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
        echo "📦 Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
        
        echo "🔌 Installing tmux plugins..."
        ~/.config/tmux/plugins/tpm/bin/install_plugins
    else
        echo "✓ TPM already installed"
        # Update plugins if TPM exists
        echo "🔌 Updating tmux plugins..."
        ~/.config/tmux/plugins/tpm/bin/update_plugins all
    fi
fi

echo "✅ Dotfiles installed successfully!"