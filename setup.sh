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
DIALOG_HEIGHT=20
DIALOG_WIDTH=70
DIALOG_MENU_HEIGHT=24

# =============================================================================
# MENU OPTIONS (Alphabetical Order)
# =============================================================================
declare -A MENU_OPTIONS=(
    [1]="Abiotic Factor"
    [2]="ARK: Survival Ascended"
    [3]="Black Mesa"
    [4]="City of Heroes"
    [5]="Counter-Strike"
    [6]="Counter-Strike 2"
    [7]="Half-Life Deathmatch"
    [8]="Half-Life 2: Deathmatch"
    [9]="HumanitZ"
    [10]="Killing Floor"
    [11]="Killing Floor 2"
    [12]="Project Zomboid"
    [13]="San Andreas Multiplayer"
    [14]="Starbound"
    [15]="Star Wars Galaxies EMU"
    [16]="Sven Co-op"
    [17]="Synergy"
    [18]="Team Fortress Classic"
    [19]="Team Fortress 2"
    [20]="Unreal Tournament 99"
    [21]="Unreal Tournament 2004"
    [22]="World of Warcraft"
)

declare -A MENU_SCRIPTS=(
    [1]="${SCRIPT_DIR}/abioticfactor/af-server-setup.sh"
    [2]="${SCRIPT_DIR}/arkasa/ark-server-setup.sh"
    [3]="${SCRIPT_DIR}/blackmesa/bm-server-setup.sh"
    [4]="${SCRIPT_DIR}/cityofheroes/coh-server-setup.sh"
    [5]="${SCRIPT_DIR}/counterstrike/cs-server-setup.sh"
    [6]="${SCRIPT_DIR}/counterstrike2/cs2-server-setup.sh"
    [7]="${SCRIPT_DIR}/hldm/hldm-server-setup.sh"
    [8]="${SCRIPT_DIR}/hl2dm/hl2dm-server-setup.sh"
    [9]="${SCRIPT_DIR}/humanitz/humanitz-server-setup.sh"
    [10]="${SCRIPT_DIR}/killingfloor/kf-server-setup.sh"
    [11]="${SCRIPT_DIR}/killingfloor2/kf2-server-setup.sh"
    [12]="${SCRIPT_DIR}/projectzomboid/pz-server-setup.sh"
    [13]="${SCRIPT_DIR}/samp/samp-server-setup.sh"
    [14]="${SCRIPT_DIR}/starbound/starbound-server-setup.sh"
    [15]="${SCRIPT_DIR}/swgemu/swgemu-server-setup.sh"
    [16]="${SCRIPT_DIR}/svencoop/svencoop-server-setup.sh"
    [17]="${SCRIPT_DIR}/synergy/synergy-server-setup.sh"
    [18]="${SCRIPT_DIR}/tfc/tfc-server-setup.sh"
    [19]="${SCRIPT_DIR}/teamfortress2/tf2-server-setup.sh"
    [20]="${SCRIPT_DIR}/ut99/ut99-server-setup.sh"
    [21]="${SCRIPT_DIR}/ut2004/ut2004-server-setup.sh"
    [22]="${SCRIPT_DIR}/azerothcore/wow-server-setup.sh"
)

declare -A MENU_DESCRIPTIONS=(
    [1]="Co-op sci-fi survival crafting"
    [2]="Dinosaur survival sandbox MMO"
    [3]="Half-Life remake deathmatch"
    [4]="Superhero MMORPG (Windows VM)"
    [5]="Classic tactical shooter"
    [6]="Modern tactical shooter"
    [7]="Classic GoldSrc deathmatch"
    [8]="Source engine deathmatch"
    [9]="Open-world zombie survival"
    [10]="Cooperative survival horror FPS"
    [11]="Cooperative survival horror sequel"
    [12]="Open-world zombie survival RPG"
    [13]="GTA San Andreas multiplayer mod"
    [14]="Sandbox exploration adventure"
    [15]="Pre-CU SWG emulator"
    [16]="Half-Life co-op mod"
    [17]="Half-Life 2 co-op mod"
    [18]="Classic team-based multiplayer"
    [19]="Team-based multiplayer FPS"
    [20]="Classic arena shooter"
    [21]="Arena shooter sequel"
    [22]="WotLK 3.3.5a private server"
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
        echo -e "  ${CYAN}m)${RESET} Monitor deployed servers"
        echo -e "  ${YELLOW}q)${RESET} Quit"
        echo ""
        separator "─" 60

        echo ""
        echo -en "${CYAN}Enter your choice [1-${#MENU_OPTIONS[@]}, m, q]: ${RESET}"
        read -r choice

        case "$choice" in
            [1-9]|1[0-9]|2[0-2])
                run_setup "$choice"
                ;;
            m|M)
                show_monitor_menu
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
    # Add monitoring option
    options+=("M" "Monitor Deployed Servers - View status, logs, control servers")

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

        if [[ "$choice" == "M" ]]; then
            show_monitor_menu
        elif [[ -n "$choice" ]]; then
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
    -m, --monitor   Open server monitoring menu
    -s, --status    Show quick status of all deployed servers

Examples:
    ${SCRIPT_NAME}           # Run interactive menu
    ${SCRIPT_NAME} --text    # Force text menu
    ${SCRIPT_NAME} --list    # Show available servers
    ${SCRIPT_NAME} --monitor # Monitor deployed servers
    ${SCRIPT_NAME} --status  # Quick server status check

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
# MONITORING FUNCTIONS
# =============================================================================

# Show monitoring menu
show_monitor_menu() {
    local choice

    while true; do
        show_banner
        echo -e "${BOLD}Server Monitoring${RESET}"
        echo ""

        show_servers_status

        separator "─" 60
        echo -e "${BOLD}Actions:${RESET}"
        echo ""
        echo -e "  ${GREEN}1)${RESET} Refresh status"
        echo -e "  ${GREEN}2)${RESET} View server details"
        echo -e "  ${GREEN}3)${RESET} Start a server"
        echo -e "  ${GREEN}4)${RESET} Stop a server"
        echo -e "  ${GREEN}5)${RESET} Restart a server"
        echo -e "  ${GREEN}6)${RESET} View server logs"
        echo -e "  ${GREEN}7)${RESET} Live resource monitor"
        echo ""
        separator "─" 60
        echo -e "  ${YELLOW}b)${RESET} Back to main menu"
        echo -e "  ${YELLOW}q)${RESET} Quit"
        echo ""
        separator "─" 60

        echo ""
        echo -en "${CYAN}Enter your choice: ${RESET}"
        read -r choice

        case "$choice" in
            1)
                # Refresh - just continue loop
                ;;
            2)
                select_and_show_details
                ;;
            3)
                select_and_control_server "start"
                ;;
            4)
                select_and_control_server "stop"
                ;;
            5)
                select_and_control_server "restart"
                ;;
            6)
                select_and_view_logs
                ;;
            7)
                show_live_stats
                ;;
            b|B)
                return 0
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

# Select a server and show details
select_and_show_details() {
    local containers
    containers=$(list_game_containers | sort -u)

    if [[ -z "$containers" ]]; then
        log_warn "No game server containers found."
        sleep 2
        return
    fi

    echo ""
    echo -e "${BOLD}Select a server to view details:${RESET}"
    echo ""

    local i=1
    declare -A container_map
    while IFS= read -r container; do
        [[ -z "$container" ]] && continue
        echo -e "  ${GREEN}${i})${RESET} $container"
        container_map[$i]="$container"
        ((i++))
    done <<< "$containers"

    echo ""
    echo -en "${CYAN}Enter server number (or 'b' to go back): ${RESET}"
    read -r choice

    if [[ "$choice" == "b" || "$choice" == "B" ]]; then
        return
    fi

    if [[ -n "${container_map[$choice]}" ]]; then
        show_server_details "${container_map[$choice]}"
        echo -en "Press Enter to continue..."
        read -r
    else
        log_warn "Invalid selection."
        sleep 1
    fi
}

# Select a server and control it (start/stop/restart)
select_and_control_server() {
    local action="$1"
    local containers
    containers=$(list_game_containers | sort -u)

    if [[ -z "$containers" ]]; then
        log_warn "No game server containers found."
        sleep 2
        return
    fi

    echo ""
    echo -e "${BOLD}Select a server to ${action}:${RESET}"
    echo ""

    local i=1
    declare -A container_map
    while IFS= read -r container; do
        [[ -z "$container" ]] && continue
        local status
        status=$(get_container_status "$container")
        local status_icon
        case "$status" in
            running) status_icon="${GREEN}●${RESET}" ;;
            stopped) status_icon="${RED}●${RESET}" ;;
            *) status_icon="${YELLOW}●${RESET}" ;;
        esac
        echo -e "  ${GREEN}${i})${RESET} $container [$status_icon $status]"
        container_map[$i]="$container"
        ((i++))
    done <<< "$containers"

    echo ""
    echo -en "${CYAN}Enter server number (or 'b' to go back): ${RESET}"
    read -r choice

    if [[ "$choice" == "b" || "$choice" == "B" ]]; then
        return
    fi

    if [[ -n "${container_map[$choice]}" ]]; then
        local container="${container_map[$choice]}"
        echo ""
        case "$action" in
            start)
                log_info "Starting ${container}..."
                if docker start "$container" &>/dev/null; then
                    log_success "Server started: ${container}"
                else
                    log_error "Failed to start: ${container}"
                fi
                ;;
            stop)
                log_info "Stopping ${container}..."
                if docker stop "$container" &>/dev/null; then
                    log_success "Server stopped: ${container}"
                else
                    log_error "Failed to stop: ${container}"
                fi
                ;;
            restart)
                log_info "Restarting ${container}..."
                if docker restart "$container" &>/dev/null; then
                    log_success "Server restarted: ${container}"
                else
                    log_error "Failed to restart: ${container}"
                fi
                ;;
        esac
        sleep 2
    else
        log_warn "Invalid selection."
        sleep 1
    fi
}

# Select a server and view its logs
select_and_view_logs() {
    local containers
    containers=$(list_game_containers | sort -u)

    if [[ -z "$containers" ]]; then
        log_warn "No game server containers found."
        sleep 2
        return
    fi

    echo ""
    echo -e "${BOLD}Select a server to view logs:${RESET}"
    echo ""

    local i=1
    declare -A container_map
    while IFS= read -r container; do
        [[ -z "$container" ]] && continue
        echo -e "  ${GREEN}${i})${RESET} $container"
        container_map[$i]="$container"
        ((i++))
    done <<< "$containers"

    echo ""
    echo -en "${CYAN}Enter server number (or 'b' to go back): ${RESET}"
    read -r choice

    if [[ "$choice" == "b" || "$choice" == "B" ]]; then
        return
    fi

    if [[ -n "${container_map[$choice]}" ]]; then
        local container="${container_map[$choice]}"
        echo ""
        separator "=" 60
        echo -e "${BOLD}Logs for: ${container}${RESET}"
        echo -e "${DIM}(Press Ctrl+C to stop following logs)${RESET}"
        separator "-" 60
        echo ""

        # Show last 50 lines then follow
        docker logs --tail 50 -f "$container" 2>&1 || true

        echo ""
        echo -en "Press Enter to continue..."
        read -r
    else
        log_warn "Invalid selection."
        sleep 1
    fi
}

# Show live resource stats for all running servers
show_live_stats() {
    local containers
    containers=$(docker ps --format '{{.Names}}' | grep -E "server$|server[0-9]*$" | sort -u)

    if [[ -z "$containers" ]]; then
        log_warn "No running game server containers found."
        sleep 2
        return
    fi

    echo ""
    separator "=" 60
    echo -e "${BOLD}Live Resource Monitor${RESET}"
    echo -e "${DIM}(Press Ctrl+C to stop)${RESET}"
    separator "-" 60
    echo ""

    # Run docker stats for game server containers
    docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.PIDs}}" $containers || true

    echo ""
    echo -en "Press Enter to continue..."
    read -r
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    local force_text=false
    local show_monitor=false
    local show_status_only=false

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
            -m|--monitor)
                show_monitor=true
                shift
                ;;
            -s|--status)
                show_status_only=true
                shift
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

    # Check Docker prerequisites
    if ! command_exists docker; then
        log_error "Docker is not installed."
        echo ""
        echo -e "${BOLD}Docker is required to run game servers.${RESET}"
        echo ""
        echo "Install Docker using one of these methods:"
        echo ""
        echo -e "  ${GREEN}Ubuntu/Debian:${RESET}"
        echo "    curl -fsSL https://get.docker.com | sh"
        echo "    sudo usermod -aG docker \$USER"
        echo ""
        echo -e "  ${GREEN}Arch Linux:${RESET}"
        echo "    sudo pacman -S docker"
        echo "    sudo systemctl enable --now docker"
        echo ""
        echo -e "  ${GREEN}Fedora:${RESET}"
        echo "    sudo dnf install docker"
        echo "    sudo systemctl enable --now docker"
        echo ""
        echo "After installation, log out and back in for group changes to take effect."
        echo ""
        exit 1
    fi

    if ! docker info &>/dev/null; then
        log_error "Docker daemon is not running."
        echo ""
        echo "Start Docker with:"
        echo "  sudo systemctl start docker"
        echo ""
        echo "To enable Docker on boot:"
        echo "  sudo systemctl enable docker"
        echo ""
        exit 1
    fi

    log_success "Docker is available"

    # Handle --status option (quick status check and exit)
    if [[ "$show_status_only" == true ]]; then
        show_servers_status
        exit 0
    fi

    # Handle --monitor option (go directly to monitoring menu)
    if [[ "$show_monitor" == true ]]; then
        show_monitor_menu
        exit 0
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
