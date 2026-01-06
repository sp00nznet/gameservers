#!/bin/bash
#
# Counter-Strike 2 Dedicated Server Setup
# Downloads, configures, and runs a CS2 server using SteamCMD
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="Counter-Strike 2"
readonly SERVICE_NAME="cs2server"
readonly STEAM_APP_ID="730"
readonly INSTALL_DIR="/opt/cs2server"
readonly WORKING_DIR="${INSTALL_DIR}"
readonly SERVER_BINARY="${INSTALL_DIR}/game/bin/linuxsteamrt64/cs2"

# Game server settings
readonly SERVER_NAME="Silverware CS2 Server"
readonly DEFAULT_MAP="de_dust2"
readonly MAX_PLAYERS="20"
readonly GAME_TYPE="0"
readonly GAME_MODE="1"
readonly RCON_PASSWORD="changeme"

# Network ports
readonly GAME_PORT="27015"
readonly TV_PORT="27020"

# Steam Game Server Login Token (GSLT)
# Get your token from: https://steamcommunity.com/dev/managegameservers
# App ID for CS2: 730
STEAM_GSLT_TOKEN="${STEAM_GSLT_TOKEN:-}"

# Screen session name
readonly SCREEN_NAME="${SERVICE_NAME}"

# Config file for storing token
readonly CONFIG_FILE="${INSTALL_DIR}/cs2server.conf"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Validate prerequisites
check_prerequisites() {
    log_step 1 7 "Checking prerequisites..."

    local deps=("curl" "tar" "screen" "systemctl")

    if ! check_dependencies "${deps[@]}"; then
        log_error "Missing dependencies. Please install them first."
        exit 1
    fi

    # Check for 64-bit system (CS2 requires 64-bit)
    if [[ $(uname -m) != "x86_64" ]]; then
        log_error "Counter-Strike 2 requires a 64-bit system"
        exit 1
    fi

    log_success "All prerequisites satisfied"
}

# Install SteamCMD
setup_steamcmd() {
    log_step 2 7 "Setting up SteamCMD..."

    if ! install_steamcmd; then
        log_error "Failed to install SteamCMD"
        exit 1
    fi
}

# Download/update game files
download_game_files() {
    log_step 3 7 "Downloading ${GAME_NAME} server files..."

    # Create install directory if needed
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating install directory: ${INSTALL_DIR}"
        mkdir -p "$INSTALL_DIR"
    fi

    if ! run_steamcmd "$INSTALL_DIR" "$STEAM_APP_ID"; then
        log_error "Failed to download game files"
        exit 1
    fi

    log_success "Game files downloaded"
}

# Prompt for Steam GSLT token
configure_steam_token() {
    log_step 4 7 "Configuring Steam Game Server Login Token..."

    # Check if token is already set via environment variable
    if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
        log_info "Using GSLT from environment variable"
        return 0
    fi

    # Check if token exists in config file
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
            log_info "Using GSLT from config file"
            return 0
        fi
    fi

    echo ""
    separator "-" 60
    echo -e "${YELLOW}Steam Game Server Login Token (GSLT) Required${RESET}"
    echo ""
    echo "A GSLT is REQUIRED for CS2 servers to function properly."
    echo "Get one from:"
    echo -e "  ${CYAN}https://steamcommunity.com/dev/managegameservers${RESET}"
    echo ""
    echo "Use App ID: 730 (Counter-Strike 2)"
    echo ""
    separator "-" 60
    echo ""

    echo -en "${CYAN}Enter your GSLT (or press Enter to skip): ${RESET}"
    read -r token_input

    if [[ -n "$token_input" ]]; then
        STEAM_GSLT_TOKEN="$token_input"

        # Save to config file
        mkdir -p "$(dirname "$CONFIG_FILE")"
        echo "# CS2 Server Configuration" > "$CONFIG_FILE"
        echo "STEAM_GSLT_TOKEN=\"${STEAM_GSLT_TOKEN}\"" >> "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"

        log_success "GSLT saved to ${CONFIG_FILE}"
    else
        log_warn "No GSLT provided. Server may not function properly."
        log_info "You can set it later in: ${CONFIG_FILE}"
    fi
}

# Generate systemd service file content
generate_service_file() {
    local gslt_param=""
    if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
        gslt_param="+sv_setsteamaccount ${STEAM_GSLT_TOKEN}"
    fi

    cat << EOF
[Unit]
Description=${GAME_NAME} Dedicated Server
After=network.target

[Service]
Type=forking
User=root
WorkingDirectory=${WORKING_DIR}
ExecStart=/usr/bin/screen -dmS "${SCREEN_NAME}" ${SERVER_BINARY} -dedicated +map ${DEFAULT_MAP} +maxplayers ${MAX_PLAYERS} -port ${GAME_PORT} +game_type ${GAME_TYPE} +game_mode ${GAME_MODE} +rcon_password "${RCON_PASSWORD}" ${gslt_param}
ExecStop=/usr/bin/screen -S "${SCREEN_NAME}" -X quit
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# Create systemd service
setup_systemd_service() {
    log_step 5 7 "Creating systemd service..."

    local service_content
    service_content="$(generate_service_file)"

    if ! create_systemd_service "$SERVICE_NAME" "$service_content"; then
        log_error "Failed to create systemd service"
        exit 1
    fi
}

# Enable and start the service
start_service() {
    log_step 6 7 "Enabling and starting service..."

    if ! enable_service "$SERVICE_NAME"; then
        log_error "Failed to start service"
        exit 1
    fi
}

# Display completion summary
show_summary() {
    log_step 7 7 "Setup complete!"

    local gslt_status="${RED}Not configured${RESET}"
    if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
        gslt_status="${GREEN}Configured${RESET}"
    fi

    echo ""
    separator "=" 60
    echo ""
    echo -e "${BOLD}${GAME_NAME} Server Installation Summary${RESET}"
    echo ""
    separator "-" 60
    echo -e "  ${CYAN}Install Directory:${RESET}  ${INSTALL_DIR}"
    echo -e "  ${CYAN}Service Name:${RESET}       ${SERVICE_NAME}"
    echo -e "  ${CYAN}Default Map:${RESET}        ${DEFAULT_MAP}"
    echo -e "  ${CYAN}Max Players:${RESET}        ${MAX_PLAYERS}"
    echo -e "  ${CYAN}Game Port:${RESET}          ${GAME_PORT}"
    echo -e "  ${CYAN}GSLT Status:${RESET}        ${gslt_status}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Game Modes:${RESET}"
    echo -e "  ${DIM}game_type 0, game_mode 0${RESET} - Casual"
    echo -e "  ${DIM}game_type 0, game_mode 1${RESET} - Competitive"
    echo -e "  ${DIM}game_type 1, game_mode 0${RESET} - Arms Race"
    echo -e "  ${DIM}game_type 1, game_mode 1${RESET} - Demolition"
    echo -e "  ${DIM}game_type 1, game_mode 2${RESET} - Deathmatch"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Default Credentials (CHANGE THESE!):${RESET}"
    echo -e "  ${YELLOW}RCON Password:${RESET}      ${RCON_PASSWORD}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Useful Commands:${RESET}"
    echo -e "  ${GREEN}Start server:${RESET}    systemctl start ${SERVICE_NAME}"
    echo -e "  ${GREEN}Stop server:${RESET}     systemctl stop ${SERVICE_NAME}"
    echo -e "  ${GREEN}Restart server:${RESET}  systemctl restart ${SERVICE_NAME}"
    echo -e "  ${GREEN}Server status:${RESET}   systemctl status ${SERVICE_NAME}"
    echo -e "  ${GREEN}View console:${RESET}    screen -r ${SCREEN_NAME}"
    echo ""
    echo -e "${BOLD}Configuration Files:${RESET}"
    echo -e "  ${DIM}Server config:${RESET}   ${INSTALL_DIR}/game/csgo/cfg/server.cfg"
    echo -e "  ${DIM}GSLT config:${RESET}     ${CONFIG_FILE}"
    echo ""

    if [[ -z "$STEAM_GSLT_TOKEN" ]]; then
        separator "-" 60
        echo ""
        echo -e "${YELLOW}IMPORTANT:${RESET} CS2 requires a GSLT to function properly."
        echo -e "Add your GSLT to: ${CONFIG_FILE}"
        echo ""
        echo "Then restart the service: systemctl restart ${SERVICE_NAME}"
    fi

    separator "-" 60
    echo ""
    echo -e "${YELLOW}Firewall:${RESET} Open these ports if using a firewall:"
    echo -e "  ufw allow ${GAME_PORT}/tcp"
    echo -e "  ufw allow ${GAME_PORT}/udp"
    echo -e "  ufw allow ${TV_PORT}/udp   # SourceTV"
    echo ""
    separator "=" 60
    echo ""

    log_to_file "COMPLETE" "${GAME_NAME} server setup finished successfully"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    log_header "${GAME_NAME} Server Setup"
    log_to_file "START" "Beginning ${GAME_NAME} server installation"

    check_prerequisites
    setup_steamcmd
    download_game_files
    configure_steam_token
    setup_systemd_service
    start_service
    show_summary

    return 0
}

# Run main function
main "$@"
