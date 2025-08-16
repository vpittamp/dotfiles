# Dotfiles

My personal dotfiles managed with GNU Stow.

## Installation

1. Clone this repository:
```bash
git clone https://github.com/vpittamp/dotfiles.git ~/dotfiles
```

2. Install GNU Stow:
```bash
# Ubuntu/Debian
sudo apt-get install stow

# macOS
brew install stow
```

3. Apply configurations:
```bash
cd ~/dotfiles

# Install all configs
stow bash git zsh yarn tmux neovim fish ghostty git-config

# Or install specific configs
stow bash
stow tmux
```

## Structure

- `bash/` - Bash configuration (.bashrc, .bash_aliases, etc.)
- `git/` - Git configuration (.gitconfig, .gitignore)
- `zsh/` - Zsh configuration
- `tmux/` - Tmux configuration
- `neovim/` - Neovim configuration
- `fish/` - Fish shell configuration
- `ghostty/` - Ghostty terminal configuration
- `yarn/` - Yarn package manager configuration

## Uninstalling

To remove symlinks:
```bash
cd ~/dotfiles
stow -D bash  # Remove bash configs
stow -D tmux  # Remove tmux configs
```

## Syncing to DevSpace Container

Use the included `sync-to-devspace.sh` script to sync dotfiles to your DevSpace container.