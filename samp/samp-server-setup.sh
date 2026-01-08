#!/bin/bash
#
# San Andreas Multiplayer (SA:MP) Dedicated Server Setup (Docker)
# Builds and runs a SA:MP server in a Docker container
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
readonly CONTAINER_NAME="sampserver"
readonly IMAGE_NAME="gameservers/samp"
readonly INSTALL_DIR="/home/samp/server"

# Download URL for SA:MP server
readonly SAMP_SERVER_URL="https://files.sa-mp.com/samp037svr_R2-1.tar.gz"

# Game server settings
readonly SERVER_NAME="Silverware SA:MP Server"
readonly MAX_PLAYERS="50"
readonly RCON_PASSWORD="changeme"

# Network ports
readonly GAME_PORT="7777"

# Data directory for persistent storage
DATA_DIR=""

# =============================================================================
# FUNCTIONS
# =============================================================================

check_prerequisites() {
    log_step 1 5 "Checking prerequisites..."

    if ! check_docker; then
        log_error "Docker is required. Please install Docker first."
        exit 1
    fi

    log_success "All prerequisites satisfied"
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
        wget \
        lib32gcc-s1 \
        lib32stdc++6 \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

RUN useradd -m -s /bin/bash samp
WORKDIR /home/samp

RUN mkdir -p /home/samp/server && \
    cd /home/samp/server && \
    wget -q -O /tmp/samp-server.tar.gz "https://files.sa-mp.com/samp037svr_R2-1.tar.gz" && \
    tar -xzf /tmp/samp-server.tar.gz -C /home/samp/server --strip-components=1 && \
    rm -f /tmp/samp-server.tar.gz && \
    chmod +x samp03svr && \
    chown -R samp:samp /home/samp

USER samp
WORKDIR /home/samp/server

EXPOSE 7777/udp

ENTRYPOINT ["./samp03svr"]
EOF
}

build_image() {
    log_step 2 5 "Building Docker image..."
    log_info "Downloading and building SA:MP server..."

    local dockerfile
    dockerfile="$(generate_dockerfile)"

    if ! build_docker_image "$IMAGE_NAME" "$dockerfile"; then
        log_error "Failed to build Docker image"
        exit 1
    fi
}

setup_data_directory() {
    log_step 3 5 "Setting up data directory..."

    DATA_DIR=$(create_game_data_dir "samp")
    mkdir -p "${DATA_DIR}/gamemodes"
    mkdir -p "${DATA_DIR}/filterscripts"
    mkdir -p "${DATA_DIR}/scriptfiles"

    # Create server configuration file
    local config_file="${DATA_DIR}/server.cfg"
    if [[ ! -f "$config_file" ]]; then
        log_info "Creating server configuration..."
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
        log_success "Server configuration created"
    fi

    log_success "Data directory ready: ${DATA_DIR}"
}

run_container() {
    log_step 4 5 "Starting Docker container..."

    local port_mappings="-p ${GAME_PORT}:${GAME_PORT}/udp"
    local volume_mappings="-v ${DATA_DIR}/server.cfg:${INSTALL_DIR}/server.cfg -v ${DATA_DIR}/gamemodes:${INSTALL_DIR}/gamemodes -v ${DATA_DIR}/filterscripts:${INSTALL_DIR}/filterscripts -v ${DATA_DIR}/scriptfiles:${INSTALL_DIR}/scriptfiles"

    if ! run_docker_container "$CONTAINER_NAME" "$IMAGE_NAME" "$port_mappings" "$volume_mappings" ""; then
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
    log_step 5 5 "Setup complete!"

    echo ""
    separator "=" 60
    echo -e "${BOLD}${GAME_NAME} Server Installation Summary${RESET}"
    separator "-" 60
    echo -e "  ${CYAN}Container Name:${RESET}     ${CONTAINER_NAME}"
    echo -e "  ${CYAN}Image Name:${RESET}         ${IMAGE_NAME}"
    echo -e "  ${CYAN}Data Directory:${RESET}     ${DATA_DIR}"
    echo -e "  ${CYAN}Max Players:${RESET}        ${MAX_PLAYERS}"
    echo -e "  ${CYAN}Game Port:${RESET}          ${GAME_PORT}/udp"
    separator "-" 60
    echo -e "${BOLD}Default Credentials (CHANGE THESE!):${RESET}"
    echo -e "  ${YELLOW}RCON Password:${RESET}      ${RCON_PASSWORD}"
    separator "-" 60
    echo -e "${BOLD}Configuration Files:${RESET}"
    echo -e "  ${DIM}Server config:${RESET}   ${DATA_DIR}/server.cfg"
    separator "-" 60
    echo -e "${BOLD}Gamemodes:${RESET}"
    echo -e "  ${DIM}Located in:${RESET}      ${DATA_DIR}/gamemodes/"
    echo -e "  ${DIM}Default:${RESET}         grandlarc"
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
    build_image
    run_container
    show_summary

    return 0
}

main "$@"
