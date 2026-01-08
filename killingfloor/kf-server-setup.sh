#!/bin/bash
#
# Killing Floor 1 Dedicated Server Setup (Docker)
# Builds and runs a KF1 server in a Docker container
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="Killing Floor"
readonly CONTAINER_NAME="kf1server"
readonly IMAGE_NAME="gameservers/killingfloor"
readonly STEAM_APP_ID="215360"
readonly INSTALL_DIR="/home/steam/kf1server"

# Game server settings
readonly DEFAULT_MAP="KF-WestLondon.rom"
readonly MAX_PLAYERS="6"
readonly GAME_TYPE="KFmod.KFGameType"

# Network ports
readonly GAME_PORT="7707"
readonly QUERY_PORT="7708"
readonly WEB_ADMIN_PORT="8075"

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

RUN mkdir -p /home/steam/kf1server && chown -R steam:steam /home/steam/kf1server

USER steam

RUN /home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/steam/kf1server \
    +login anonymous \
    +app_update 215360 validate \
    +quit

WORKDIR /home/steam/kf1server/System

RUN chmod +x ucc-bin 2>/dev/null || true

EXPOSE 7707/udp 7708/udp 8075/tcp

ENTRYPOINT ["./ucc-bin", "server"]
EOF
}

build_image() {
    log_step 2 5 "Building Docker image..."
    log_info "This may take a while for the initial download..."

    local dockerfile
    dockerfile="$(generate_dockerfile)"

    if ! build_docker_image "$IMAGE_NAME" "$dockerfile"; then
        log_error "Failed to build Docker image"
        exit 1
    fi
}

setup_data_directory() {
    log_step 3 5 "Setting up data directory..."

    DATA_DIR=$(create_game_data_dir "killingfloor")
    mkdir -p "${DATA_DIR}/System"
    mkdir -p "${DATA_DIR}/Maps"

    log_success "Data directory ready: ${DATA_DIR}"
}

run_container() {
    log_step 4 5 "Starting Docker container..."

    local port_mappings="-p ${GAME_PORT}:${GAME_PORT}/udp -p ${QUERY_PORT}:${QUERY_PORT}/udp -p ${WEB_ADMIN_PORT}:${WEB_ADMIN_PORT}/tcp"
    local volume_mappings="-v ${DATA_DIR}/System:${INSTALL_DIR}/System/ServerPackages -v ${DATA_DIR}/Maps:${INSTALL_DIR}/Maps"
    local extra_args="${DEFAULT_MAP}?game=${GAME_TYPE}?MaxPlayers=${MAX_PLAYERS} -nohomedir"

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
    log_step 5 5 "Setup complete!"

    echo ""
    separator "=" 60
    echo -e "${BOLD}${GAME_NAME} Server Installation Summary${RESET}"
    separator "-" 60
    echo -e "  ${CYAN}Container Name:${RESET}     ${CONTAINER_NAME}"
    echo -e "  ${CYAN}Image Name:${RESET}         ${IMAGE_NAME}"
    echo -e "  ${CYAN}Data Directory:${RESET}     ${DATA_DIR}"
    echo -e "  ${CYAN}Default Map:${RESET}        ${DEFAULT_MAP}"
    echo -e "  ${CYAN}Max Players:${RESET}        ${MAX_PLAYERS}"
    echo -e "  ${CYAN}Game Port:${RESET}          ${GAME_PORT}/udp"
    echo -e "  ${CYAN}Query Port:${RESET}         ${QUERY_PORT}/udp"
    echo -e "  ${CYAN}Web Admin Port:${RESET}     ${WEB_ADMIN_PORT}/tcp"
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
