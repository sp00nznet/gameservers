#!/bin/bash
#
# Starbound Dedicated Server Setup (Docker)
# Builds and runs a Starbound server in a Docker container
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="Starbound"
readonly CONTAINER_NAME="starboundserver"
readonly IMAGE_NAME="gameservers/starbound"
readonly STEAM_APP_ID="211820"
readonly INSTALL_DIR="/home/steam/starboundserver"

# Game server settings
readonly MAX_PLAYERS="8"

# Network ports
readonly GAME_PORT="21025"

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
        lib32gcc-s1 \
        lib32stdc++6 \
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

RUN mkdir -p /home/steam/starboundserver && chown -R steam:steam /home/steam/starboundserver

USER steam

RUN /home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/steam/starboundserver \
    +login anonymous \
    +app_update 211820 validate \
    +quit

WORKDIR /home/steam/starboundserver/linux

RUN chmod +x starbound_server 2>/dev/null || true

EXPOSE 21025/tcp

ENTRYPOINT ["./starbound_server"]
EOF
}

build_image() {
    log_step 2 5 "Building Docker image..."
    log_info "This may take a while for the initial build..."

    local dockerfile
    dockerfile="$(generate_dockerfile)"

    if ! build_docker_image "$IMAGE_NAME" "$dockerfile"; then
        log_error "Failed to build Docker image"
        exit 1
    fi
}

setup_data_directory() {
    log_step 3 5 "Setting up data directory..."

    DATA_DIR=$(create_game_data_dir "starbound")
    mkdir -p "${DATA_DIR}/storage"

    log_success "Data directory ready: ${DATA_DIR}"
}

run_container() {
    log_step 4 5 "Starting Docker container..."

    local port_mappings="-p ${GAME_PORT}:${GAME_PORT}/tcp"
    local volume_mappings="-v ${DATA_DIR}/storage:${INSTALL_DIR}/storage"

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

    # Create systemd service for auto-start
    create_docker_service "$CONTAINER_NAME" "${GAME_NAME} Dedicated Server"
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
    echo -e "  ${CYAN}Game Port:${RESET}          ${GAME_PORT}/tcp"
    separator "-" 60
    echo -e "${BOLD}Configuration Files:${RESET}"
    echo -e "  ${DIM}Server config:${RESET}   ${DATA_DIR}/storage/starbound_server.config"
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
