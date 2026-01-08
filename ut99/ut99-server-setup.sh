#!/bin/bash
#
# Unreal Tournament 99 Dedicated Server Setup (Docker)
# Builds and runs a UT99 server in a Docker container
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="Unreal Tournament 99"
readonly CONTAINER_NAME="ut99server"
readonly IMAGE_NAME="gameservers/ut99"
readonly INSTALL_DIR="/home/ut99/server"

# Download URL for UT99 server (OldUnreal patch)
readonly UT99_SERVER_URL="https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469d/OldUnreal-UTPatch469d-Linux-amd64.tar.bz2"

# Game server settings
readonly SERVER_NAME="Silverware UT99 Server"
readonly DEFAULT_MAP="DM-Deck16]["
readonly MAX_PLAYERS="16"
readonly ADMIN_PASSWORD="changeme"

# Network ports
readonly GAME_PORT="7777"
readonly QUERY_PORT="7778"

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
        bzip2 \
        lib32gcc-s1 \
        lib32stdc++6 \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

RUN useradd -m -s /bin/bash ut99
WORKDIR /home/ut99

RUN mkdir -p /home/ut99/server && \
    cd /home/ut99/server && \
    wget -q -O /tmp/ut99-server.tar.bz2 "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469d/OldUnreal-UTPatch469d-Linux-amd64.tar.bz2" && \
    tar -xjf /tmp/ut99-server.tar.bz2 -C /home/ut99/server --strip-components=1 && \
    rm -f /tmp/ut99-server.tar.bz2 && \
    chmod +x System/ucc-bin 2>/dev/null || true && \
    chown -R ut99:ut99 /home/ut99

USER ut99
WORKDIR /home/ut99/server/System

EXPOSE 7777/udp 7778/udp

ENTRYPOINT ["./ucc-bin", "server"]
EOF
}

build_image() {
    log_step 2 5 "Building Docker image..."
    log_info "Downloading OldUnreal UT99 patch..."

    local dockerfile
    dockerfile="$(generate_dockerfile)"

    if ! build_docker_image "$IMAGE_NAME" "$dockerfile"; then
        log_error "Failed to build Docker image"
        exit 1
    fi
}

setup_data_directory() {
    log_step 3 5 "Setting up data directory..."

    DATA_DIR=$(create_game_data_dir "ut99")
    mkdir -p "${DATA_DIR}/System"
    mkdir -p "${DATA_DIR}/Maps"
    mkdir -p "${DATA_DIR}/Textures"
    mkdir -p "${DATA_DIR}/Sounds"
    mkdir -p "${DATA_DIR}/Music"

    log_warn "NOTE: You need original UT99 game files to run the server."
    log_info "Copy your UT99 Maps, Textures, Sounds, and Music folders to ${DATA_DIR}"

    log_success "Data directory ready: ${DATA_DIR}"
}

run_container() {
    log_step 4 5 "Starting Docker container..."

    local port_mappings="-p ${GAME_PORT}:${GAME_PORT}/udp -p ${QUERY_PORT}:${QUERY_PORT}/udp"
    local volume_mappings="-v ${DATA_DIR}/Maps:${INSTALL_DIR}/Maps -v ${DATA_DIR}/Textures:${INSTALL_DIR}/Textures -v ${DATA_DIR}/Sounds:${INSTALL_DIR}/Sounds -v ${DATA_DIR}/Music:${INSTALL_DIR}/Music"
    local extra_args="${DEFAULT_MAP}?game=Botpack.DeathMatchPlus?MaxPlayers=${MAX_PLAYERS} -nohomedir"

    if ! run_docker_container "$CONTAINER_NAME" "$IMAGE_NAME" "$port_mappings" "$volume_mappings" "$extra_args"; then
        log_error "Failed to start container"
        exit 1
    fi

    sleep 2
    if container_is_running "$CONTAINER_NAME"; then
        log_success "Container is running"
    else
        log_warn "Container may need original game files. Check logs with: docker logs ${CONTAINER_NAME}"
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
    separator "-" 60
    echo -e "${BOLD}Game Modes:${RESET}"
    echo -e "  ${DIM}Deathmatch:${RESET}      Botpack.DeathMatchPlus"
    echo -e "  ${DIM}Team DM:${RESET}         Botpack.TeamGamePlus"
    echo -e "  ${DIM}CTF:${RESET}             Botpack.CTFGame"
    echo -e "  ${DIM}Assault:${RESET}         Botpack.Assault"
    echo -e "  ${DIM}Domination:${RESET}      Botpack.Domination"
    separator "-" 60
    echo -e "${YELLOW}IMPORTANT:${RESET} You need original UT99 game files!"
    echo -e "Copy Maps, Textures, Sounds, and Music folders to:"
    echo -e "  ${DATA_DIR}"
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
