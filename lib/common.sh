#!/bin/bash
#
# Common library for Silverware Game Servers
# Provides logging, colors, and utility functions
#

# =============================================================================
# SCRIPT CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="/var/log/gameservers"
LOG_FILE="${LOG_DIR}/setup.log"
STEAMCMD_DIR="/opt/steamcmd"
STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"

# =============================================================================
# COLOR DEFINITIONS
# =============================================================================
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[0;37m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    WHITE=''
    BOLD=''
    DIM=''
    RESET=''
fi

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

# Initialize logging directory
init_logging() {
    if [[ ! -d "$LOG_DIR" ]]; then
        sudo mkdir -p "$LOG_DIR" 2>/dev/null || mkdir -p "$LOG_DIR"
        sudo chmod 755 "$LOG_DIR" 2>/dev/null || true
    fi

    # Create log file if it doesn't exist
    if [[ ! -f "$LOG_FILE" ]]; then
        sudo touch "$LOG_FILE" 2>/dev/null || touch "$LOG_FILE"
        sudo chmod 644 "$LOG_FILE" 2>/dev/null || true
    fi
}

# Get timestamp for logs
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Log to file only
log_to_file() {
    local level="$1"
    local message="$2"
    echo "[$(timestamp)] [$level] $message" >> "$LOG_FILE" 2>/dev/null || true
}

# Log info message
log_info() {
    local message="$1"
    echo -e "${BLUE}[INFO]${RESET} $message"
    log_to_file "INFO" "$message"
}

# Log success message
log_success() {
    local message="$1"
    echo -e "${GREEN}[OK]${RESET} $message"
    log_to_file "SUCCESS" "$message"
}

# Log warning message
log_warn() {
    local message="$1"
    echo -e "${YELLOW}[WARN]${RESET} $message"
    log_to_file "WARN" "$message"
}

# Log error message
log_error() {
    local message="$1"
    echo -e "${RED}[ERROR]${RESET} $message" >&2
    log_to_file "ERROR" "$message"
}

# Log step (for multi-step operations)
log_step() {
    local step="$1"
    local total="$2"
    local message="$3"
    echo -e "${CYAN}[${step}/${total}]${RESET} ${BOLD}$message${RESET}"
    log_to_file "STEP" "[$step/$total] $message"
}

# Log header for sections
log_header() {
    local message="$1"
    local width=60
    local padding=$(( (width - ${#message}) / 2 ))
    local line=$(printf '%*s' "$width" | tr ' ' '=')

    echo ""
    echo -e "${MAGENTA}${line}${RESET}"
    echo -e "${MAGENTA}$(printf '%*s' $padding '')${BOLD}$message${RESET}"
    echo -e "${MAGENTA}${line}${RESET}"
    echo ""
    log_to_file "HEADER" "$message"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check required dependencies
check_dependencies() {
    local deps=("$@")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing[*]}"
        log_info "Install them with: apt-get install ${missing[*]}"
        return 1
    fi

    return 0
}

# Install SteamCMD if not present
install_steamcmd() {
    if [[ -f "${STEAMCMD_DIR}/steamcmd.sh" ]]; then
        log_info "SteamCMD already installed at ${STEAMCMD_DIR}"
        return 0
    fi

    log_info "Installing SteamCMD..."

    mkdir -p "$STEAMCMD_DIR"
    cd "$STEAMCMD_DIR" || {
        log_error "Failed to change to SteamCMD directory"
        return 1
    }

    if ! curl -sqL "$STEAMCMD_URL" | tar zxvf -; then
        log_error "Failed to download and extract SteamCMD"
        return 1
    fi

    log_success "SteamCMD installed successfully"
    return 0
}

# Run SteamCMD to install/update a game server
run_steamcmd() {
    local install_dir="$1"
    local app_id="$2"

    log_info "Updating game files (App ID: ${app_id})..."
    log_info "Install directory: ${install_dir}"

    if ! "${STEAMCMD_DIR}/steamcmd.sh" \
        +force_install_dir "$install_dir" \
        +login anonymous \
        +app_update "$app_id" validate \
        +quit; then
        log_error "SteamCMD failed to update app ${app_id}"
        return 1
    fi

    log_success "Game files updated successfully"
    return 0
}

# Create a systemd service file
create_systemd_service() {
    local service_name="$1"
    local service_content="$2"
    local service_path="/etc/systemd/system/${service_name}.service"

    log_info "Creating systemd service: ${service_name}"

    echo "$service_content" | sudo tee "$service_path" > /dev/null

    if [[ ! -f "$service_path" ]]; then
        log_error "Failed to create service file: ${service_path}"
        return 1
    fi

    log_success "Service file created: ${service_path}"
    return 0
}

# Enable and start a systemd service
enable_service() {
    local service_name="$1"

    log_info "Reloading systemd daemon..."
    systemctl daemon-reload

    log_info "Enabling ${service_name} service..."
    if ! systemctl enable "${service_name}.service"; then
        log_error "Failed to enable ${service_name} service"
        return 1
    fi

    log_info "Starting ${service_name} service..."
    if ! systemctl start "${service_name}"; then
        log_error "Failed to start ${service_name} service"
        return 1
    fi

    log_success "${service_name} service is now running"
    return 0
}

# Show a spinner for long operations
spinner() {
    local pid=$1
    local message="${2:-Processing...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${CYAN}[%s]${RESET} %s" "${spin:i++%${#spin}:1}" "$message"
        sleep 0.1
    done
    printf "\r"
}

# Confirm action with user
confirm() {
    local message="${1:-Are you sure?}"
    local response

    echo -en "${YELLOW}${message} [y/N]:${RESET} "
    read -r response

    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Print a separator line
separator() {
    local char="${1:--}"
    local width="${2:-60}"
    printf '%*s\n' "$width" '' | tr ' ' "$char"
}

# =============================================================================
# DOCKER FUNCTIONS
# =============================================================================

# Docker data directory for persistent storage
DOCKER_DATA_DIR="/opt/gameservers"

# Check if Docker is installed and running
check_docker() {
    if ! command_exists docker; then
        log_error "Docker is not installed."
        log_info "Install Docker with: curl -fsSL https://get.docker.com | sh"
        return 1
    fi

    if ! docker info &>/dev/null; then
        log_error "Docker daemon is not running."
        log_info "Start Docker with: systemctl start docker"
        return 1
    fi

    log_success "Docker is available"
    return 0
}

# Build a Docker image
# Usage: build_docker_image <image_name> <dockerfile_content> [build_context_dir]
build_docker_image() {
    local image_name="$1"
    local dockerfile_content="$2"
    local build_context="${3:-/tmp/docker-build-$$}"

    log_info "Building Docker image: ${image_name}..."

    # Create build context directory
    mkdir -p "$build_context"

    # Write Dockerfile
    echo "$dockerfile_content" > "${build_context}/Dockerfile"

    # Build the image
    if ! docker build -t "$image_name" "$build_context"; then
        log_error "Failed to build Docker image: ${image_name}"
        rm -rf "$build_context"
        return 1
    fi

    # Cleanup
    rm -rf "$build_context"

    log_success "Docker image built: ${image_name}"
    return 0
}

# Run a Docker container
# Usage: run_docker_container <container_name> <image_name> <port_mappings> <volume_mappings> [extra_args]
# port_mappings: "-p 27015:27015/udp -p 27015:27015/tcp"
# volume_mappings: "-v /host/path:/container/path"
run_docker_container() {
    local container_name="$1"
    local image_name="$2"
    local port_mappings="$3"
    local volume_mappings="$4"
    local extra_args="${5:-}"

    log_info "Starting Docker container: ${container_name}..."

    # Stop and remove existing container if it exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log_info "Removing existing container: ${container_name}"
        docker stop "$container_name" 2>/dev/null || true
        docker rm "$container_name" 2>/dev/null || true
    fi

    # Run the container
    # shellcheck disable=SC2086
    if ! docker run -d \
        --name "$container_name" \
        --restart unless-stopped \
        $port_mappings \
        $volume_mappings \
        $extra_args \
        "$image_name"; then
        log_error "Failed to start Docker container: ${container_name}"
        return 1
    fi

    log_success "Docker container started: ${container_name}"
    return 0
}

# Stop a Docker container
stop_docker_container() {
    local container_name="$1"

    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log_info "Stopping Docker container: ${container_name}..."
        docker stop "$container_name"
        log_success "Container stopped: ${container_name}"
    else
        log_info "Container ${container_name} is not running"
    fi
}

# Check if a Docker container is running
container_is_running() {
    local container_name="$1"
    docker ps --format '{{.Names}}' | grep -q "^${container_name}$"
}

# Get container logs
get_container_logs() {
    local container_name="$1"
    local lines="${2:-50}"
    docker logs --tail "$lines" "$container_name"
}

# Create data directory for a game server
create_game_data_dir() {
    local game_name="$1"
    local data_dir="${DOCKER_DATA_DIR}/${game_name}"

    if [[ ! -d "$data_dir" ]]; then
        log_info "Creating data directory: ${data_dir}"
        mkdir -p "$data_dir"
    fi

    echo "$data_dir"
}

# Generate a base SteamCMD Dockerfile
generate_steamcmd_dockerfile() {
    local app_id="$1"
    local install_dir="$2"
    local extra_packages="${3:-}"

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
        ${extra_packages} \\
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
RUN mkdir -p ${install_dir} && chown -R steam:steam ${install_dir}

USER steam

# Install game server
RUN /home/steam/steamcmd/steamcmd.sh \\
    +force_install_dir ${install_dir} \\
    +login anonymous \\
    +app_update ${app_id} validate \\
    +quit

WORKDIR ${install_dir}
EOF
}

# Create a systemd service for a Docker container
# This ensures the container starts on boot and can be managed via systemctl
create_docker_service() {
    local container_name="$1"
    local description="$2"

    local service_content="[Unit]
Description=${description}
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start ${container_name}
ExecStop=/usr/bin/docker stop ${container_name}
ExecReload=/usr/bin/docker restart ${container_name}

[Install]
WantedBy=multi-user.target"

    local service_path="/etc/systemd/system/${container_name}.service"

    log_info "Creating systemd service for container: ${container_name}"

    echo "$service_content" | sudo tee "$service_path" > /dev/null

    if [[ ! -f "$service_path" ]]; then
        log_error "Failed to create service file: ${service_path}"
        return 1
    fi

    # Reload systemd and enable the service
    sudo systemctl daemon-reload
    sudo systemctl enable "${container_name}.service" 2>/dev/null

    log_success "Systemd service created: ${container_name}.service"
    return 0
}

# =============================================================================
# MONITORING FUNCTIONS
# =============================================================================

# List all game server containers (both running and stopped)
list_game_containers() {
    docker ps -a --filter "label=gameserver=true" --format "{{.Names}}" 2>/dev/null
    # Also list containers matching our naming pattern
    docker ps -a --format "{{.Names}}" 2>/dev/null | grep -E "server$|server[0-9]*$" | sort -u
}

# Get container status info
get_container_status() {
    local container_name="$1"

    if ! docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "not_found"
        return 1
    fi

    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "running"
    else
        echo "stopped"
    fi
}

# Get detailed container info
get_container_info() {
    local container_name="$1"

    if ! docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        return 1
    fi

    local status
    local uptime
    local image
    local ports

    status=$(docker inspect --format '{{.State.Status}}' "$container_name" 2>/dev/null)
    image=$(docker inspect --format '{{.Config.Image}}' "$container_name" 2>/dev/null)
    ports=$(docker port "$container_name" 2>/dev/null | tr '\n' ' ')

    if [[ "$status" == "running" ]]; then
        uptime=$(docker inspect --format '{{.State.StartedAt}}' "$container_name" 2>/dev/null)
        uptime=$(date -d "$uptime" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$uptime")
    else
        uptime="N/A"
    fi

    echo "status:$status"
    echo "image:$image"
    echo "started:$uptime"
    echo "ports:$ports"
}

# Get container resource usage
get_container_stats() {
    local container_name="$1"

    if ! container_is_running "$container_name"; then
        return 1
    fi

    docker stats --no-stream --format "CPU:{{.CPUPerc}}|MEM:{{.MemUsage}}|NET:{{.NetIO}}" "$container_name" 2>/dev/null
}

# Show all game servers status in a formatted table
show_servers_status() {
    local containers
    containers=$(list_game_containers | sort -u)

    if [[ -z "$containers" ]]; then
        echo ""
        log_warn "No game server containers found."
        echo ""
        return 0
    fi

    echo ""
    separator "=" 80
    printf "${BOLD}%-25s %-12s %-20s %-15s${RESET}\n" "CONTAINER" "STATUS" "IMAGE" "PORTS"
    separator "-" 80

    while IFS= read -r container; do
        [[ -z "$container" ]] && continue

        local status image ports status_color

        status=$(docker inspect --format '{{.State.Status}}' "$container" 2>/dev/null || echo "unknown")
        image=$(docker inspect --format '{{.Config.Image}}' "$container" 2>/dev/null | cut -d'/' -f2 || echo "unknown")
        ports=$(docker port "$container" 2>/dev/null | head -1 | cut -d':' -f2 | cut -d'-' -f1 || echo "-")

        case "$status" in
            running)
                status_color="${GREEN}"
                ;;
            exited|stopped)
                status_color="${RED}"
                ;;
            *)
                status_color="${YELLOW}"
                ;;
        esac

        printf "%-25s ${status_color}%-12s${RESET} %-20s %-15s\n" "$container" "$status" "$image" "$ports"
    done <<< "$containers"

    separator "=" 80
    echo ""
}

# Show detailed info for a specific server
show_server_details() {
    local container_name="$1"

    if ! docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log_error "Container not found: ${container_name}"
        return 1
    fi

    echo ""
    separator "=" 60
    echo -e "${BOLD}Server Details: ${container_name}${RESET}"
    separator "-" 60

    local status image created started ports

    status=$(docker inspect --format '{{.State.Status}}' "$container_name" 2>/dev/null)
    image=$(docker inspect --format '{{.Config.Image}}' "$container_name" 2>/dev/null)
    created=$(docker inspect --format '{{.Created}}' "$container_name" 2>/dev/null | cut -d'T' -f1)
    started=$(docker inspect --format '{{.State.StartedAt}}' "$container_name" 2>/dev/null | cut -d'T' -f1,2 | tr 'T' ' ' | cut -d'.' -f1)

    case "$status" in
        running) echo -e "  ${CYAN}Status:${RESET}       ${GREEN}●${RESET} Running" ;;
        exited)  echo -e "  ${CYAN}Status:${RESET}       ${RED}●${RESET} Stopped" ;;
        *)       echo -e "  ${CYAN}Status:${RESET}       ${YELLOW}●${RESET} $status" ;;
    esac

    echo -e "  ${CYAN}Image:${RESET}        $image"
    echo -e "  ${CYAN}Created:${RESET}      $created"
    echo -e "  ${CYAN}Started:${RESET}      $started"

    separator "-" 60
    echo -e "${BOLD}Port Mappings:${RESET}"
    docker port "$container_name" 2>/dev/null | while read -r line; do
        echo -e "  $line"
    done

    if [[ "$status" == "running" ]]; then
        separator "-" 60
        echo -e "${BOLD}Resource Usage:${RESET}"
        local stats
        stats=$(docker stats --no-stream --format "{{.CPUPerc}}|{{.MemUsage}}|{{.NetIO}}" "$container_name" 2>/dev/null)
        if [[ -n "$stats" ]]; then
            local cpu mem net
            cpu=$(echo "$stats" | cut -d'|' -f1)
            mem=$(echo "$stats" | cut -d'|' -f2)
            net=$(echo "$stats" | cut -d'|' -f3)
            echo -e "  ${CYAN}CPU:${RESET}          $cpu"
            echo -e "  ${CYAN}Memory:${RESET}       $mem"
            echo -e "  ${CYAN}Network I/O:${RESET}  $net"
        fi
    fi

    separator "-" 60
    echo -e "${BOLD}Systemd Service:${RESET}"
    if systemctl list-unit-files "${container_name}.service" &>/dev/null; then
        local svc_status
        svc_status=$(systemctl is-active "${container_name}.service" 2>/dev/null || echo "inactive")
        local svc_enabled
        svc_enabled=$(systemctl is-enabled "${container_name}.service" 2>/dev/null || echo "disabled")
        echo -e "  ${CYAN}Service:${RESET}      ${container_name}.service"
        echo -e "  ${CYAN}Active:${RESET}       $svc_status"
        echo -e "  ${CYAN}Enabled:${RESET}      $svc_enabled"
    else
        echo -e "  ${DIM}No systemd service configured${RESET}"
    fi

    separator "=" 60
    echo ""
}

# Initialize logging on source
init_logging
