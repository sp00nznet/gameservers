#!/bin/bash
#
# Team Fortress 2 Dedicated Server Setup (Docker)
# Builds and runs a TF2 server in a Docker container
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="Team Fortress 2"
readonly CONTAINER_NAME="tf2server"
readonly IMAGE_NAME="gameservers/tf2"
readonly STEAM_APP_ID="232250"
readonly INSTALL_DIR="/home/steam/tf2server"

# Game server settings
readonly DEFAULT_MAP="ctf_2fort"
readonly MAX_PLAYERS="24"
readonly SV_PURE="1"
readonly GAME_MODE="tf"

# Network ports
readonly GAME_PORT="27015"

# Steam Game Server Login Token (GSLT)
# Get your token from: https://steamcommunity.com/dev/managegameservers
# Required for public server listing
STEAM_GSLT_TOKEN="${STEAM_GSLT_TOKEN:-}"

# Data directory for persistent storage
DATA_DIR=""

# =============================================================================
# FUNCTIONS
# =============================================================================

# Validate prerequisites
check_prerequisites() {
    log_step 1 6 "Checking prerequisites..."

    if ! check_docker; then
        log_error "Docker is required. Please install Docker first."
        exit 1
    fi

    log_success "All prerequisites satisfied"
}

# Prompt for Steam GSLT token
configure_steam_token() {
    log_step 2 6 "Configuring Steam Game Server Login Token..."

    local config_file="${DATA_DIR}/tf2server.conf"

    # Check if token is already set via environment variable
    if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
        log_info "Using GSLT from environment variable"
        return 0
    fi

    # Check if token exists in config file
    if [[ -f "$config_file" ]]; then
        source "$config_file"
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
    echo "Use App ID: 440 (Team Fortress 2)"
    echo ""
    separator "-" 60
    echo ""

    echo -en "${CYAN}Enter your GSLT (or press Enter to skip): ${RESET}"
    read -r token_input

    if [[ -n "$token_input" ]]; then
        STEAM_GSLT_TOKEN="$token_input"

        # Save to config file
        echo "# TF2 Server Configuration" > "$config_file"
        echo "STEAM_GSLT_TOKEN=\"${STEAM_GSLT_TOKEN}\"" >> "$config_file"
        chmod 600 "$config_file"

        log_success "GSLT saved to ${config_file}"
    else
        log_warn "No GSLT provided. Server will not appear in public browser."
        log_info "You can set it later in: ${config_file}"
    fi
}

# Generate Dockerfile for TF2 server
generate_dockerfile() {
    local gslt_param=""
    if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
        gslt_param="+sv_setsteamaccount ${STEAM_GSLT_TOKEN}"
    fi

    cat << EOF
FROM debian:bookworm-slim

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN dpkg --add-architecture i386 && \\
    apt-get update && \\
    apt-get install -y --no-install-recommends \\
        ca-certificates \\
        curl \\
        lib32gcc-s1 \\
        lib32stdc++6 \\
        libsdl2-2.0-0:i386 \\
        locales \\
    && rm -rf /var/lib/apt/lists/* \\
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

# Create steamcmd user
RUN useradd -m -s /bin/bash steam
WORKDIR /home/steam

# Install SteamCMD
RUN mkdir -p /home/steam/steamcmd && \\
    cd /home/steam/steamcmd && \\
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - && \\
    chown -R steam:steam /home/steam

# Create game directory
RUN mkdir -p ${INSTALL_DIR} && chown -R steam:steam ${INSTALL_DIR}

USER steam

# Install game server
RUN /home/steam/steamcmd/steamcmd.sh \\
    +force_install_dir ${INSTALL_DIR} \\
    +login anonymous \\
    +app_update ${STEAM_APP_ID} validate \\
    +quit

WORKDIR ${INSTALL_DIR}

# Expose ports
EXPOSE ${GAME_PORT}/tcp ${GAME_PORT}/udp

# Start server
CMD ["./srcds_run", "-console", "-game", "${GAME_MODE}", "+sv_pure", "${SV_PURE}", "+map", "${DEFAULT_MAP}", "+maxplayers", "${MAX_PLAYERS}", "${gslt_param}"]
EOF
}

# Build Docker image
build_image() {
    log_step 3 6 "Building Docker image..."
    log_info "This may take a while for the initial build (~15GB download)..."

    local dockerfile
    dockerfile="$(generate_dockerfile)"

    if ! build_docker_image "$IMAGE_NAME" "$dockerfile"; then
        log_error "Failed to build Docker image"
        exit 1
    fi
}

# Create server configuration directory
setup_data_directory() {
    log_step 4 6 "Setting up data directory..."

    DATA_DIR=$(create_game_data_dir "tf2")

    # Create config directories
    mkdir -p "${DATA_DIR}/tf/cfg"

    # Create default server.cfg if it doesn't exist
    local server_cfg="${DATA_DIR}/tf/cfg/server.cfg"
    if [[ ! -f "$server_cfg" ]]; then
        log_info "Creating default server.cfg..."
        cat > "$server_cfg" << EOF
// TF2 Server Configuration
// Generated by Silverware Game Servers

hostname "Silverware TF2 Server"
sv_password ""
rcon_password "changeme"

// Network settings
sv_maxrate 0
sv_minrate 0
sv_maxupdaterate 66
sv_minupdaterate 10

// Server settings
mp_autoteambalance 1
mp_teams_unbalance_limit 1
mp_idlemaxtime 3
mp_idledealmethod 1

// Communication
sv_alltalk 0
sv_voiceenable 1
EOF
        log_success "Default server.cfg created"
    else
        log_info "Using existing server.cfg"
    fi

    log_success "Data directory ready: ${DATA_DIR}"
}

# Run the Docker container
run_container() {
    log_step 5 6 "Starting Docker container..."

    local gslt_param=""
    if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
        gslt_param="+sv_setsteamaccount ${STEAM_GSLT_TOKEN}"
    fi

    local port_mappings="-p ${GAME_PORT}:${GAME_PORT}/tcp -p ${GAME_PORT}:${GAME_PORT}/udp"
    local volume_mappings="-v ${DATA_DIR}/tf/cfg:${INSTALL_DIR}/tf/cfg"

    # Build the CMD with proper argument handling
    local cmd_args="./srcds_run -console -game ${GAME_MODE} +sv_pure ${SV_PURE} +map ${DEFAULT_MAP} +maxplayers ${MAX_PLAYERS}"
    if [[ -n "$gslt_param" ]]; then
        cmd_args="${cmd_args} ${gslt_param}"
    fi

    if ! run_docker_container "$CONTAINER_NAME" "$IMAGE_NAME" "$port_mappings" "$volume_mappings" "-it"; then
        log_error "Failed to start container"
        exit 1
    fi

    # Give it a moment to start
    sleep 2

    if container_is_running "$CONTAINER_NAME"; then
        log_success "Container is running"
    else
        log_error "Container failed to start. Check logs with: docker logs ${CONTAINER_NAME}"
        exit 1
    fi
}

# Display completion summary
show_summary() {
    log_step 6 6 "Setup complete!"

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
    echo -e "  ${CYAN}Container Name:${RESET}     ${CONTAINER_NAME}"
    echo -e "  ${CYAN}Image Name:${RESET}         ${IMAGE_NAME}"
    echo -e "  ${CYAN}Data Directory:${RESET}     ${DATA_DIR}"
    echo -e "  ${CYAN}Default Map:${RESET}        ${DEFAULT_MAP}"
    echo -e "  ${CYAN}Max Players:${RESET}        ${MAX_PLAYERS}"
    echo -e "  ${CYAN}SV_Pure:${RESET}            ${SV_PURE}"
    echo -e "  ${CYAN}GSLT Status:${RESET}        ${gslt_status}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Network Ports:${RESET}"
    echo -e "  ${CYAN}Game Port:${RESET}          ${GAME_PORT}/tcp, ${GAME_PORT}/udp"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Useful Commands:${RESET}"
    echo -e "  ${GREEN}Start server:${RESET}    docker start ${CONTAINER_NAME}"
    echo -e "  ${GREEN}Stop server:${RESET}     docker stop ${CONTAINER_NAME}"
    echo -e "  ${GREEN}Restart server:${RESET}  docker restart ${CONTAINER_NAME}"
    echo -e "  ${GREEN}Server status:${RESET}   docker ps -f name=${CONTAINER_NAME}"
    echo -e "  ${GREEN}View logs:${RESET}       docker logs -f ${CONTAINER_NAME}"
    echo -e "  ${GREEN}Console access:${RESET}  docker attach ${CONTAINER_NAME}"
    echo ""
    echo -e "${BOLD}Configuration Files:${RESET}"
    echo -e "  ${DIM}Server config:${RESET}   ${DATA_DIR}/tf/cfg/server.cfg"
    echo -e "  ${DIM}GSLT config:${RESET}     ${DATA_DIR}/tf2server.conf"
    echo ""

    if [[ -z "$STEAM_GSLT_TOKEN" ]]; then
        separator "-" 60
        echo ""
        echo -e "${YELLOW}Note:${RESET} To make your server public, add your GSLT to:"
        echo -e "  ${DATA_DIR}/tf2server.conf"
        echo ""
        echo "Then rebuild the image and restart the container:"
        echo "  ${SCRIPT_DIR}/tf2-server-setup.sh"
    fi

    separator "=" 60
    echo ""

    log_to_file "COMPLETE" "${GAME_NAME} Docker server setup finished successfully"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    log_header "${GAME_NAME} Server Setup (Docker)"
    log_to_file "START" "Beginning ${GAME_NAME} Docker server installation"

    check_prerequisites
    setup_data_directory
    configure_steam_token
    build_image
    run_container
    show_summary

    return 0
}

# Run main function
main "$@"
