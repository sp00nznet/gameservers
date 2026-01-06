#!/bin/bash
#
# Unreal Tournament 2004 Dedicated Server Setup
# Downloads, configures, and runs a UT2004 server
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="Unreal Tournament 2004"
readonly SERVICE_NAME="ut2004server"
readonly INSTALL_DIR="/opt/ut2004server"
readonly WORKING_DIR="${INSTALL_DIR}/System"
readonly SERVER_BINARY="${INSTALL_DIR}/System/ucc-bin"

# Game server settings
readonly SERVER_NAME="Silverware UT2004 Server"
readonly DEFAULT_MAP="DM-Rankin"
readonly MAX_PLAYERS="16"
readonly ADMIN_PASSWORD="changeme"

# Network ports
readonly GAME_PORT="7777"
readonly QUERY_PORT="7778"
readonly WEB_ADMIN_PORT="8075"
readonly GAME_SPY_PORT="10777"

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
        log_info "Run: apt-get install lib32gcc-s1 libstdc++6:i386 if needed"
    fi

    log_success "All prerequisites satisfied"
}

# Download server files
download_game_files() {
    log_step 2 6 "Preparing ${GAME_NAME} server directory..."

    # Create install directory if needed
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating install directory: ${INSTALL_DIR}"
        mkdir -p "$INSTALL_DIR"
        mkdir -p "${INSTALL_DIR}/System"
        mkdir -p "${INSTALL_DIR}/Maps"
        mkdir -p "${INSTALL_DIR}/Textures"
        mkdir -p "${INSTALL_DIR}/Sounds"
        mkdir -p "${INSTALL_DIR}/Music"
        mkdir -p "${INSTALL_DIR}/Animations"
        mkdir -p "${INSTALL_DIR}/StaticMeshes"
    fi

    echo ""
    separator "-" 60
    echo -e "${YELLOW}UT2004 Server Installation${RESET}"
    echo ""
    echo "UT2004 dedicated server requires original game files."
    echo ""
    echo "You need to manually copy the following from your UT2004 install:"
    echo "  - System folder (including ucc-bin)"
    echo "  - Maps folder"
    echo "  - Textures folder"
    echo "  - Sounds folder"
    echo "  - Music folder"
    echo "  - Animations folder"
    echo "  - StaticMeshes folder"
    echo ""
    echo "Copy these to: ${INSTALL_DIR}"
    echo ""
    separator "-" 60
    echo ""

    log_warn "Manual file copy required. See instructions above."
}

# Create server configuration
create_config() {
    log_step 3 6 "Creating server configuration..."

    local ini_file="${INSTALL_DIR}/System/UT2004.ini"

    if [[ -f "$ini_file" ]]; then
        # Update admin password
        sed -i "s/AdminPassword=.*/AdminPassword=${ADMIN_PASSWORD}/" "$ini_file" 2>/dev/null || true
    else
        log_info "Configuration file will be created when game files are copied"
    fi

    log_success "Configuration prepared"
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
ExecStart=/usr/bin/screen -dmS "${SCREEN_NAME}" ${SERVER_BINARY} server ${DEFAULT_MAP}?game=XGame.xDeathMatch?MaxPlayers=${MAX_PLAYERS} -nohomedir
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

# Enable service (but don't start - no files yet)
prepare_service() {
    log_step 5 6 "Preparing service..."

    systemctl daemon-reload
    log_info "Service file created but not started (game files needed first)"
    log_success "Service prepared"
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
    echo -e "  ${CYAN}Query Port:${RESET}         ${QUERY_PORT}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Default Credentials (CHANGE THESE!):${RESET}"
    echo -e "  ${YELLOW}Admin Password:${RESET}     ${ADMIN_PASSWORD}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Next Steps:${RESET}"
    echo -e "  1. Copy UT2004 game files to ${INSTALL_DIR}"
    echo -e "  2. Make binary executable: chmod +x ${SERVER_BINARY}"
    echo -e "  3. Start the server: systemctl start ${SERVICE_NAME}"
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
    echo -e "  ${DIM}Server config:${RESET}   ${INSTALL_DIR}/System/UT2004.ini"
    echo ""
    echo -e "${BOLD}Game Modes:${RESET}"
    echo -e "  ${DIM}Deathmatch:${RESET}      XGame.xDeathMatch"
    echo -e "  ${DIM}Team DM:${RESET}         XGame.xTeamGame"
    echo -e "  ${DIM}CTF:${RESET}             XGame.xCTFGame"
    echo -e "  ${DIM}Bombing Run:${RESET}     XGame.xBombingRun"
    echo -e "  ${DIM}Double Dom:${RESET}      XGame.xDoubleDom"
    echo -e "  ${DIM}Onslaught:${RESET}       Onslaught.ONSOnslaughtGame"
    echo -e "  ${DIM}Assault:${RESET}         UT2k4Assault.UT2k4AssaultGame"
    separator "-" 60
    echo ""
    echo -e "${YELLOW}Firewall:${RESET} Open these ports if using a firewall:"
    echo -e "  ufw allow ${GAME_PORT}/udp"
    echo -e "  ufw allow ${QUERY_PORT}/udp"
    echo -e "  ufw allow ${WEB_ADMIN_PORT}/tcp  # Web admin"
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
    download_game_files
    create_config
    setup_systemd_service
    prepare_service
    show_summary

    return 0
}

# Run main function
main "$@"
