#!/bin/bash
#
# Star Wars Galaxies EMU (SWGEmu) Dedicated Server Setup
# Downloads, compiles, and configures a SWGEmu Core3 server
#
# Based on: https://github.com/swgemu/Core3
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="Star Wars Galaxies EMU"
readonly SERVICE_NAME="swgemuserver"
readonly INSTALL_DIR="/opt/swgemu"
readonly WORKSPACE_DIR="${INSTALL_DIR}/workspace"
readonly CORE3_DIR="${WORKSPACE_DIR}/Core3"
readonly BIN_DIR="${CORE3_DIR}/MMOCoreORB/bin"
readonly TRE_DIR="${INSTALL_DIR}/tre"

# Git repository
readonly CORE3_REPO="https://github.com/swgemu/Core3.git"
readonly CORE3_BRANCH="unstable"

# Database configuration
readonly DB_NAME="swgemu"
readonly DB_USER="swgemu"
readonly DB_PASS="swgemu"

# Network ports
readonly LOGIN_PORT="44419"
readonly ZONE_PORT="44453"
readonly PING_PORT="44462"
readonly STATUS_PORT="44455"

# Screen session name
readonly SCREEN_NAME="${SERVICE_NAME}"

# Dedicated user
readonly SWG_USER="swgemu"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Validate prerequisites
check_prerequisites() {
    log_step 1 12 "Checking prerequisites..."

    local deps=("curl" "wget" "screen" "systemctl" "git")

    if ! check_dependencies "${deps[@]}"; then
        log_error "Missing dependencies. Please install them first."
        exit 1
    fi

    # Check available RAM (8GB+ recommended)
    local total_ram
    total_ram=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $total_ram -lt 8000 ]]; then
        log_warn "System has ${total_ram}MB RAM. Recommended: 8GB+"
    fi

    # Check available disk space (50GB+ recommended)
    local free_space
    free_space=$(df -BG /opt 2>/dev/null | awk 'NR==2 {print $4}' | tr -d 'G')
    if [[ ${free_space:-0} -lt 50 ]]; then
        log_warn "Low disk space. Recommended: 50GB+ free"
    fi

    log_success "Prerequisites check complete"
}

# Create dedicated user
create_swg_user() {
    log_step 2 12 "Creating dedicated user..."

    if id "$SWG_USER" &>/dev/null; then
        log_info "User '${SWG_USER}' already exists"
    else
        useradd -m -s /bin/bash "$SWG_USER"
        log_success "Created user '${SWG_USER}'"
    fi
}

# Install build dependencies
install_dependencies() {
    log_step 3 12 "Installing build dependencies..."

    # Detect package manager
    if command -v apt-get &>/dev/null; then
        log_info "Installing dependencies (Debian/Ubuntu)..."

        # Add LLVM repository and install Clang 19
        apt-get update
        apt-get install -y apt-transport-https ca-certificates git gnupg \
            lsb-release moreutils software-properties-common wget curl

        # Install LLVM/Clang 19
        log_info "Installing Clang 19..."
        wget -O /tmp/llvm.sh https://apt.llvm.org/llvm.sh
        chmod +x /tmp/llvm.sh
        /tmp/llvm.sh 19 all || log_warn "LLVM install script had issues, continuing..."

        # Create symlinks for clang tools
        cd /usr/bin
        for i in ../lib/llvm-*/bin/*; do
            ln -sf "$i" . 2>/dev/null || true
        done
        cd - > /dev/null

        # Install other dependencies
        apt-get install -y \
            build-essential \
            libmariadb-dev \
            libmariadb-dev-compat \
            liblua5.3-dev \
            libdb5.3-dev \
            libssl-dev \
            cmake \
            default-jre \
            libboost-all-dev \
            gdb \
            ninja-build \
            libjemalloc-dev \
            mariadb-server \
            mariadb-client \
            zlib1g-dev

    elif command -v dnf &>/dev/null; then
        log_info "Installing dependencies (Fedora/RHEL)..."
        dnf install -y \
            gcc-c++ \
            clang \
            cmake \
            ninja-build \
            mariadb-server \
            mariadb-devel \
            lua-devel \
            libdb-devel \
            openssl-devel \
            java-latest-openjdk \
            boost-devel \
            gdb \
            jemalloc-devel \
            zlib-devel \
            git
    else
        log_error "Unsupported package manager. Please install dependencies manually."
        exit 1
    fi

    log_success "Dependencies installed"
}

# Create directory structure
create_directories() {
    log_step 4 12 "Creating directory structure..."

    mkdir -p "$INSTALL_DIR"
    mkdir -p "$WORKSPACE_DIR"
    mkdir -p "$TRE_DIR"
    mkdir -p "${BIN_DIR}/conf"

    chown -R "${SWG_USER}:${SWG_USER}" "$INSTALL_DIR"

    log_success "Directories created"
}

# Clone Core3 repository
clone_repository() {
    log_step 5 12 "Cloning SWGEmu Core3 repository..."

    if [[ -d "$CORE3_DIR" ]]; then
        log_info "Core3 directory exists, updating..."
        cd "$CORE3_DIR"
        sudo -u "$SWG_USER" git fetch origin
        sudo -u "$SWG_USER" git checkout "$CORE3_BRANCH"
        sudo -u "$SWG_USER" git pull origin "$CORE3_BRANCH"
    else
        log_info "Cloning Core3 repository..."
        cd "$WORKSPACE_DIR"
        sudo -u "$SWG_USER" git clone "$CORE3_REPO"
        cd "$CORE3_DIR"
        sudo -u "$SWG_USER" git checkout "$CORE3_BRANCH"
    fi

    log_success "Repository ready"
}

# Build the server
build_server() {
    log_step 6 12 "Building SWGEmu server (this takes a while)..."

    cd "${CORE3_DIR}/MMOCoreORB"

    log_info "Running ninja build (release mode)..."
    sudo -u "$SWG_USER" make -j$(nproc)

    if [[ ! -f "${BIN_DIR}/core3" ]]; then
        log_error "Build failed - core3 binary not found"
        exit 1
    fi

    log_success "Server built successfully"
}

# Setup MariaDB database
setup_database() {
    log_step 7 12 "Setting up MariaDB database..."

    # Start MariaDB
    systemctl enable mariadb
    systemctl start mariadb

    # Create database and user
    log_info "Creating database and user..."
    mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"

    # Import schema if exists
    local sql_file="${CORE3_DIR}/MMOCoreORB/sql/swgemu.sql"
    if [[ -f "$sql_file" ]]; then
        log_info "Importing database schema..."
        mysql "$DB_NAME" < "$sql_file"
    fi

    log_success "Database setup complete"
}

# Create server configuration
create_config() {
    log_step 8 12 "Creating server configuration..."

    local config_file="${BIN_DIR}/conf/config-local.lua"

    cat > "$config_file" << 'EOF'
-- SWGEmu Server Configuration
-- Edit this file for your server settings

-- Database settings
DBHost = "127.0.0.1"
DBPort = 3306
DBName = "swgemu"
DBUser = "swgemu"
DBPass = "swgemu"
DBSecret = "swgemu"

-- Server settings
LoginPort = 44419
StatusPort = 44455
PingPort = 44462

-- TRE file location
TrePath = "/opt/swgemu/tre/"

-- Server name
ZoneGalaxyID = 2
ZoneServerName = "Silverware SWG"

-- Enable features
ZoneAllowedToEnterThePlanet = true
ZoneOnlineCharactersPerAccount = 2

-- Admin accounts (add Steam IDs or account names)
-- Admins = { "admin" }
EOF

    chown "${SWG_USER}:${SWG_USER}" "$config_file"

    log_success "Configuration created"
}

# Prompt for TRE files
setup_tre_files() {
    log_step 9 12 "Setting up TRE files..."

    echo ""
    separator "-" 60
    echo -e "${YELLOW}TRE Files Required${RESET}"
    echo ""
    echo "SWGEmu requires the original Star Wars Galaxies .tre files."
    echo "You need a legally obtained copy of the original game."
    echo ""
    echo "Copy all .tre files from your SWG client to:"
    echo -e "  ${CYAN}${TRE_DIR}/${RESET}"
    echo ""
    echo "Required files typically include:"
    echo "  bottom.tre, data_animation_00.tre, data_music_00.tre,"
    echo "  data_other_00.tre, data_sample_00.tre, data_sample_01.tre,"
    echo "  data_skeletal_mesh_00.tre, data_static_mesh_00.tre,"
    echo "  data_texture_00.tre, default_patch.tre, patch_00.tre, etc."
    echo ""
    separator "-" 60
    echo ""

    echo -en "${CYAN}Press Enter when TRE files are copied (or 'q' to skip): ${RESET}"
    read -r response

    if [[ "$response" != "q" ]]; then
        local tre_count
        tre_count=$(find "$TRE_DIR" -name "*.tre" 2>/dev/null | wc -l)
        if [[ $tre_count -gt 0 ]]; then
            log_success "Found ${tre_count} TRE files"
        else
            log_warn "No TRE files found. Server won't start without them."
        fi
    fi
}

# Generate systemd service
generate_service_file() {
    cat << EOF
[Unit]
Description=${GAME_NAME} Dedicated Server
After=network.target mariadb.service
Requires=mariadb.service

[Service]
Type=forking
User=${SWG_USER}
WorkingDirectory=${BIN_DIR}
ExecStart=/usr/bin/screen -dmS "${SCREEN_NAME}" ${BIN_DIR}/core3
ExecStop=/usr/bin/screen -S "${SCREEN_NAME}" -X quit
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# Create systemd service
setup_systemd_service() {
    log_step 10 12 "Creating systemd service..."

    local service_content
    service_content="$(generate_service_file)"

    if ! create_systemd_service "$SERVICE_NAME" "$service_content"; then
        log_error "Failed to create systemd service"
        exit 1
    fi
}

# Enable and start the service
start_service() {
    log_step 11 12 "Enabling service..."

    # Check for TRE files before starting
    local tre_count
    tre_count=$(find "$TRE_DIR" -name "*.tre" 2>/dev/null | wc -l)

    if [[ $tre_count -eq 0 ]]; then
        log_warn "No TRE files found. Service enabled but not started."
        systemctl daemon-reload
        systemctl enable "$SERVICE_NAME"
    else
        if ! enable_service "$SERVICE_NAME"; then
            log_warn "Service may not start without proper configuration"
        fi
    fi
}

# Display completion summary
show_summary() {
    log_step 12 12 "Setup complete!"

    echo ""
    separator "=" 60
    echo ""
    echo -e "${BOLD}${GAME_NAME} Server Installation Summary${RESET}"
    echo ""
    separator "-" 60
    echo -e "  ${CYAN}Install Directory:${RESET}  ${INSTALL_DIR}"
    echo -e "  ${CYAN}Core3 Directory:${RESET}    ${CORE3_DIR}"
    echo -e "  ${CYAN}Binary Directory:${RESET}   ${BIN_DIR}"
    echo -e "  ${CYAN}TRE Files:${RESET}          ${TRE_DIR}"
    echo -e "  ${CYAN}Service Name:${RESET}       ${SERVICE_NAME}"
    echo -e "  ${CYAN}Run As User:${RESET}        ${SWG_USER}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Network Ports:${RESET}"
    echo -e "  ${DIM}Login:${RESET}    ${LOGIN_PORT}/tcp"
    echo -e "  ${DIM}Zone:${RESET}     ${ZONE_PORT}/tcp"
    echo -e "  ${DIM}Ping:${RESET}     ${PING_PORT}/udp"
    echo -e "  ${DIM}Status:${RESET}   ${STATUS_PORT}/tcp"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Database Credentials:${RESET}"
    echo -e "  ${YELLOW}Database:${RESET}   ${DB_NAME}"
    echo -e "  ${YELLOW}Username:${RESET}   ${DB_USER}"
    echo -e "  ${YELLOW}Password:${RESET}   ${DB_PASS}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Useful Commands:${RESET}"
    echo -e "  ${GREEN}Start server:${RESET}    systemctl start ${SERVICE_NAME}"
    echo -e "  ${GREEN}Stop server:${RESET}     systemctl stop ${SERVICE_NAME}"
    echo -e "  ${GREEN}Restart server:${RESET}  systemctl restart ${SERVICE_NAME}"
    echo -e "  ${GREEN}Server status:${RESET}   systemctl status ${SERVICE_NAME}"
    echo -e "  ${GREEN}View console:${RESET}    screen -r ${SCREEN_NAME}"
    echo ""
    echo -e "${BOLD}Configuration Files:${RESET}"
    echo -e "  ${DIM}Local config:${RESET}    ${BIN_DIR}/conf/config-local.lua"
    echo ""
    separator "-" 60
    echo ""
    echo -e "${YELLOW}IMPORTANT:${RESET} Copy your SWG TRE files to:"
    echo -e "  ${TRE_DIR}/"
    echo ""
    echo -e "${YELLOW}Resources:${RESET}"
    echo -e "  ${DIM}GitHub:${RESET}      https://github.com/swgemu/Core3"
    echo -e "  ${DIM}Wiki:${RESET}        https://www.swgemu.com/wiki/"
    echo ""
    separator "-" 60
    echo ""
    echo -e "${YELLOW}Firewall:${RESET} Open these ports if using a firewall:"
    echo -e "  ufw allow ${LOGIN_PORT}/tcp"
    echo -e "  ufw allow ${ZONE_PORT}/tcp"
    echo -e "  ufw allow ${PING_PORT}/udp"
    echo -e "  ufw allow ${STATUS_PORT}/tcp"
    echo ""
    separator "=" 60
    echo ""

    log_to_file "COMPLETE" "${GAME_NAME} server setup finished successfully"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    log_header "${GAME_NAME} Server Setup"
    log_to_file "START" "Beginning ${GAME_NAME} server installation"

    echo ""
    echo -e "${YELLOW}This script sets up a Star Wars Galaxies EMU server.${RESET}"
    echo -e "${YELLOW}Based on SWGEmu Core3 project.${RESET}"
    echo ""
    separator "-" 60
    echo ""
    echo "This setup will:"
    echo "  1. Install Clang 19 and build dependencies"
    echo "  2. Clone and build Core3 server"
    echo "  3. Set up MariaDB database"
    echo "  4. Create systemd service"
    echo ""
    echo "Requirements:"
    echo "  - Debian 12 / Ubuntu 22.04+ recommended"
    echo "  - 8GB+ RAM"
    echo "  - 50GB+ free disk space"
    echo "  - Original SWG .tre files"
    echo ""
    separator "-" 60
    echo ""

    echo -en "${CYAN}Continue with setup? [y/N]: ${RESET}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled."
        exit 0
    fi

    check_prerequisites
    create_swg_user
    install_dependencies
    create_directories
    clone_repository
    build_server
    setup_database
    create_config
    setup_tre_files
    setup_systemd_service
    start_service
    show_summary

    return 0
}

# Run main function
main "$@"
