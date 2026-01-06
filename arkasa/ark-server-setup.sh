#!/bin/bash
#
# ARK: Survival Ascended Dedicated Server Setup
# Downloads, configures, and runs an ARK ASA server using SteamCMD
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="ARK: Survival Ascended"
readonly SERVICE_NAME="arkserver"
readonly STEAM_APP_ID="2430930"
readonly INSTALL_DIR="/opt/arkserver"
readonly WORKING_DIR="${INSTALL_DIR}/ShooterGame/Binaries/Win64"
readonly SERVER_BINARY="${WORKING_DIR}/ArkAscendedServer.exe"

# Game server settings
readonly SERVER_NAME="Silverware ARK Server"
readonly SERVER_PASSWORD=""
readonly ADMIN_PASSWORD="changeme"
readonly MAX_PLAYERS="70"
readonly DEFAULT_MAP="TheIsland_WP"

# Network ports
readonly GAME_PORT="7777"
readonly QUERY_PORT="27015"
readonly RCON_PORT="27020"
readonly RCON_ENABLED="True"

# =============================================================================
# MODS CONFIGURATION
# =============================================================================
# Add CurseForge mod IDs here (comma-separated, no spaces)
# Find mod IDs on CurseForge: curseforge.com/ark-survival-ascended
#
# Example popular mods:
#   928793   - Structures Plus (S+)
#   900062   - Dino Storage v2
#   893657   - Awesome Spyglass
#
MODS=""

# =============================================================================
# SERVER SETTINGS
# =============================================================================
# Rates and multipliers (adjust as needed)
readonly XP_MULTIPLIER="1.0"
readonly TAMING_SPEED="1.0"
readonly HARVEST_AMOUNT="1.0"
readonly BREEDING_MULTIPLIER="1.0"
readonly MAX_DINO_LEVEL="150"

# Server behavior
readonly ENABLE_PVP="True"
readonly ALLOW_FLYER_CARRY="True"
readonly PREVENT_DOWNLOAD_SURVIVORS="False"
readonly PREVENT_DOWNLOAD_ITEMS="False"
readonly PREVENT_DOWNLOAD_DINOS="False"

# Screen session name
readonly SCREEN_NAME="${SERVICE_NAME}"

# Dedicated user for the server
readonly SERVER_USER="arkuser"

# Proton/Wine configuration (ASA requires Windows compatibility layer)
readonly PROTON_VERSION="GE-Proton8-25"
readonly STEAM_COMPAT_DATA="${INSTALL_DIR}/steamcompat"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Validate prerequisites
check_prerequisites() {
    log_step 1 9 "Checking prerequisites..."

    local deps=("curl" "tar" "screen" "systemctl" "wget")

    if ! check_dependencies "${deps[@]}"; then
        log_error "Missing basic dependencies. Please install them first."
        exit 1
    fi

    # Check system requirements
    local total_ram
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [[ "$total_ram" -lt 16 ]]; then
        log_warn "ARK ASA recommends at least 16GB RAM. You have ${total_ram}GB."
        log_warn "Server may experience performance issues."
    else
        log_info "RAM check passed: ${total_ram}GB available"
    fi

    # Check disk space (ARK ASA needs ~50GB+)
    local available_space
    available_space=$(df -BG /opt | awk 'NR==2 {print $4}' | tr -d 'G')
    if [[ "$available_space" -lt 60 ]]; then
        log_warn "ARK ASA requires ~50GB+ disk space. Only ${available_space}GB available in /opt"
    else
        log_info "Disk space check passed: ${available_space}GB available"
    fi

    log_success "Prerequisites check completed"
}

# Create dedicated user for the server
setup_server_user() {
    log_step 2 9 "Setting up server user..."

    if id "$SERVER_USER" &>/dev/null; then
        log_info "User ${SERVER_USER} already exists"
    else
        log_info "Creating dedicated user: ${SERVER_USER}"
        useradd -m -s /bin/bash "$SERVER_USER"
        log_success "User ${SERVER_USER} created"
    fi
}

# Install SteamCMD
setup_steamcmd() {
    log_step 3 9 "Setting up SteamCMD..."

    if ! install_steamcmd; then
        log_error "Failed to install SteamCMD"
        exit 1
    fi
}

# Install Proton GE for Windows compatibility
setup_proton() {
    log_step 4 9 "Setting up Proton GE for Windows compatibility..."

    local proton_dir="/opt/proton"
    local proton_url="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${PROTON_VERSION}/${PROTON_VERSION}.tar.gz"

    if [[ -d "${proton_dir}/${PROTON_VERSION}" ]]; then
        log_info "Proton GE ${PROTON_VERSION} already installed"
        return 0
    fi

    log_info "Downloading Proton GE ${PROTON_VERSION}..."
    mkdir -p "$proton_dir"
    cd "$proton_dir"

    if ! wget -q --show-progress "$proton_url" -O "${PROTON_VERSION}.tar.gz"; then
        log_error "Failed to download Proton GE"
        exit 1
    fi

    log_info "Extracting Proton GE..."
    tar -xzf "${PROTON_VERSION}.tar.gz"
    rm -f "${PROTON_VERSION}.tar.gz"

    # Create Steam compatibility data directory
    mkdir -p "$STEAM_COMPAT_DATA"

    log_success "Proton GE installed successfully"
}

# Download/update game files
download_game_files() {
    log_step 5 9 "Downloading ${GAME_NAME} server files..."
    log_info "This will take a while (~50GB download)..."

    # Create install directory if needed
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating install directory: ${INSTALL_DIR}"
        mkdir -p "$INSTALL_DIR"
    fi

    if ! run_steamcmd "$INSTALL_DIR" "$STEAM_APP_ID"; then
        log_error "Failed to download game files"
        exit 1
    fi

    # Set ownership to server user
    chown -R "${SERVER_USER}:${SERVER_USER}" "$INSTALL_DIR"

    log_success "Game files downloaded and permissions set"
}

# Create server configuration
configure_server() {
    log_step 6 9 "Configuring server..."

    local config_dir="${INSTALL_DIR}/ShooterGame/Saved/Config/WindowsServer"
    mkdir -p "$config_dir"

    # Create GameUserSettings.ini
    local settings_file="${config_dir}/GameUserSettings.ini"
    log_info "Creating server configuration: ${settings_file}"

    cat > "$settings_file" << EOF
[ServerSettings]
ServerPassword=${SERVER_PASSWORD}
ServerAdminPassword=${ADMIN_PASSWORD}
RCONEnabled=${RCON_ENABLED}
RCONPort=${RCON_PORT}
MaxPlayers=${MAX_PLAYERS}
DifficultyOffset=1.0
NewMaxStructuresInRange=10500.000000
PvEStructureDecayPeriodMultiplier=1.000000
AllowFlyerCarryPvE=${ALLOW_FLYER_CARRY}
bDisableStructureDecayPvE=False
bAllowPlatformSaddleMultiFloors=False
PreventDownloadSurvivors=${PREVENT_DOWNLOAD_SURVIVORS}
PreventDownloadItems=${PREVENT_DOWNLOAD_ITEMS}
PreventDownloadDinos=${PREVENT_DOWNLOAD_DINOS}
bPreventSpawnAnimations=False
ServerPVE=$([[ "$ENABLE_PVP" == "True" ]] && echo "False" || echo "True")

[SessionSettings]
SessionName=${SERVER_NAME}
QueryPort=${QUERY_PORT}
Port=${GAME_PORT}
MultiHome=0.0.0.0

[/Script/ShooterGame.ShooterGameMode]
XPMultiplier=${XP_MULTIPLIER}
TamingSpeedMultiplier=${TAMING_SPEED}
HarvestAmountMultiplier=${HARVEST_AMOUNT}
BabyMatureSpeedMultiplier=${BREEDING_MULTIPLIER}
OverrideOfficialDifficulty=5.0
DifficultyOffset=1.0
DestroyTamesOverLevel=${MAX_DINO_LEVEL}

[MessageOfTheDay]
Duration=20
Message=Welcome to ${SERVER_NAME}!

[ScriptEngineSettings]
EOF

    # Create Game.ini
    local game_ini="${config_dir}/Game.ini"
    log_info "Creating Game.ini: ${game_ini}"

    cat > "$game_ini" << EOF
[/script/shootergame.shootergamemode]
bDisableDinoDecay=False
bDisableStructureDecay=False
bAllowUnlimitedRespecs=True
EOF

    # Create startup script
    local startup_script="${INSTALL_DIR}/start-ark.sh"
    log_info "Creating startup script: ${startup_script}"

    local mods_param=""
    if [[ -n "$MODS" ]]; then
        mods_param="-mods=${MODS}"
    fi

    cat > "$startup_script" << EOF
#!/bin/bash
export STEAM_COMPAT_DATA_PATH="${STEAM_COMPAT_DATA}"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="/opt/steamcmd"

cd "${WORKING_DIR}"

# Run with Proton
/opt/proton/${PROTON_VERSION}/proton run ${SERVER_BINARY} \\
    ${DEFAULT_MAP}?listen \\
    ?SessionName="${SERVER_NAME}" \\
    ?Port=${GAME_PORT} \\
    ?QueryPort=${QUERY_PORT} \\
    ?RCONEnabled=${RCON_ENABLED} \\
    ?RCONPort=${RCON_PORT} \\
    ?ServerPassword="${SERVER_PASSWORD}" \\
    ?ServerAdminPassword="${ADMIN_PASSWORD}" \\
    ?MaxPlayers=${MAX_PLAYERS} \\
    ${mods_param} \\
    -server \\
    -log \\
    -NoBattlEye
EOF

    chmod +x "$startup_script"

    # Set ownership
    chown -R "${SERVER_USER}:${SERVER_USER}" "$INSTALL_DIR"
    chown -R "${SERVER_USER}:${SERVER_USER}" "$STEAM_COMPAT_DATA"

    log_success "Server configured"
}

# Generate systemd service file content
generate_service_file() {
    cat << EOF
[Unit]
Description=${GAME_NAME} Dedicated Server
After=network.target

[Service]
Type=forking
User=${SERVER_USER}
Group=${SERVER_USER}
WorkingDirectory=${INSTALL_DIR}
Environment="STEAM_COMPAT_DATA_PATH=${STEAM_COMPAT_DATA}"
Environment="STEAM_COMPAT_CLIENT_INSTALL_PATH=/opt/steamcmd"
ExecStart=/usr/bin/screen -dmS "${SCREEN_NAME}" ${INSTALL_DIR}/start-ark.sh
ExecStop=/usr/bin/screen -S "${SCREEN_NAME}" -p 0 -X stuff "saveworld^Mquit^M"
ExecStop=/bin/sleep 30
Restart=on-failure
RestartSec=60
TimeoutStartSec=600
TimeoutStopSec=120

[Install]
WantedBy=multi-user.target
EOF
}

# Create systemd service
setup_systemd_service() {
    log_step 7 9 "Creating systemd service..."

    local service_content
    service_content="$(generate_service_file)"

    if ! create_systemd_service "$SERVICE_NAME" "$service_content"; then
        log_error "Failed to create systemd service"
        exit 1
    fi
}

# Enable and start the service
start_service() {
    log_step 8 9 "Enabling and starting service..."

    if ! enable_service "$SERVICE_NAME"; then
        log_error "Failed to start service"
        exit 1
    fi
}

# Display completion summary
show_summary() {
    log_step 9 9 "Setup complete!"

    local mods_status="${DIM}None configured${RESET}"
    if [[ -n "$MODS" ]]; then
        mods_status="${GREEN}${MODS}${RESET}"
    fi

    echo ""
    separator "=" 60
    echo ""
    echo -e "${BOLD}${GAME_NAME} Server Installation Summary${RESET}"
    echo ""
    separator "-" 60
    echo -e "  ${CYAN}Install Directory:${RESET}  ${INSTALL_DIR}"
    echo -e "  ${CYAN}Service Name:${RESET}       ${SERVICE_NAME}"
    echo -e "  ${CYAN}Server Name:${RESET}        ${SERVER_NAME}"
    echo -e "  ${CYAN}Server User:${RESET}        ${SERVER_USER}"
    echo -e "  ${CYAN}Default Map:${RESET}        ${DEFAULT_MAP}"
    echo -e "  ${CYAN}Max Players:${RESET}        ${MAX_PLAYERS}"
    echo -e "  ${CYAN}PvP Mode:${RESET}           ${ENABLE_PVP}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Network Ports:${RESET}"
    echo -e "  ${CYAN}Game Port:${RESET}          ${GAME_PORT}/udp"
    echo -e "  ${CYAN}Query Port:${RESET}         ${QUERY_PORT}/udp"
    echo -e "  ${CYAN}RCON Port:${RESET}          ${RCON_PORT}/tcp"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Server Rates:${RESET}"
    echo -e "  ${CYAN}XP Multiplier:${RESET}      ${XP_MULTIPLIER}x"
    echo -e "  ${CYAN}Taming Speed:${RESET}       ${TAMING_SPEED}x"
    echo -e "  ${CYAN}Harvest Amount:${RESET}     ${HARVEST_AMOUNT}x"
    echo -e "  ${CYAN}Breeding Speed:${RESET}     ${BREEDING_MULTIPLIER}x"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Default Credentials (CHANGE THESE!):${RESET}"
    echo -e "  ${YELLOW}Admin Password:${RESET}     ${ADMIN_PASSWORD}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Mods:${RESET}                 ${mods_status}"
    echo -e "  ${DIM}To add mods, edit the MODS variable in:${RESET}"
    echo -e "  ${CYAN}${SCRIPT_DIR}/ark-server-setup.sh${RESET}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Useful Commands:${RESET}"
    echo -e "  ${GREEN}Start server:${RESET}    systemctl start ${SERVICE_NAME}"
    echo -e "  ${GREEN}Stop server:${RESET}     systemctl stop ${SERVICE_NAME}"
    echo -e "  ${GREEN}Restart server:${RESET}  systemctl restart ${SERVICE_NAME}"
    echo -e "  ${GREEN}Server status:${RESET}   systemctl status ${SERVICE_NAME}"
    echo -e "  ${GREEN}View console:${RESET}    sudo -u ${SERVER_USER} screen -r ${SCREEN_NAME}"
    echo ""
    echo -e "${BOLD}Configuration Files:${RESET}"
    echo -e "  ${DIM}GameUserSettings:${RESET} ${INSTALL_DIR}/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini"
    echo -e "  ${DIM}Game.ini:${RESET}         ${INSTALL_DIR}/ShooterGame/Saved/Config/WindowsServer/Game.ini"
    echo ""
    separator "-" 60
    echo ""
    echo -e "${YELLOW}Firewall:${RESET} Open these ports if using a firewall:"
    echo -e "  ufw allow ${GAME_PORT}/udp"
    echo -e "  ufw allow ${QUERY_PORT}/udp"
    echo -e "  ufw allow ${RCON_PORT}/tcp"
    echo ""
    echo -e "${YELLOW}NOTE:${RESET} First startup may take several minutes as shaders compile."
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
    setup_server_user
    setup_steamcmd
    setup_proton
    download_game_files
    configure_server
    setup_systemd_service
    start_service
    show_summary

    return 0
}

# Run main function
main "$@"
