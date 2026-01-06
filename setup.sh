#!/bin/bash
#
# Silverware Game Servers - Main Setup Menu
# Interactive installer for various game dedicated servers
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "$0")"

# Source common library
source "${SCRIPT_DIR}/lib/common.sh"

# Menu configuration
MENU_TITLE="Silverware Game Servers"
MENU_VERSION="1.0.0"

# Dialog dimensions
DIALOG_HEIGHT=18
DIALOG_WIDTH=60
DIALOG_MENU_HEIGHT=6

# =============================================================================
# MENU OPTIONS
# =============================================================================
declare -A MENU_OPTIONS=(
    [1]="Killing Floor"
    [2]="Killing Floor 2"
    [3]="Team Fortress 2"
    [4]="Project Zomboid"
)

declare -A MENU_SCRIPTS=(
    [1]="${SCRIPT_DIR}/killingfloor/kf-server-setup.sh"
    [2]="${SCRIPT_DIR}/killingfloor2/kf2-server-setup.sh"
    [3]="${SCRIPT_DIR}/teamfortress2/tf2-server-setup.sh"
    [4]="${SCRIPT_DIR}/projectzomboid/pz-server-setup.sh"
)

declare -A MENU_DESCRIPTIONS=(
    [1]="Classic cooperative survival horror FPS"
    [2]="Sequel with updated graphics and gameplay"
    [3]="Team-based multiplayer FPS by Valve"
    [4]="Open-world zombie survival RPG"
)

# =============================================================================
# FUNCTIONS
# =============================================================================

# Display banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
  ____  _ _
 / ___|(_) |_   _____ _ ____      ____ _ _ __ ___
 \___ \| | \ \ / / _ \ '__\ \ /\ / / _` | '__/ _ \
  ___) | | |\ V /  __/ |   \ V  V / (_| | | |  __/
 |____/|_|_| \_/ \___|_|    \_/\_/ \__,_|_|  \___|

   ____                        ____
  / ___| __ _ _ __ ___   ___  / ___|  ___ _ ____   _____ _ __ ___
 | |  _ / _` | '_ ` _ \ / _ \ \___ \ / _ \ '__\ \ / / _ \ '__/ __|
 | |_| | (_| | | | | | |  __/  ___) |  __/ |   \ V /  __/ |  \__ \
  \____|\__,_|_| |_| |_|\___| |____/ \___|_|    \_/ \___|_|  |___/

EOF
    echo -e "${RESET}"
    echo -e "${DIM}Version ${MENU_VERSION}${RESET}"
    separator "─" 60
    echo ""
}

# Show text-based menu (fallback when dialog is not available)
show_text_menu() {
    local choice

    while true; do
        show_banner

        echo -e "${BOLD}Available Game Servers:${RESET}"
        echo ""

        for key in $(echo "${!MENU_OPTIONS[@]}" | tr ' ' '\n' | sort -n); do
            echo -e "  ${GREEN}${key})${RESET} ${BOLD}${MENU_OPTIONS[$key]}${RESET}"
            echo -e "     ${DIM}${MENU_DESCRIPTIONS[$key]}${RESET}"
            echo ""
        done

        separator "─" 60
        echo -e "  ${YELLOW}q)${RESET} Quit"
        echo ""
        separator "─" 60

        echo ""
        echo -en "${CYAN}Enter your choice [1-${#MENU_OPTIONS[@]}, q]: ${RESET}"
        read -r choice

        case "$choice" in
            [1-4])
                run_setup "$choice"
                ;;
            q|Q)
                echo ""
                log_info "Exiting. Goodbye!"
                exit 0
                ;;
            *)
                log_warn "Invalid option. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Show dialog-based menu (if dialog is installed)
show_dialog_menu() {
    local choice
    local options=()

    # Build options array for dialog
    for key in $(echo "${!MENU_OPTIONS[@]}" | tr ' ' '\n' | sort -n); do
        options+=("$key" "${MENU_OPTIONS[$key]} - ${MENU_DESCRIPTIONS[$key]}")
    done

    while true; do
        choice=$(dialog --clear \
            --backtitle "$MENU_TITLE - v$MENU_VERSION" \
            --title "Select Game Server" \
            --cancel-label "Exit" \
            --menu "Choose a game server to install and configure:" \
            $DIALOG_HEIGHT $DIALOG_WIDTH $DIALOG_MENU_HEIGHT \
            "${options[@]}" \
            2>&1 >/dev/tty)

        local exit_status=$?

        clear

        # Check if user pressed Cancel/Exit
        if [[ $exit_status -ne 0 ]]; then
            log_info "Exiting. Goodbye!"
            exit 0
        fi

        if [[ -n "$choice" ]]; then
            run_setup "$choice"
        fi
    done
}

# Run the selected setup script
run_setup() {
    local choice="$1"
    local script="${MENU_SCRIPTS[$choice]}"
    local game="${MENU_OPTIONS[$choice]}"

    # Validate script exists
    if [[ ! -f "$script" ]]; then
        log_error "Setup script not found: ${script}"
        echo ""
        echo -en "Press Enter to continue..."
        read -r
        return 1
    fi

    # Validate script is executable
    if [[ ! -x "$script" ]]; then
        log_warn "Script is not executable. Attempting to fix..."
        chmod +x "$script"
    fi

    log_header "Installing ${game} Server"
    log_info "Running setup script: ${script}"
    log_to_file "SETUP" "User selected: ${game}"
    echo ""

    # Run the setup script
    if bash "$script"; then
        log_success "${game} server setup completed!"
        log_to_file "SETUP" "${game} setup completed successfully"
    else
        log_error "${game} server setup failed!"
        log_to_file "SETUP" "${game} setup failed"
    fi

    echo ""
    separator "─" 60
    echo -en "Press Enter to return to menu..."
    read -r
}

# Show usage information
show_usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Silverware Game Servers Setup Utility

Options:
    -h, --help      Show this help message
    -v, --version   Show version information
    -t, --text      Force text-based menu (no dialog)
    -l, --list      List available game servers

Examples:
    ${SCRIPT_NAME}           # Run interactive menu
    ${SCRIPT_NAME} --text    # Force text menu
    ${SCRIPT_NAME} --list    # Show available servers

EOF
}

# List available servers
list_servers() {
    echo ""
    echo -e "${BOLD}Available Game Servers:${RESET}"
    echo ""
    for key in $(echo "${!MENU_OPTIONS[@]}" | tr ' ' '\n' | sort -n); do
        echo -e "  ${key}. ${MENU_OPTIONS[$key]}"
        echo -e "     ${DIM}${MENU_DESCRIPTIONS[$key]}${RESET}"
    done
    echo ""
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    local force_text=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--version)
                echo "${MENU_TITLE} v${MENU_VERSION}"
                exit 0
                ;;
            -t|--text)
                force_text=true
                shift
                ;;
            -l|--list)
                list_servers
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Log session start
    log_to_file "SESSION" "=== New session started ==="
    log_to_file "SESSION" "User: $(whoami), Host: $(hostname)"

    # Check for root privileges
    if [[ $EUID -ne 0 ]]; then
        log_warn "Not running as root. Some operations may fail."
        log_warn "Consider running with: sudo ${SCRIPT_NAME}"
        echo ""
        sleep 2
    fi

    # Select menu type
    if [[ "$force_text" == true ]] || ! command_exists dialog; then
        if ! command_exists dialog && [[ "$force_text" != true ]]; then
            log_info "Dialog not found. Using text-based menu."
            log_info "Install dialog for a better experience: apt-get install dialog"
            sleep 2
        fi
        show_text_menu
    else
        show_dialog_menu
    fi
}

# Run main function
main "$@"
