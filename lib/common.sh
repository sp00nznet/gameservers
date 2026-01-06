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

# Initialize logging on source
init_logging
