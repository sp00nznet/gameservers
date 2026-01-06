#!/bin/bash
#
# Half-Life 2: Deathmatch Dedicated Server Setup
# Downloads, configures, and runs an HL2DM server using SteamCMD
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="Half-Life 2: Deathmatch"
readonly SERVICE_NAME="hl2dmserver"
readonly STEAM_APP_ID="232370"
readonly INSTALL_DIR="/opt/hl2dmserver"
readonly WORKING_DIR="${INSTALL_DIR}"
readonly SERVER_BINARY="${INSTALL_DIR}/srcds_run"

# Game server settings
readonly SERVER_NAME="Silverware HL2DM Server"
readonly DEFAULT_MAP="dm_lockdown"
readonly MAX_PLAYERS="16"
readonly SERVER_PASSWORD=""
readonly RCON_PASSWORD="changeme"

# Network ports
readonly GAME_PORT="27015"
readonly CLIENT_PORT="27005"

# Steam Game Server Login Token (GSLT)
# Get your token from: https://steamcommunity.com/dev/managegameservers
# App ID for HL2DM: 320
STEAM_GSLT_TOKEN="${STEAM_GSLT_TOKEN:-}"

# Screen session name
readonly SCREEN_NAME="${SERVICE_NAME}"

# Config file for storing token
readonly CONFIG_FILE="${INSTALL_DIR}/hl2dmserver.conf"

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

    # Check for 32-bit libraries
    if [[ $(uname -m) == "x86_64" ]]; then
        log_info "64-bit system detected. Ensure 32-bit libraries are installed."
        log_info "Run: apt-get install lib32gcc-s1 if needed"
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
    echo "A GSLT is required for your server to appear in the public"
    echo "server browser. Get one from:"
    echo -e "  ${CYAN}https://steamcommunity.com/dev/managegameservers${RESET}"
    echo ""
    echo "Use App ID: 320 (Half-Life 2: Deathmatch)"
    echo ""
    separator "-" 60
    echo ""

    echo -en "${CYAN}Enter your GSLT (or press Enter to skip): ${RESET}"
    read -r token_input

    if [[ -n "$token_input" ]]; then
        STEAM_GSLT_TOKEN="$token_input"

        # Save to config file
        mkdir -p "$(dirname "$CONFIG_FILE")"
        echo "# HL2DM Server Configuration" > "$CONFIG_FILE"
        echo "STEAM_GSLT_TOKEN=\"${STEAM_GSLT_TOKEN}\"" >> "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"

        log_success "GSLT saved to ${CONFIG_FILE}"
    else
        log_warn "No GSLT provided. Server will not appear in public browser."
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
ExecStart=/usr/bin/screen -dmS "${SCREEN_NAME}" ${SERVER_BINARY} -console -game hl2mp +map ${DEFAULT_MAP} +maxplayers ${MAX_PLAYERS} +port ${GAME_PORT} +sv_lan 0 +rcon_password "${RCON_PASSWORD}" ${gslt_param}
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
    echo -e "  ${DIM}Server config:${RESET}   ${INSTALL_DIR}/hl2mp/cfg/server.cfg"
    echo -e "  ${DIM}GSLT config:${RESET}     ${CONFIG_FILE}"
    echo ""

    if [[ -z "$STEAM_GSLT_TOKEN" ]]; then
        separator "-" 60
        echo ""
        echo -e "${YELLOW}Note:${RESET} To make your server public, add your GSLT to:"
        echo -e "  ${CONFIG_FILE}"
        echo ""
        echo "Then restart the service: systemctl restart ${SERVICE_NAME}"
    fi

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
    configure_steam_token
    setup_systemd_service
    start_service
    show_summary

    return 0
}

# Run main function
main "$@"
