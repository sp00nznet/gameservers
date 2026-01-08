#!/bin/bash
#
# Half-Life 2: Deathmatch Dedicated Server Setup (Docker)
# Builds and runs an HL2DM server in a Docker container
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
readonly CONTAINER_NAME="hl2dmserver"
readonly IMAGE_NAME="gameservers/hl2dm"
readonly STEAM_APP_ID="232370"
readonly INSTALL_DIR="/home/steam/hl2dmserver"

# Game server settings
readonly SERVER_NAME="Silverware HL2DM Server"
readonly DEFAULT_MAP="dm_lockdown"
readonly MAX_PLAYERS="16"
readonly RCON_PASSWORD="changeme"

# Network ports
readonly GAME_PORT="27015"

# Steam Game Server Login Token (GSLT)
STEAM_GSLT_TOKEN="${STEAM_GSLT_TOKEN:-}"

# Data directory for persistent storage
DATA_DIR=""

# =============================================================================
# FUNCTIONS
# =============================================================================

check_prerequisites() {
    log_step 1 6 "Checking prerequisites..."

    if ! check_docker; then
        log_error "Docker is required. Please install Docker first."
        exit 1
    fi

    log_success "All prerequisites satisfied"
}

configure_steam_token() {
    log_step 2 6 "Configuring Steam Game Server Login Token..."

    local config_file="${DATA_DIR}/hl2dmserver.conf"

    if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
        log_info "Using GSLT from environment variable"
        return 0
    fi

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
    echo "Use App ID: 320 (Half-Life 2: Deathmatch)"
    echo ""
    separator "-" 60
    echo ""

    echo -en "${CYAN}Enter your GSLT (or press Enter to skip): ${RESET}"
    read -r token_input

    if [[ -n "$token_input" ]]; then
        STEAM_GSLT_TOKEN="$token_input"
        echo "# HL2DM Server Configuration" > "$config_file"
        echo "STEAM_GSLT_TOKEN=\"${STEAM_GSLT_TOKEN}\"" >> "$config_file"
        chmod 600 "$config_file"
        log_success "GSLT saved to ${config_file}"
    else
        log_warn "No GSLT provided. Server will not appear in public browser."
    fi
}

generate_dockerfile() {
    cat << 'EOF'
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        lib32gcc-s1 \
        lib32stdc++6 \
        libsdl2-2.0-0:i386 \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

RUN useradd -m -s /bin/bash steam
WORKDIR /home/steam

RUN mkdir -p /home/steam/steamcmd && \
    cd /home/steam/steamcmd && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - && \
    chown -R steam:steam /home/steam

RUN mkdir -p /home/steam/hl2dmserver && chown -R steam:steam /home/steam/hl2dmserver

USER steam

RUN /home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/steam/hl2dmserver \
    +login anonymous \
    +app_update 232370 validate \
    +quit

WORKDIR /home/steam/hl2dmserver

EXPOSE 27015/tcp 27015/udp

ENTRYPOINT ["./srcds_run", "-console", "-game", "hl2mp"]
EOF
}

build_image() {
    log_step 3 6 "Building Docker image..."
    log_info "This may take a while for the initial build..."

    local dockerfile
    dockerfile="$(generate_dockerfile)"

    if ! build_docker_image "$IMAGE_NAME" "$dockerfile"; then
        log_error "Failed to build Docker image"
        exit 1
    fi
}

setup_data_directory() {
    log_step 4 6 "Setting up data directory..."

    DATA_DIR=$(create_game_data_dir "hl2dm")
    mkdir -p "${DATA_DIR}/hl2mp/cfg"

    local server_cfg="${DATA_DIR}/hl2mp/cfg/server.cfg"
    if [[ ! -f "$server_cfg" ]]; then
        log_info "Creating default server.cfg..."
        cat > "$server_cfg" << EOF
// HL2DM Server Configuration
hostname "${SERVER_NAME}"
sv_password ""
rcon_password "${RCON_PASSWORD}"
sv_lan 0
sv_cheats 0
EOF
        log_success "Default server.cfg created"
    fi

    log_success "Data directory ready: ${DATA_DIR}"
}

run_container() {
    log_step 5 6 "Starting Docker container..."

    local gslt_param=""
    if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
        gslt_param="+sv_setsteamaccount ${STEAM_GSLT_TOKEN}"
    fi

    local port_mappings="-p ${GAME_PORT}:${GAME_PORT}/tcp -p ${GAME_PORT}:${GAME_PORT}/udp"
    local volume_mappings="-v ${DATA_DIR}/hl2mp/cfg:${INSTALL_DIR}/hl2mp/cfg"
    local extra_args="+map ${DEFAULT_MAP} +maxplayers ${MAX_PLAYERS} +port ${GAME_PORT} +sv_lan 0 +rcon_password ${RCON_PASSWORD} ${gslt_param}"

    if ! run_docker_container "$CONTAINER_NAME" "$IMAGE_NAME" "$port_mappings" "$volume_mappings" "$extra_args"; then
        log_error "Failed to start container"
        exit 1
    fi

    sleep 2
    if container_is_running "$CONTAINER_NAME"; then
        log_success "Container is running"
    else
        log_error "Container failed to start. Check logs with: docker logs ${CONTAINER_NAME}"
        exit 1
    fi
}

show_summary() {
    log_step 6 6 "Setup complete!"

    local gslt_status="${RED}Not configured${RESET}"
    if [[ -n "$STEAM_GSLT_TOKEN" ]]; then
        gslt_status="${GREEN}Configured${RESET}"
    fi

    echo ""
    separator "=" 60
    echo -e "${BOLD}${GAME_NAME} Server Installation Summary${RESET}"
    separator "-" 60
    echo -e "  ${CYAN}Container Name:${RESET}     ${CONTAINER_NAME}"
    echo -e "  ${CYAN}Image Name:${RESET}         ${IMAGE_NAME}"
    echo -e "  ${CYAN}Data Directory:${RESET}     ${DATA_DIR}"
    echo -e "  ${CYAN}Default Map:${RESET}        ${DEFAULT_MAP}"
    echo -e "  ${CYAN}Max Players:${RESET}        ${MAX_PLAYERS}"
    echo -e "  ${CYAN}Game Port:${RESET}          ${GAME_PORT}"
    echo -e "  ${CYAN}GSLT Status:${RESET}        ${gslt_status}"
    separator "-" 60
    echo -e "${BOLD}Useful Commands:${RESET}"
    echo -e "  ${GREEN}Start server:${RESET}    docker start ${CONTAINER_NAME}"
    echo -e "  ${GREEN}Stop server:${RESET}     docker stop ${CONTAINER_NAME}"
    echo -e "  ${GREEN}View logs:${RESET}       docker logs -f ${CONTAINER_NAME}"
    echo -e "  ${GREEN}Console access:${RESET}  docker attach ${CONTAINER_NAME}"
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

main "$@"
