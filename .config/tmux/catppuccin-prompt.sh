#!/bin/bash
# Catppuccin Mocha themed bash prompt with git integration

# Catppuccin Mocha color definitions
CATPPUCCIN_ROSEWATER=$'\e[38;2;245;224;220m'
CATPPUCCIN_FLAMINGO=$'\e[38;2;242;205;205m'
CATPPUCCIN_PINK=$'\e[38;2;245;194;231m'
CATPPUCCIN_MAUVE=$'\e[38;2;203;166;247m'
CATPPUCCIN_RED=$'\e[38;2;243;139;168m'
CATPPUCCIN_MAROON=$'\e[38;2;235;160;172m'
CATPPUCCIN_PEACH=$'\e[38;2;250;179;135m'
CATPPUCCIN_YELLOW=$'\e[38;2;249;226;175m'
CATPPUCCIN_GREEN=$'\e[38;2;166;227;161m'
CATPPUCCIN_TEAL=$'\e[38;2;148;226;213m'
CATPPUCCIN_SKY=$'\e[38;2;137;220;235m'
CATPPUCCIN_SAPPHIRE=$'\e[38;2;116;199;236m'
CATPPUCCIN_BLUE=$'\e[38;2;137;180;250m'
CATPPUCCIN_LAVENDER=$'\e[38;2;180;190;254m'
CATPPUCCIN_TEXT=$'\e[38;2;205;214;244m'
CATPPUCCIN_SUBTEXT1=$'\e[38;2;186;194;222m'
CATPPUCCIN_OVERLAY0=$'\e[38;2;108;112;134m'
CATPPUCCIN_SURFACE0=$'\e[38;2;49;50;68m'
CATPPUCCIN_BASE=$'\e[38;2;30;30;46m'
CATPPUCCIN_MANTLE=$'\e[38;2;24;24;37m'
CATPPUCCIN_CRUST=$'\e[38;2;17;17;27m'
RESET=$'\e[0m'
BOLD=$'\e[1m'

# Command timing
function timer_start {
    timer=${timer:-$SECONDS}
}

function timer_stop {
    timer_show=$(($SECONDS - $timer))
    if [ $timer_show -ge 3600 ]; then
        timer_display="$(($timer_show / 3600))h $((($timer_show % 3600) / 60))m"
    elif [ $timer_show -ge 60 ]; then
        timer_display="$(($timer_show / 60))m $(($timer_show % 60))s"
    elif [ $timer_show -ge 1 ]; then
        timer_display="${timer_show}s"
    else
        timer_display=""
    fi
    unset timer
}

trap 'timer_start' DEBUG
PROMPT_COMMAND=timer_stop

# Git functions
function parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function parse_git_dirty() {
    [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}

function git_status_summary() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(parse_git_branch)
        local dirty=$(parse_git_dirty)
        local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)
        local modified=$(git diff --name-only 2>/dev/null | wc -l)
        local staged=$(git diff --cached --name-only 2>/dev/null | wc -l)
        
        local git_info="${CATPPUCCIN_LAVENDER} ${branch}${RESET}"
        
        if [ "$staged" -gt 0 ]; then
            git_info="${git_info} ${CATPPUCCIN_GREEN}+${staged}${RESET}"
        fi
        
        if [ "$modified" -gt 0 ]; then
            git_info="${git_info} ${CATPPUCCIN_YELLOW}~${modified}${RESET}"
        fi
        
        if [ "$untracked" -gt 0 ]; then
            git_info="${git_info} ${CATPPUCCIN_RED}?${untracked}${RESET}"
        fi
        
        if [ -n "$dirty" ]; then
            git_info="${git_info} ${CATPPUCCIN_PEACH}${RESET}"
        fi
        
        echo "$git_info"
    fi
}

# Virtual environment detection
function virtualenv_info() {
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "${CATPPUCCIN_YELLOW}($(basename $VIRTUAL_ENV))${RESET} "
    fi
}

# Node version (if nvm is installed)
function node_version() {
    if command -v node &> /dev/null; then
        echo "${CATPPUCCIN_GREEN} $(node -v | sed 's/v//')${RESET}"
    fi
}

# Directory with truncation
function get_dir() {
    local dir="${PWD/#$HOME/~}"
    local max_len=30
    if [ ${#dir} -gt $max_len ]; then
        local offset=$(( ${#dir} - $max_len ))
        dir="...${dir:$offset:$max_len}"
    fi
    echo "$dir"
}

# Exit status indicator
function exit_status() {
    local status=$?
    if [ $status -eq 0 ]; then
        echo "${CATPPUCCIN_GREEN}${RESET}"
    else
        echo "${CATPPUCCIN_RED}✗ ${status}${RESET}"
    fi
}

# Build the prompt
function build_prompt() {
    local last_status=$?
    
    PS1="\n"
    
    # First line: User@Host | Working directory | Git status
    PS1+="${CATPPUCCIN_BLUE}┌─${RESET} "
    PS1+="${CATPPUCCIN_GREEN}\u${RESET}"
    PS1+="${CATPPUCCIN_OVERLAY0}@${RESET}"
    PS1+="${CATPPUCCIN_MAUVE}\h${RESET} "
    PS1+="${CATPPUCCIN_OVERLAY0}in${RESET} "
    PS1+="${CATPPUCCIN_PINK}${BOLD}$(get_dir)${RESET}"
    
    local git_info=$(git_status_summary)
    if [ -n "$git_info" ]; then
        PS1+=" ${CATPPUCCIN_OVERLAY0}on${RESET}${git_info}"
    fi
    
    # Add timer if command took time
    if [ -n "$timer_display" ]; then
        PS1+=" ${CATPPUCCIN_OVERLAY0}took${RESET} ${CATPPUCCIN_YELLOW}⏱ ${timer_display}${RESET}"
    fi
    
    # Virtual environment
    local venv=$(virtualenv_info)
    if [ -n "$venv" ]; then
        PS1+=" $venv"
    fi
    
    PS1+="\n"
    
    # Second line: Status and prompt
    PS1+="${CATPPUCCIN_BLUE}└─${RESET} "
    
    if [ $last_status -eq 0 ]; then
        PS1+="${CATPPUCCIN_GREEN}❯${RESET} "
    else
        PS1+="${CATPPUCCIN_RED}✗ ${last_status} ❯${RESET} "
    fi
}

# Set the prompt command
PROMPT_COMMAND='build_prompt; timer_stop'

# Enable colors for ls and grep
export CLICOLOR=1
export GREP_OPTIONS='--color=auto'

# Catppuccin-themed LS colors
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43'

# Set terminal title to show current directory
function set_terminal_title() {
    echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/#$HOME/~}\007"
}

# Add to PROMPT_COMMAND
PROMPT_COMMAND="$PROMPT_COMMAND; set_terminal_title"