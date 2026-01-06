#!/bin/bash
#
# World of Warcraft (AzerothCore) Dedicated Server Setup
# Downloads, compiles, and configures an AzerothCore WoW 3.3.5a server
#
# Based on: https://www.azerothcore.org/wiki/linux-server-setup
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="World of Warcraft (AzerothCore)"
readonly SERVICE_NAME_AUTH="wowauth"
readonly SERVICE_NAME_WORLD="wowworld"
readonly INSTALL_DIR="/opt/azerothcore"
readonly SOURCE_DIR="${INSTALL_DIR}/source"
readonly BUILD_DIR="${INSTALL_DIR}/build"
readonly SERVER_DIR="${INSTALL_DIR}/server"
readonly DATA_DIR="${INSTALL_DIR}/data"
readonly CLIENT_DIR="${INSTALL_DIR}/client"

# Git repository
readonly ACORE_REPO="https://github.com/azerothcore/azerothcore-wotlk.git"
readonly ACORE_BRANCH="master"

# Database configuration
readonly DB_HOST="127.0.0.1"
readonly DB_PORT="3306"
readonly DB_USER="acore"
readonly DB_PASS="acore"

# Network ports
readonly AUTH_PORT="3724"
readonly WORLD_PORT="8085"
readonly SOAP_PORT="7878"

# Screen session names
readonly SCREEN_AUTH="${SERVICE_NAME_AUTH}"
readonly SCREEN_WORLD="${SERVICE_NAME_WORLD}"

# Dedicated user
readonly WOW_USER="acore"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Validate prerequisites
check_prerequisites() {
    log_step 1 14 "Checking prerequisites..."

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
create_wow_user() {
    log_step 2 14 "Creating dedicated user..."

    if id "$WOW_USER" &>/dev/null; then
        log_info "User '${WOW_USER}' already exists"
    else
        useradd -m -s /bin/bash "$WOW_USER"
        log_success "Created user '${WOW_USER}'"
    fi
}

# Install build dependencies
install_dependencies() {
    log_step 3 14 "Installing build dependencies..."

    # Detect package manager
    if command -v apt-get &>/dev/null; then
        log_info "Installing dependencies (Debian/Ubuntu)..."

        apt-get update
        apt-get install -y \
            git \
            cmake \
            make \
            gcc \
            g++ \
            clang \
            libmysqlclient-dev \
            libssl-dev \
            libbz2-dev \
            libreadline-dev \
            libncurses-dev \
            libboost-all-dev \
            mariadb-server \
            mariadb-client \
            default-libmysqlclient-dev \
            p7zip-full \
            screen \
            curl \
            unzip \
            wget

    elif command -v dnf &>/dev/null; then
        log_info "Installing dependencies (Fedora/RHEL)..."
        dnf install -y \
            git \
            cmake \
            make \
            gcc \
            gcc-c++ \
            clang \
            mariadb-server \
            mariadb-devel \
            openssl-devel \
            bzip2-devel \
            readline-devel \
            ncurses-devel \
            boost-devel \
            p7zip \
            screen \
            curl \
            unzip \
            wget
    else
        log_error "Unsupported package manager. Please install dependencies manually."
        exit 1
    fi

    # Start MariaDB
    systemctl enable mariadb
    systemctl start mariadb

    log_success "Dependencies installed"
}

# Create directory structure
create_directories() {
    log_step 4 14 "Creating directory structure..."

    mkdir -p "$INSTALL_DIR"
    mkdir -p "$SOURCE_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$SERVER_DIR"
    mkdir -p "$DATA_DIR"
    mkdir -p "$CLIENT_DIR"
    mkdir -p "${SERVER_DIR}/etc"
    mkdir -p "${SERVER_DIR}/log"

    chown -R "${WOW_USER}:${WOW_USER}" "$INSTALL_DIR"

    log_success "Directories created"
}

# Clone AzerothCore repository
clone_repository() {
    log_step 5 14 "Cloning AzerothCore repository..."

    if [[ -d "${SOURCE_DIR}/.git" ]]; then
        log_info "Source directory exists, updating..."
        cd "$SOURCE_DIR"
        sudo -u "$WOW_USER" git fetch origin
        sudo -u "$WOW_USER" git checkout "$ACORE_BRANCH"
        sudo -u "$WOW_USER" git pull origin "$ACORE_BRANCH"
    else
        log_info "Cloning AzerothCore repository..."
        sudo -u "$WOW_USER" git clone --depth 1 -b "$ACORE_BRANCH" "$ACORE_REPO" "$SOURCE_DIR"
    fi

    log_success "Repository ready"
}

# Build the server
build_server() {
    log_step 6 14 "Building AzerothCore (this takes a while)..."

    cd "$BUILD_DIR"

    log_info "Running CMake..."
    sudo -u "$WOW_USER" cmake "$SOURCE_DIR" \
        -DCMAKE_INSTALL_PREFIX="$SERVER_DIR" \
        -DCMAKE_C_COMPILER=/usr/bin/clang \
        -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
        -DWITH_WARNINGS=1 \
        -DTOOLS_BUILD=all \
        -DSCRIPTS=static

    log_info "Compiling (using $(nproc) cores)..."
    sudo -u "$WOW_USER" make -j$(nproc)

    log_info "Installing..."
    sudo -u "$WOW_USER" make install

    if [[ ! -f "${SERVER_DIR}/bin/authserver" ]] || [[ ! -f "${SERVER_DIR}/bin/worldserver" ]]; then
        log_error "Build failed - server binaries not found"
        exit 1
    fi

    log_success "Server built successfully"
}

# Setup MariaDB database
setup_database() {
    log_step 7 14 "Setting up MariaDB database..."

    log_info "Creating database user..."
    mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';"

    # Create databases
    log_info "Creating databases..."
    mysql -e "CREATE DATABASE IF NOT EXISTS acore_world;"
    mysql -e "CREATE DATABASE IF NOT EXISTS acore_characters;"
    mysql -e "CREATE DATABASE IF NOT EXISTS acore_auth;"

    # Grant privileges
    mysql -e "GRANT ALL PRIVILEGES ON acore_world.* TO '${DB_USER}'@'localhost';"
    mysql -e "GRANT ALL PRIVILEGES ON acore_characters.* TO '${DB_USER}'@'localhost';"
    mysql -e "GRANT ALL PRIVILEGES ON acore_auth.* TO '${DB_USER}'@'localhost';"
    mysql -e "GRANT ALL PRIVILEGES ON acore_world.* TO '${DB_USER}'@'127.0.0.1';"
    mysql -e "GRANT ALL PRIVILEGES ON acore_characters.* TO '${DB_USER}'@'127.0.0.1';"
    mysql -e "GRANT ALL PRIVILEGES ON acore_auth.* TO '${DB_USER}'@'127.0.0.1';"
    mysql -e "FLUSH PRIVILEGES;"

    log_success "Database setup complete"
}

# Create server configuration
create_config() {
    log_step 8 14 "Creating server configuration..."

    # Authserver config
    local auth_conf="${SERVER_DIR}/etc/authserver.conf"
    if [[ -f "${SERVER_DIR}/etc/authserver.conf.dist" ]]; then
        cp "${SERVER_DIR}/etc/authserver.conf.dist" "$auth_conf"
        # Update database connection
        sed -i "s|^LoginDatabaseInfo.*|LoginDatabaseInfo = \"${DB_HOST};${DB_PORT};${DB_USER};${DB_PASS};acore_auth\"|" "$auth_conf"
    fi

    # Worldserver config
    local world_conf="${SERVER_DIR}/etc/worldserver.conf"
    if [[ -f "${SERVER_DIR}/etc/worldserver.conf.dist" ]]; then
        cp "${SERVER_DIR}/etc/worldserver.conf.dist" "$world_conf"
        # Update database connections
        sed -i "s|^LoginDatabaseInfo.*|LoginDatabaseInfo = \"${DB_HOST};${DB_PORT};${DB_USER};${DB_PASS};acore_auth\"|" "$world_conf"
        sed -i "s|^WorldDatabaseInfo.*|WorldDatabaseInfo = \"${DB_HOST};${DB_PORT};${DB_USER};${DB_PASS};acore_world\"|" "$world_conf"
        sed -i "s|^CharacterDatabaseInfo.*|CharacterDatabaseInfo = \"${DB_HOST};${DB_PORT};${DB_USER};${DB_PASS};acore_characters\"|" "$world_conf"
        # Set data directory
        sed -i "s|^DataDir.*|DataDir = \"${DATA_DIR}\"|" "$world_conf"
    fi

    chown -R "${WOW_USER}:${WOW_USER}" "${SERVER_DIR}/etc"

    log_success "Configuration created"
}

# Prompt for client data extraction
setup_client_data() {
    log_step 9 14 "Setting up client data..."

    echo ""
    separator "-" 60
    echo -e "${YELLOW}WoW Client Data Required${RESET}"
    echo ""
    echo "AzerothCore requires data extracted from a WoW 3.3.5a client."
    echo ""
    echo "Option 1: Extract from your own client"
    echo "  1. Copy WoW 3.3.5a client to: ${CLIENT_DIR}/"
    echo "  2. Run the extractors from: ${SERVER_DIR}/bin/"
    echo "     - mapextractor"
    echo "     - vmap4extractor && vmap4assembler"
    echo "     - mmaps_generator (takes hours)"
    echo "  3. Copy dbc, maps, vmaps, mmaps to: ${DATA_DIR}/"
    echo ""
    echo "Option 2: Use pre-extracted data"
    echo "  Copy extracted folders (dbc, maps, vmaps, mmaps) to:"
    echo "  ${DATA_DIR}/"
    echo ""
    separator "-" 60
    echo ""

    echo -en "${CYAN}Press Enter when data is ready (or 'q' to skip): ${RESET}"
    read -r response

    if [[ "$response" != "q" ]]; then
        local required_dirs=("dbc" "maps")
        local missing=0
        for dir in "${required_dirs[@]}"; do
            if [[ ! -d "${DATA_DIR}/${dir}" ]]; then
                log_warn "Missing: ${DATA_DIR}/${dir}"
                missing=1
            fi
        done
        if [[ $missing -eq 0 ]]; then
            log_success "Required data directories found"
        else
            log_warn "Some data directories missing. Server may not start."
        fi
    fi
}

# Generate authserver systemd service
generate_auth_service() {
    cat << EOF
[Unit]
Description=WoW Auth Server (AzerothCore)
After=network.target mariadb.service
Requires=mariadb.service

[Service]
Type=forking
User=${WOW_USER}
WorkingDirectory=${SERVER_DIR}/bin
ExecStart=/usr/bin/screen -dmS "${SCREEN_AUTH}" ${SERVER_DIR}/bin/authserver
ExecStop=/usr/bin/screen -S "${SCREEN_AUTH}" -X quit
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# Generate worldserver systemd service
generate_world_service() {
    cat << EOF
[Unit]
Description=WoW World Server (AzerothCore)
After=network.target mariadb.service ${SERVICE_NAME_AUTH}.service
Requires=mariadb.service
Wants=${SERVICE_NAME_AUTH}.service

[Service]
Type=forking
User=${WOW_USER}
WorkingDirectory=${SERVER_DIR}/bin
ExecStart=/usr/bin/screen -dmS "${SCREEN_WORLD}" ${SERVER_DIR}/bin/worldserver
ExecStop=/usr/bin/screen -S "${SCREEN_WORLD}" -X quit
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# Create systemd services
setup_systemd_services() {
    log_step 10 14 "Creating systemd services..."

    # Auth server service
    local auth_service
    auth_service="$(generate_auth_service)"
    echo "$auth_service" > "/etc/systemd/system/${SERVICE_NAME_AUTH}.service"

    # World server service
    local world_service
    world_service="$(generate_world_service)"
    echo "$world_service" > "/etc/systemd/system/${SERVICE_NAME_WORLD}.service"

    systemctl daemon-reload

    log_success "Services created"
}

# Enable services
enable_services() {
    log_step 11 14 "Enabling services..."

    systemctl enable "$SERVICE_NAME_AUTH"
    systemctl enable "$SERVICE_NAME_WORLD"

    # Check for required data before starting
    if [[ -d "${DATA_DIR}/dbc" ]] && [[ -d "${DATA_DIR}/maps" ]]; then
        log_info "Starting auth server..."
        systemctl start "$SERVICE_NAME_AUTH"
        sleep 3

        log_info "Starting world server..."
        systemctl start "$SERVICE_NAME_WORLD"
    else
        log_warn "Data directories not found. Services enabled but not started."
        log_info "Copy client data to ${DATA_DIR}/ then start services manually."
    fi
}

# Set up realmlist
setup_realmlist() {
    log_step 12 14 "Setting up realmlist..."

    local server_ip
    server_ip=$(hostname -I | awk '{print $1}')

    log_info "Updating realmlist for IP: ${server_ip}"

    mysql acore_auth -e "UPDATE realmlist SET address = '${server_ip}', localAddress = '127.0.0.1' WHERE id = 1;" 2>/dev/null || true

    log_success "Realmlist updated"
}

# Create admin account helper
create_admin_helper() {
    log_step 13 14 "Creating admin account helper..."

    local helper_script="${SERVER_DIR}/bin/create_account.sh"

    cat > "$helper_script" << 'EOF'
#!/bin/bash
# Create a WoW account via worldserver console

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    echo "Usage: $0 <username> <password> [gmlevel]"
    echo "  gmlevel: 0=player, 1=moderator, 2=gamemaster, 3=admin"
    exit 1
fi

USERNAME="$1"
PASSWORD="$2"
GMLEVEL="${3:-0}"

screen -S wowworld -X stuff "account create $USERNAME $PASSWORD\n"
sleep 1

if [[ "$GMLEVEL" -gt 0 ]]; then
    screen -S wowworld -X stuff "account set gmlevel $USERNAME $GMLEVEL -1\n"
fi

echo "Account '$USERNAME' created with GM level $GMLEVEL"
EOF

    chmod +x "$helper_script"
    chown "${WOW_USER}:${WOW_USER}" "$helper_script"

    log_success "Admin helper created"
}

# Display completion summary
show_summary() {
    log_step 14 14 "Setup complete!"

    local server_ip
    server_ip=$(hostname -I | awk '{print $1}')

    echo ""
    separator "=" 60
    echo ""
    echo -e "${BOLD}${GAME_NAME} Server Installation Summary${RESET}"
    echo ""
    separator "-" 60
    echo -e "  ${CYAN}Install Directory:${RESET}  ${INSTALL_DIR}"
    echo -e "  ${CYAN}Server Directory:${RESET}   ${SERVER_DIR}"
    echo -e "  ${CYAN}Data Directory:${RESET}     ${DATA_DIR}"
    echo -e "  ${CYAN}Auth Service:${RESET}       ${SERVICE_NAME_AUTH}"
    echo -e "  ${CYAN}World Service:${RESET}      ${SERVICE_NAME_WORLD}"
    echo -e "  ${CYAN}Run As User:${RESET}        ${WOW_USER}"
    echo -e "  ${CYAN}Server IP:${RESET}          ${server_ip}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Network Ports:${RESET}"
    echo -e "  ${DIM}Auth Server:${RESET}    ${AUTH_PORT}/tcp"
    echo -e "  ${DIM}World Server:${RESET}   ${WORLD_PORT}/tcp"
    echo -e "  ${DIM}SOAP:${RESET}           ${SOAP_PORT}/tcp"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Database Credentials:${RESET}"
    echo -e "  ${YELLOW}Username:${RESET}   ${DB_USER}"
    echo -e "  ${YELLOW}Password:${RESET}   ${DB_PASS}"
    echo -e "  ${YELLOW}Databases:${RESET}  acore_world, acore_characters, acore_auth"
    separator "-" 60
    echo ""
    echo -e "${BOLD}Useful Commands:${RESET}"
    echo -e "  ${GREEN}Start auth:${RESET}      systemctl start ${SERVICE_NAME_AUTH}"
    echo -e "  ${GREEN}Start world:${RESET}     systemctl start ${SERVICE_NAME_WORLD}"
    echo -e "  ${GREEN}Stop all:${RESET}        systemctl stop ${SERVICE_NAME_WORLD} ${SERVICE_NAME_AUTH}"
    echo -e "  ${GREEN}Auth console:${RESET}    screen -r ${SCREEN_AUTH}"
    echo -e "  ${GREEN}World console:${RESET}   screen -r ${SCREEN_WORLD}"
    echo ""
    echo -e "${BOLD}Create Account:${RESET}"
    echo -e "  ${SERVER_DIR}/bin/create_account.sh <user> <pass> [gmlevel]"
    echo ""
    echo -e "${BOLD}Configuration Files:${RESET}"
    echo -e "  ${DIM}Auth config:${RESET}     ${SERVER_DIR}/etc/authserver.conf"
    echo -e "  ${DIM}World config:${RESET}    ${SERVER_DIR}/etc/worldserver.conf"
    echo ""
    separator "-" 60
    echo ""
    echo -e "${YELLOW}Client Setup:${RESET}"
    echo "  1. Install WoW 3.3.5a client"
    echo "  2. Edit Data/enUS/realmlist.wtf (or your locale)"
    echo "  3. Set: set realmlist ${server_ip}"
    echo ""
    echo -e "${YELLOW}Resources:${RESET}"
    echo -e "  ${DIM}Wiki:${RESET}        https://www.azerothcore.org/wiki/"
    echo -e "  ${DIM}GitHub:${RESET}      https://github.com/azerothcore/azerothcore-wotlk"
    echo ""
    separator "-" 60
    echo ""
    echo -e "${YELLOW}Firewall:${RESET} Open these ports if using a firewall:"
    echo -e "  ufw allow ${AUTH_PORT}/tcp"
    echo -e "  ufw allow ${WORLD_PORT}/tcp"
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
    echo -e "${YELLOW}This script sets up a World of Warcraft 3.3.5a server.${RESET}"
    echo -e "${YELLOW}Based on AzerothCore (Wrath of the Lich King).${RESET}"
    echo ""
    separator "-" 60
    echo ""
    echo "This setup will:"
    echo "  1. Install build dependencies"
    echo "  2. Clone and build AzerothCore"
    echo "  3. Set up MariaDB databases"
    echo "  4. Create systemd services"
    echo ""
    echo "Requirements:"
    echo "  - Ubuntu 20.04+ / Debian 11+ recommended"
    echo "  - 8GB+ RAM (16GB recommended)"
    echo "  - 50GB+ free disk space"
    echo "  - WoW 3.3.5a client for data extraction"
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
    create_wow_user
    install_dependencies
    create_directories
    clone_repository
    build_server
    setup_database
    create_config
    setup_client_data
    setup_systemd_services
    enable_services
    setup_realmlist
    create_admin_helper
    show_summary

    return 0
}

# Run main function
main "$@"
