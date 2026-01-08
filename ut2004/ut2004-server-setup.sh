#!/bin/bash
#
# Unreal Tournament 2004 Dedicated Server Setup (Docker)
# Builds and runs a UT2004 server in a Docker container
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
readonly CONTAINER_NAME="ut2004server"
readonly IMAGE_NAME="gameservers/ut2004"
readonly INSTALL_DIR="/home/ut2004/server"

# Game server settings
readonly SERVER_NAME="Silverware UT2004 Server"
readonly DEFAULT_MAP="DM-Rankin"
readonly MAX_PLAYERS="16"
readonly ADMIN_PASSWORD="changeme"

# Network ports
readonly GAME_PORT="7777"
readonly QUERY_PORT="7778"
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
        lib32gcc-s1 \
        lib32stdc++6 \
        libstdc++6:i386 \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

RUN useradd -m -s /bin/bash ut2004
WORKDIR /home/ut2004

RUN mkdir -p /home/ut2004/server/System && \
    mkdir -p /home/ut2004/server/Maps && \
    mkdir -p /home/ut2004/server/Textures && \
    mkdir -p /home/ut2004/server/Sounds && \
    mkdir -p /home/ut2004/server/Music && \
    mkdir -p /home/ut2004/server/Animations && \
    mkdir -p /home/ut2004/server/StaticMeshes && \
    chown -R ut2004:ut2004 /home/ut2004

USER ut2004
WORKDIR /home/ut2004/server/System

EXPOSE 7777/udp 7778/udp 8075/tcp

# Note: Server binary must be provided by user
ENTRYPOINT ["./ucc-bin", "server"]
EOF
}

build_image() {
    log_step 2 5 "Building Docker image..."

    local dockerfile
    dockerfile="$(generate_dockerfile)"

    if ! build_docker_image "$IMAGE_NAME" "$dockerfile"; then
        log_error "Failed to build Docker image"
        exit 1
    fi
}

setup_data_directory() {
    log_step 3 5 "Setting up data directory..."

    DATA_DIR=$(create_game_data_dir "ut2004")
    mkdir -p "${DATA_DIR}/System"
    mkdir -p "${DATA_DIR}/Maps"
    mkdir -p "${DATA_DIR}/Textures"
    mkdir -p "${DATA_DIR}/Sounds"
    mkdir -p "${DATA_DIR}/Music"
    mkdir -p "${DATA_DIR}/Animations"
    mkdir -p "${DATA_DIR}/StaticMeshes"

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
    echo "Copy these to: ${DATA_DIR}"
    echo ""
    separator "-" 60

    log_success "Data directory ready: ${DATA_DIR}"
}

run_container() {
    log_step 4 5 "Preparing Docker container..."

    log_warn "Container will not start until game files are copied to ${DATA_DIR}"
    log_info "After copying files, run: docker start ${CONTAINER_NAME}"

    local port_mappings="-p ${GAME_PORT}:${GAME_PORT}/udp -p ${QUERY_PORT}:${QUERY_PORT}/udp -p ${WEB_ADMIN_PORT}:${WEB_ADMIN_PORT}/tcp"
    local volume_mappings="-v ${DATA_DIR}:${INSTALL_DIR}"
    local extra_args="${DEFAULT_MAP}?game=XGame.xDeathMatch?MaxPlayers=${MAX_PLAYERS} -nohomedir"

    # Create the container but don't start it (no game files yet)
    log_info "Container prepared but not started (game files needed)"
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
    separator "-" 60
    echo -e "${BOLD}Next Steps:${RESET}"
    echo -e "  1. Copy UT2004 game files to ${DATA_DIR}"
    echo -e "  2. Make binary executable: chmod +x ${DATA_DIR}/System/ucc-bin"
    echo -e "  3. Start: docker run -d --name ${CONTAINER_NAME} \\"
    echo -e "       -p ${GAME_PORT}:${GAME_PORT}/udp \\"
    echo -e "       -v ${DATA_DIR}:${INSTALL_DIR} \\"
    echo -e "       ${IMAGE_NAME} ${DEFAULT_MAP}?game=XGame.xDeathMatch"
    separator "-" 60
    echo -e "${BOLD}Game Modes:${RESET}"
    echo -e "  ${DIM}Deathmatch:${RESET}      XGame.xDeathMatch"
    echo -e "  ${DIM}Team DM:${RESET}         XGame.xTeamGame"
    echo -e "  ${DIM}CTF:${RESET}             XGame.xCTFGame"
    echo -e "  ${DIM}Bombing Run:${RESET}     XGame.xBombingRun"
    echo -e "  ${DIM}Onslaught:${RESET}       Onslaught.ONSOnslaughtGame"
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
