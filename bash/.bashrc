#!/bin/bash
# Simplified bashrc specifically for container use
# This avoids all the problematic components

# Basic shell options
set -o vi  # vi mode if you prefer
shopt -s histappend
shopt -s checkwinsize
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# Simple colored prompt without git integration
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Essential aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Git aliases (simple, no prompt integration)
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# Node/Yarn development
alias ys='yarn start'
alias yb='yarn build'
alias yt='yarn test'
alias yd='yarn dev'

# Environment
export TERM=xterm-256color
export NODE_ENV=development
export BROWSER=none
export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:./node_modules/.bin:$PATH"

# Start in app directory
cd /app 2>/dev/null || true

# Bash completion (lightweight)
[ -f /etc/bash_completion ] && . /etc/bash_completion