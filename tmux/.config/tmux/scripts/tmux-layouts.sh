#!/bin/bash
# Quick layout creator for tmux with Catppuccin theming
# Works alongside sesh for session management

# Catppuccin colors
GREEN='\033[38;2;166;227;161m'
BLUE='\033[38;2;137;180;250m'
PINK='\033[38;2;245;194;231m'
MAUVE='\033[38;2;203;166;247m'
YELLOW='\033[38;2;249;226;175m'
RESET='\033[0m'

# Common project layouts - these create windows/panes in current session
function dev_layout() {
    local project_dir="${1:-$(pwd)}"
    
    echo -e "${BLUE}Creating development layout in current session...${RESET}"
    
    # Create windows for development workflow
    tmux rename-window "editor"
    tmux split-window -h -c "$project_dir"
    tmux resize-pane -t 0 -x 60%
    
    tmux new-window -n "git" -c "$project_dir"
    tmux new-window -n "server" -c "$project_dir"
    tmux split-window -v -c "$project_dir"
    
    tmux new-window -n "test" -c "$project_dir"
    
    # Return to editor window
    tmux select-window -t "editor"
    
    echo -e "${GREEN}✓ Development layout created${RESET}"
}

function monitoring_layout() {
    echo -e "${GREEN}Creating monitoring layout in current session...${RESET}"
    
    # Create 4-pane layout for monitoring
    tmux rename-window "system"
    tmux split-window -h
    tmux split-window -v -t 0
    tmux split-window -v -t 1
    
    # Run monitoring commands
    tmux send-keys -t 0 "htop" Enter
    tmux send-keys -t 1 "watch -n 1 'df -h'" Enter
    tmux send-keys -t 2 "watch -n 1 'free -h'" Enter
    tmux send-keys -t 3 "journalctl -f" Enter
    
    # Create network monitoring window
    tmux new-window -n "network"
    tmux send-keys "watch -n 1 'ss -tunap | head -20'" Enter
    
    tmux select-window -t "system"
    
    echo -e "${GREEN}✓ Monitoring layout created${RESET}"
}

function notes_layout() {
    local notes_dir="${1:-$HOME/notes}"
    
    echo -e "${PINK}Creating notes layout in current session...${RESET}"
    
    # Create notes directory if it doesn't exist
    mkdir -p "$notes_dir"
    
    tmux rename-window "notes"
    tmux send-keys "cd $notes_dir" Enter
    tmux split-window -h -c "$notes_dir"
    tmux resize-pane -t 0 -x 70%
    
    # Create todo window
    tmux new-window -n "todo" -c "$notes_dir"
    
    tmux select-window -t "notes"
    
    echo -e "${GREEN}✓ Notes layout created${RESET}"
}

function docker_layout() {
    echo -e "${MAUVE}Creating Docker layout in current session...${RESET}"
    
    tmux rename-window "containers"
    tmux split-window -h
    
    # Docker monitoring commands
    tmux send-keys -t 0 "watch -n 2 'docker ps --format \"table {{.Names}}\t{{.Status}}\t{{.Ports}}\"'" Enter
    tmux send-keys -t 1 "docker stats" Enter
    
    # Create compose window
    tmux new-window -n "compose"
    
    # Create logs window
    tmux new-window -n "logs"
    
    tmux select-window -t "containers"
    
    echo -e "${GREEN}✓ Docker layout created${RESET}"
}

# Main menu
function main() {
    # Check if we're in a tmux session
    if [ -z "$TMUX" ]; then
        echo -e "${YELLOW}Not in a tmux session!${RESET}"
        echo -e "Use ${GREEN}sesh${RESET} to create or attach to a session first."
        exit 1
    fi
    
    echo -e "${BLUE}╔══════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║     Tmux Layout Templates           ║${RESET}"
    echo -e "${BLUE}╚══════════════════════════════════════╝${RESET}"
    echo
    echo -e "${YELLOW}Select a layout for current session:${RESET}"
    echo -e "  ${GREEN}1)${RESET} Development (editor, git, server, test)"
    echo -e "  ${GREEN}2)${RESET} System Monitoring (htop, disk, memory, logs)"
    echo -e "  ${GREEN}3)${RESET} Notes & Documentation"
    echo -e "  ${GREEN}4)${RESET} Docker Management"
    echo
    
    read -p "Choice [1-4]: " choice
    
    case $choice in
        1)
            read -p "Project directory [current]: " dir
            dev_layout "${dir:-$(pwd)}"
            ;;
        2)
            monitoring_layout
            ;;
        3)
            read -p "Notes directory [$HOME/notes]: " dir
            notes_layout "${dir:-$HOME/notes}"
            ;;
        4)
            docker_layout
            ;;
        *)
            echo -e "${YELLOW}Invalid choice${RESET}"
            ;;
    esac
}

# Run main function
main