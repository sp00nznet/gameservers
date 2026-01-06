#!/bin/bash
#
# Counter-Strike 1.6 Dedicated Server Setup
# Downloads, configures, and runs a CS 1.6 server using SteamCMD
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="Counter-Strike 1.6"
readonly SERVICE_NAME="csserver"
readonly STEAM_APP_ID="90"
readonly INSTALL_DIR="/opt/csserver"
readonly WORKING_DIR="${INSTALL_DIR}"
readonly SERVER_BINARY="${INSTALL_DIR}/hlds_run"

# Game server settings
readonly SERVER_NAME="Silverware CS Server"
readonly DEFAULT_MAP="de_dust2"
readonly MAX_PLAYERS="20"
readonly SERVER_PASSWORD=""
readonly RCON_PASSWORD="changeme"

# Network ports
readonly GAME_PORT="27015"
readonly CLIENT_PORT="27005"

# Screen session name
readonly SCREEN_NAME="${SERVICE_NAME}"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Validate prerequisites
check_prerequisites() {
    log_step 1 6 "Checking prerequisites..."

    local deps=("curl" "tar" "screen" "systemctl")

    if ! check_dependencies "${deps[@]}"; then
        log_error "Missing dependencies. Please install them first."
        exit 1
    fi

    # Check for 32-bit libraries
    if [[ $(uname -m) == "x86_64" ]]; then
        log_info "64-bit system detected. Ensure 32-bit libraries are installed."
        log_info "Run: apt-get install lib32gcc-s1 if needed"
    fi

    log_success "All prerequisites satisfied"
}

# Install SteamCMD
setup_steamcmd() {
    log_step 2 6 "Setting up SteamCMD..."

    if ! install_steamcmd; then
        log_error "Failed to install SteamCMD"
        exit 1
    fi
}

# Download/update game files
download_game_files() {
    log_step 3 6 "Downloading ${GAME_NAME} server files..."

    # Create install directory if needed
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating install directory: ${INSTALL_DIR}"
        mkdir -p "$INSTALL_DIR"
    fi

    if ! run_steamcmd "$INSTALL_DIR" "$STEAM_APP_ID" "+app_set_config 90 mod cstrike"; then
        log_error "Failed to download game files"
        exit 1
    fi

    log_success "Game files downloaded"
}

# Generate systemd service file content
generate_service_file() {
    cat << EOF
[Unit]
Description=${GAME_NAME} Dedicated Server
After=network.target

[Service]
Type=forking
User=root
WorkingDirectory=${WORKING_DIR}
ExecStart=/usr/bin/screen -dmS "${SCREEN_NAME}" ${SERVER_BINARY} -game cstrike +map ${DEFAULT_MAP} +maxplayers ${MAX_PLAYERS} +port ${GAME_PORT} +sv_lan 0 +rcon_password "${RCON_PASSWORD}"
ExecStop=/usr/bin/screen -S "${SCREEN_NAME}" -X quit
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# Create systemd service
setup_systemd_service() {
    log_step 4 6 "Creating systemd service..."

    local service_content
    service_content="$(generate_service_file)"

    if ! create_systemd_service "$SERVICE_NAME" "$service_content"; then
        log_error "Failed to create systemd service"
        exit 1
    fi
}

# Enable and start the service
start_service() {
    log_step 5 6 "Enabling and starting service..."

    if ! enable_service "$SERVICE_NAME"; then
        log_error "Failed to start service"
        exit 1
    fi
}

# Display completion summary
show_summary() {
    log_step 6 6 "Setup complete!"

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
    echo -e "  ${DIM}Server config:${RESET}   ${INSTALL_DIR}/cstrike/server.cfg"
    echo ""
    separator "-" 60
    echo ""
    echo -e "${YELLOW}Firewall:${RESET} Open these ports if using a firewall:"
    echo -e "  ufw allow ${GAME_PORT}/tcp"
    echo -e "  ufw allow ${GAME_PORT}/udp"
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
    setup_systemd_service
    start_service
    show_summary

    return 0
}

# Run main function
main "$@"
