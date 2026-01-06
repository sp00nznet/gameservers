#!/bin/bash
#
# San Andreas Multiplayer (SA:MP) Dedicated Server Setup
# Downloads, configures, and runs a SA:MP server
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="San Andreas Multiplayer"
readonly SERVICE_NAME="sampserver"
readonly INSTALL_DIR="/opt/sampserver"
readonly WORKING_DIR="${INSTALL_DIR}"
readonly SERVER_BINARY="${INSTALL_DIR}/samp03svr"

# Download URL for SA:MP server
readonly SAMP_SERVER_URL="https://files.sa-mp.com/samp037svr_R2-1.tar.gz"

# Game server settings
readonly SERVER_NAME="Silverware SA:MP Server"
readonly MAX_PLAYERS="50"
readonly RCON_PASSWORD="changeme"

# Network ports
readonly GAME_PORT="7777"

# Screen session name
readonly SCREEN_NAME="${SERVICE_NAME}"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Validate prerequisites
check_prerequisites() {
    log_step 1 6 "Checking prerequisites..."

    local deps=("curl" "tar" "screen" "systemctl" "wget")

    if ! check_dependencies "${deps[@]}"; then
        log_error "Missing dependencies. Please install them first."
        exit 1
    fi

    # Check for 32-bit libraries
    if [[ $(uname -m) == "x86_64" ]]; then
        log_info "64-bit system detected. Ensure 32-bit libraries are installed."
        log_info "Run: apt-get install lib32gcc-s1 lib32stdc++6 if needed"
    fi

    log_success "All prerequisites satisfied"
}

# Download server files
download_game_files() {
    log_step 2 6 "Downloading ${GAME_NAME} server files..."

    # Create install directory if needed
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating install directory: ${INSTALL_DIR}"
        mkdir -p "$INSTALL_DIR"
    fi

    # Download SA:MP server
    local archive_file="/tmp/samp-server.tar.gz"

    log_info "Downloading SA:MP server..."
    if ! wget -q -O "$archive_file" "$SAMP_SERVER_URL"; then
        log_error "Failed to download SA:MP server files"
        exit 1
    fi

    log_info "Extracting server files..."
    tar -xzf "$archive_file" -C "$INSTALL_DIR" --strip-components=1
    rm -f "$archive_file"

    # Make server binary executable
    chmod +x "${SERVER_BINARY}" 2>/dev/null || true

    log_success "Server files downloaded"
}

# Create server configuration
create_config() {
    log_step 3 6 "Creating server configuration..."

    local config_file="${INSTALL_DIR}/server.cfg"

    cat > "$config_file" << EOF
echo Executing Server Config...
lanmode 0
rcon_password ${RCON_PASSWORD}
maxplayers ${MAX_PLAYERS}
port ${GAME_PORT}
hostname ${SERVER_NAME}
gamemode0 grandlarc 1
filterscripts base gl_actions gl_realtime
announce 1
chatlogging 0
weburl www.sa-mp.com
onfoot_rate 40
incar_rate 40
weapon_rate 40
stream_distance 300.0
stream_rate 1000
maxnpc 0
logtimeformat [%H:%M:%S]
EOF

    log_success "Configuration created"
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
ExecStart=/usr/bin/screen -dmS "${SCREEN_NAME}" ${SERVER_BINARY}
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
    echo -e "  ${DIM}Server config:${RESET}   ${INSTALL_DIR}/server.cfg"
    echo ""
    echo -e "${BOLD}Gamemodes:${RESET}"
    echo -e "  ${DIM}Located in:${RESET}      ${INSTALL_DIR}/gamemodes/"
    echo -e "  ${DIM}Default:${RESET}         grandlarc"
    separator "-" 60
    echo ""
    echo -e "${YELLOW}Firewall:${RESET} Open these ports if using a firewall:"
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
    download_game_files
    create_config
    setup_systemd_service
    start_service
    show_summary

    return 0
}

# Run main function
main "$@"
