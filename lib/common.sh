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

# =============================================================================
# WINDOWS SERVER MONITORING (VMs & Proton)
# =============================================================================

# Check if libvirt/virsh is available
has_libvirt() {
    command_exists virsh && virsh list &>/dev/null 2>&1
}

# Check if screen is available
has_screen() {
    command_exists screen
}

# List all Windows VMs (libvirt-based game servers)
list_windows_vms() {
    if ! has_libvirt; then
        return
    fi
    # List VMs that match our naming pattern
    virsh list --all --name 2>/dev/null | grep -E "server|coh|ark" | grep -v "^$"
}

# Get VM status
get_vm_status() {
    local vm_name="$1"

    if ! has_libvirt; then
        echo "not_available"
        return 1
    fi

    local state
    state=$(virsh domstate "$vm_name" 2>/dev/null)

    case "$state" in
        running)
            echo "running"
            ;;
        "shut off"|"shutoff")
            echo "stopped"
            ;;
        paused)
            echo "paused"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Get VM resource usage
get_vm_stats() {
    local vm_name="$1"

    if ! has_libvirt; then
        return 1
    fi

    if [[ "$(get_vm_status "$vm_name")" != "running" ]]; then
        return 1
    fi

    # Get CPU and memory stats
    local vcpus mem_max mem_used
    vcpus=$(virsh vcpucount "$vm_name" --current 2>/dev/null || echo "?")
    mem_max=$(virsh dominfo "$vm_name" 2>/dev/null | grep "Max memory" | awk '{print $3}')
    mem_used=$(virsh dommemstat "$vm_name" 2>/dev/null | grep "actual" | awk '{print $2}')

    if [[ -n "$mem_max" ]]; then
        mem_max=$((mem_max / 1024))  # Convert to MB
    fi
    if [[ -n "$mem_used" ]]; then
        mem_used=$((mem_used / 1024))  # Convert to MB
    fi

    echo "CPU:${vcpus} vCPUs|MEM:${mem_used:-?}/${mem_max:-?}MB"
}

# List Proton/screen-based game servers (systemd services with screen)
list_proton_servers() {
    local servers=()

    # Check for known Proton-based servers
    if systemctl list-unit-files arkserver.service &>/dev/null 2>&1; then
        servers+=("arkserver")
    fi

    # Also check for screen sessions matching server patterns
    if has_screen; then
        screen -ls 2>/dev/null | grep -oE "[0-9]+\.[a-z]+server" | cut -d'.' -f2 | while read -r name; do
            echo "$name"
        done
    fi

    # Output known Proton servers
    for srv in "${servers[@]}"; do
        echo "$srv"
    done
}

# Get Proton/screen server status
get_proton_server_status() {
    local server_name="$1"

    # First check systemd service
    if systemctl is-active "${server_name}.service" &>/dev/null 2>&1; then
        echo "running"
        return 0
    fi

    # Check for screen session
    if has_screen && screen -ls 2>/dev/null | grep -q "\.${server_name}"; then
        echo "running"
        return 0
    fi

    # Check if service exists but is stopped
    if systemctl list-unit-files "${server_name}.service" &>/dev/null 2>&1; then
        echo "stopped"
        return 0
    fi

    echo "not_found"
    return 1
}

# =============================================================================
# DOCKER CONTAINER MONITORING
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
    local has_servers=false

    # === DOCKER CONTAINERS ===
    local containers
    containers=$(list_game_containers | sort -u)

    if [[ -n "$containers" ]]; then
        has_servers=true
        echo ""
        echo -e "${BOLD}Docker Containers:${RESET}"
        separator "=" 80
        printf "${BOLD}%-25s %-12s %-20s %-15s${RESET}\n" "CONTAINER" "STATUS" "TYPE" "PORTS"
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
    fi

    # === WINDOWS VMs (libvirt) ===
    if has_libvirt; then
        local vms
        vms=$(list_windows_vms)

        if [[ -n "$vms" ]]; then
            has_servers=true
            echo ""
            echo -e "${BOLD}Windows Virtual Machines:${RESET}"
            separator "=" 80
            printf "${BOLD}%-25s %-12s %-20s %-15s${RESET}\n" "VM NAME" "STATUS" "TYPE" "VCPUS/MEM"
            separator "-" 80

            while IFS= read -r vm; do
                [[ -z "$vm" ]] && continue

                local status status_color vcpus mem_max

                status=$(get_vm_status "$vm")
                vcpus=$(virsh vcpucount "$vm" --current 2>/dev/null || echo "?")
                mem_max=$(virsh dominfo "$vm" 2>/dev/null | grep "Max memory" | awk '{print $3}')
                if [[ -n "$mem_max" ]]; then
                    mem_max="$((mem_max / 1024))MB"
                else
                    mem_max="?"
                fi

                case "$status" in
                    running)
                        status_color="${GREEN}"
                        ;;
                    stopped)
                        status_color="${RED}"
                        ;;
                    *)
                        status_color="${YELLOW}"
                        ;;
                esac

                printf "%-25s ${status_color}%-12s${RESET} %-20s %-15s\n" "$vm" "$status" "Windows VM" "${vcpus} vCPU / ${mem_max}"
            done <<< "$vms"

            separator "=" 80
        fi
    fi

    # === PROTON/SCREEN SERVERS ===
    local proton_servers
    proton_servers=$(list_proton_servers | sort -u)

    if [[ -n "$proton_servers" ]]; then
        has_servers=true
        echo ""
        echo -e "${BOLD}Proton/Native Servers (systemd):${RESET}"
        separator "=" 80
        printf "${BOLD}%-25s %-12s %-20s %-15s${RESET}\n" "SERVICE" "STATUS" "TYPE" "SCREEN"
        separator "-" 80

        while IFS= read -r server; do
            [[ -z "$server" ]] && continue

            local status status_color screen_status server_type

            status=$(get_proton_server_status "$server")

            # Determine server type
            case "$server" in
                arkserver)
                    server_type="Proton (Wine)"
                    ;;
                *)
                    server_type="Native/Screen"
                    ;;
            esac

            # Check for screen session
            if has_screen && screen -ls 2>/dev/null | grep -q "\.${server}"; then
                screen_status="Active"
            else
                screen_status="-"
            fi

            case "$status" in
                running)
                    status_color="${GREEN}"
                    ;;
                stopped)
                    status_color="${RED}"
                    ;;
                *)
                    status_color="${YELLOW}"
                    ;;
            esac

            printf "%-25s ${status_color}%-12s${RESET} %-20s %-15s\n" "$server" "$status" "$server_type" "$screen_status"
        done <<< "$proton_servers"

        separator "=" 80
    fi

    if [[ "$has_servers" == false ]]; then
        echo ""
        log_warn "No game servers found (Docker containers, VMs, or Proton servers)."
        echo ""
    fi

    echo ""
}

# Show detailed info for a Windows VM
show_vm_details() {
    local vm_name="$1"

    if ! has_libvirt; then
        log_error "libvirt/virsh not available"
        return 1
    fi

    if ! virsh dominfo "$vm_name" &>/dev/null; then
        log_error "VM not found: ${vm_name}"
        return 1
    fi

    echo ""
    separator "=" 60
    echo -e "${BOLD}Windows VM Details: ${vm_name}${RESET}"
    separator "-" 60

    local status vcpus mem_max autostart

    status=$(get_vm_status "$vm_name")
    vcpus=$(virsh vcpucount "$vm_name" --current 2>/dev/null || echo "?")
    mem_max=$(virsh dominfo "$vm_name" 2>/dev/null | grep "Max memory" | awk '{print $3}')
    autostart=$(virsh dominfo "$vm_name" 2>/dev/null | grep "Autostart" | awk '{print $2}')

    if [[ -n "$mem_max" ]]; then
        mem_max="$((mem_max / 1024)) MB"
    fi

    case "$status" in
        running) echo -e "  ${CYAN}Status:${RESET}       ${GREEN}●${RESET} Running" ;;
        stopped) echo -e "  ${CYAN}Status:${RESET}       ${RED}●${RESET} Stopped" ;;
        paused)  echo -e "  ${CYAN}Status:${RESET}       ${YELLOW}●${RESET} Paused" ;;
        *)       echo -e "  ${CYAN}Status:${RESET}       ${YELLOW}●${RESET} $status" ;;
    esac

    echo -e "  ${CYAN}vCPUs:${RESET}        $vcpus"
    echo -e "  ${CYAN}Max Memory:${RESET}   $mem_max"
    echo -e "  ${CYAN}Autostart:${RESET}    $autostart"

    if [[ "$status" == "running" ]]; then
        separator "-" 60
        echo -e "${BOLD}Resource Usage:${RESET}"

        # Get CPU usage (this requires polling)
        local cpu_time
        cpu_time=$(virsh domstats "$vm_name" --cpu-total 2>/dev/null | grep "cpu.time" | cut -d'=' -f2)
        if [[ -n "$cpu_time" ]]; then
            echo -e "  ${CYAN}CPU Time:${RESET}     ${cpu_time} ns"
        fi

        # Get memory usage
        local mem_actual
        mem_actual=$(virsh dommemstat "$vm_name" 2>/dev/null | grep "actual" | awk '{print $2}')
        if [[ -n "$mem_actual" ]]; then
            echo -e "  ${CYAN}Memory Used:${RESET}  $((mem_actual / 1024)) MB"
        fi

        separator "-" 60
        echo -e "${BOLD}Network Interfaces:${RESET}"
        virsh domiflist "$vm_name" 2>/dev/null | tail -n +3 | while read -r line; do
            [[ -z "$line" ]] && continue
            echo -e "  $line"
        done
    fi

    separator "-" 60
    echo -e "${BOLD}Management Commands:${RESET}"
    echo -e "  ${GREEN}Start VM:${RESET}      sudo virsh start ${vm_name}"
    echo -e "  ${GREEN}Stop VM:${RESET}       sudo virsh shutdown ${vm_name}"
    echo -e "  ${GREEN}Force Stop:${RESET}    sudo virsh destroy ${vm_name}"
    echo -e "  ${GREEN}Console:${RESET}       sudo virsh console ${vm_name}"
    echo -e "  ${GREEN}VNC Viewer:${RESET}    virt-viewer ${vm_name}"

    separator "=" 60
    echo ""
}

# Show detailed info for a Proton/screen server
show_proton_server_details() {
    local server_name="$1"

    local status
    status=$(get_proton_server_status "$server_name")

    if [[ "$status" == "not_found" ]]; then
        log_error "Server not found: ${server_name}"
        return 1
    fi

    echo ""
    separator "=" 60
    echo -e "${BOLD}Proton/Native Server Details: ${server_name}${RESET}"
    separator "-" 60

    case "$status" in
        running) echo -e "  ${CYAN}Status:${RESET}       ${GREEN}●${RESET} Running" ;;
        stopped) echo -e "  ${CYAN}Status:${RESET}       ${RED}●${RESET} Stopped" ;;
        *)       echo -e "  ${CYAN}Status:${RESET}       ${YELLOW}●${RESET} $status" ;;
    esac

    # Check systemd service status
    if systemctl list-unit-files "${server_name}.service" &>/dev/null 2>&1; then
        local svc_enabled
        svc_enabled=$(systemctl is-enabled "${server_name}.service" 2>/dev/null || echo "disabled")
        echo -e "  ${CYAN}Service:${RESET}      ${server_name}.service"
        echo -e "  ${CYAN}Enabled:${RESET}      $svc_enabled"
    fi

    # Check screen session
    if has_screen; then
        local screen_info
        screen_info=$(screen -ls 2>/dev/null | grep "\.${server_name}" || echo "")
        if [[ -n "$screen_info" ]]; then
            echo -e "  ${CYAN}Screen:${RESET}       Active"
            echo -e "  ${DIM}$screen_info${RESET}"
        else
            echo -e "  ${CYAN}Screen:${RESET}       Not attached"
        fi
    fi

    # Server type specific info
    separator "-" 60
    case "$server_name" in
        arkserver)
            echo -e "${BOLD}ARK: Survival Ascended Info:${RESET}"
            echo -e "  ${CYAN}Type:${RESET}         Proton (Windows binary)"
            if [[ -d "/opt/arkserver" ]]; then
                echo -e "  ${CYAN}Install Dir:${RESET}  /opt/arkserver"
            fi
            if [[ -f "/opt/arkserver/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini" ]]; then
                echo -e "  ${CYAN}Config:${RESET}       GameUserSettings.ini found"
            fi
            ;;
        *)
            echo -e "${BOLD}Server Type:${RESET} Native/Screen-based"
            ;;
    esac

    separator "-" 60
    echo -e "${BOLD}Management Commands:${RESET}"
    echo -e "  ${GREEN}Start:${RESET}         sudo systemctl start ${server_name}"
    echo -e "  ${GREEN}Stop:${RESET}          sudo systemctl stop ${server_name}"
    echo -e "  ${GREEN}Restart:${RESET}       sudo systemctl restart ${server_name}"
    echo -e "  ${GREEN}Status:${RESET}        sudo systemctl status ${server_name}"
    if has_screen; then
        echo -e "  ${GREEN}Console:${RESET}       screen -r ${server_name}"
    fi

    separator "=" 60
    echo ""
}

# List all servers (containers, VMs, and Proton servers)
list_all_servers() {
    local servers=()

    # Docker containers
    while IFS= read -r container; do
        [[ -n "$container" ]] && servers+=("docker:$container")
    done < <(list_game_containers | sort -u)

    # Windows VMs
    if has_libvirt; then
        while IFS= read -r vm; do
            [[ -n "$vm" ]] && servers+=("vm:$vm")
        done < <(list_windows_vms)
    fi

    # Proton/screen servers
    while IFS= read -r srv; do
        [[ -n "$srv" ]] && servers+=("proton:$srv")
    done < <(list_proton_servers | sort -u)

    # Output unique servers
    printf '%s\n' "${servers[@]}" | sort -u
}

# Get server status (unified for all types)
get_server_status_unified() {
    local server_spec="$1"
    local type="${server_spec%%:*}"
    local name="${server_spec#*:}"

    case "$type" in
        docker)
            get_container_status "$name"
            ;;
        vm)
            get_vm_status "$name"
            ;;
        proton)
            get_proton_server_status "$name"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Control server (start/stop/restart) - unified for all types
control_server() {
    local server_spec="$1"
    local action="$2"
    local type="${server_spec%%:*}"
    local name="${server_spec#*:}"

    case "$type" in
        docker)
            case "$action" in
                start)   docker start "$name" ;;
                stop)    docker stop "$name" ;;
                restart) docker restart "$name" ;;
            esac
            ;;
        vm)
            case "$action" in
                start)   virsh start "$name" ;;
                stop)    virsh shutdown "$name" ;;
                restart) virsh reboot "$name" ;;
            esac
            ;;
        proton)
            case "$action" in
                start)   systemctl start "${name}.service" ;;
                stop)    systemctl stop "${name}.service" ;;
                restart) systemctl restart "${name}.service" ;;
            esac
            ;;
    esac
}

# Show detailed info for a specific server (any type)
show_server_details() {
    local container_name="$1"

    # Check if it's a Docker container
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${container_name}$"; then
        show_docker_container_details "$container_name"
        return
    fi

    # Check if it's a VM
    if has_libvirt && virsh dominfo "$container_name" &>/dev/null 2>&1; then
        show_vm_details "$container_name"
        return
    fi

    # Check if it's a Proton/screen server
    if [[ "$(get_proton_server_status "$container_name")" != "not_found" ]]; then
        show_proton_server_details "$container_name"
        return
    fi

    log_error "Server not found: ${container_name}"
    return 1
}

# Show detailed info for a Docker container
show_docker_container_details() {
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
