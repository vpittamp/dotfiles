#!/bin/bash

# Dotfiles installation script for VSCode/Codespaces/DevContainers and remote machines
set -e

echo "🚀 Installing dotfiles..."

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    PKG_INSTALL="sudo apt-get install -y"
    PKG_UPDATE="sudo apt-get update"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    PKG_INSTALL="sudo yum install -y"
    PKG_UPDATE="sudo yum check-update || true"
elif command -v brew &> /dev/null; then
    PKG_MANAGER="brew"
    PKG_INSTALL="brew install"
    PKG_UPDATE="brew update"
else
    echo "⚠️  No supported package manager found (apt-get, yum, or brew)"
    echo "   You'll need to manually install: git, stow, tmux"
fi

# Install git if not present
if ! command -v git &> /dev/null; then
    if [ -n "$PKG_MANAGER" ]; then
        echo "📦 Installing Git..."
        $PKG_UPDATE
        $PKG_INSTALL git
    else
        echo "❌ Git is not installed and no package manager available. Please install git manually."
        exit 1
    fi
else
    echo "✓ Git is already installed"
fi

# Install stow if not present
if ! command -v stow &> /dev/null; then
    if [ -n "$PKG_MANAGER" ]; then
        echo "📦 Installing GNU Stow..."
        $PKG_INSTALL stow
    else
        echo "❌ Could not install stow. Please install it manually."
        exit 1
    fi
else
    echo "✓ GNU Stow is already installed"
fi

# Install tmux if not present
if ! command -v tmux &> /dev/null; then
    if [ -n "$PKG_MANAGER" ]; then
        echo "📦 Installing Tmux..."
        $PKG_INSTALL tmux
    else
        echo "⚠️  Tmux is not installed. Please install it manually to use tmux configurations."
    fi
else
    echo "✓ Tmux is already installed"
fi

# Navigate to dotfiles directory
cd "$(dirname "$0")"

echo "🔗 Creating symlinks with stow..."

# Create necessary directories
mkdir -p "$HOME/.config"

# Stow all configurations
for package in bash git tmux; do
    if [ -d "$package" ]; then
        echo "  → Stowing $package..."
        stow -v "$package"
    else
        echo "  ⚠️  Package $package not found, skipping..."
    fi
done

# Install TPM and tmux plugins if tmux is available
if command -v tmux &> /dev/null; then
    if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
        echo "📦 Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
        
        if [ -f "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" ]; then
            echo "🔌 Installing tmux plugins..."
            ~/.config/tmux/plugins/tpm/bin/install_plugins
        fi
    else
        echo "✓ TPM already installed"
        # Update plugins if TPM exists
        if [ -f "$HOME/.config/tmux/plugins/tpm/bin/update_plugins" ]; then
            echo "🔌 Updating tmux plugins..."
            ~/.config/tmux/plugins/tpm/bin/update_plugins all
        fi
    fi
else
    echo "ℹ️  Skipping tmux plugin installation (tmux not installed)"
fi

# Check for optional dependencies
echo ""
echo "📋 Checking optional dependencies..."

# Check for xclip (for tmux clipboard support)
if ! command -v xclip &> /dev/null; then
    echo "  ⚠️  xclip not found - tmux clipboard integration won't work"
    echo "     Install with: $PKG_INSTALL xclip"
else
    echo "  ✓ xclip (clipboard support)"
fi

# Check for fzf (for tmux-fzf plugin)
if ! command -v fzf &> /dev/null; then
    echo "  ⚠️  fzf not found - some tmux features won't work"
    echo "     Install with: git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install"
else
    echo "  ✓ fzf (fuzzy finder)"
fi

echo ""
echo "✅ Dotfiles installed successfully!"
echo ""
echo "💡 Tips:"
echo "   - Restart your shell or run: source ~/.bashrc"
echo "   - In tmux, press 'prefix + I' to ensure all plugins are installed"
echo "   - The tmux prefix is set to backtick (`)"