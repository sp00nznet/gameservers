#!/bin/bash
#
# City of Heroes (Ouroboros Volume 2) Dedicated Server Setup
# Creates a Windows VM, downloads game files, and configures the server
#
# This script sets up a complete City of Heroes private server using:
# - QEMU/KVM for Windows virtualization
# - Windows Server Evaluation for the guest OS
# - Ouroboros Volume 2 server files
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "${SCRIPT_DIR}/../lib/common.sh"

# Server configuration
readonly GAME_NAME="City of Heroes"
readonly SERVICE_NAME="cohserver"
readonly INSTALL_DIR="/opt/cohserver"
readonly VM_DIR="${INSTALL_DIR}/vm"
readonly ISO_DIR="${INSTALL_DIR}/iso"
readonly TORRENT_DIR="${INSTALL_DIR}/torrents"

# VM Configuration
readonly VM_NAME="coh-windows-server"
readonly VM_RAM="8192"          # 8GB minimum, 32GB recommended
readonly VM_CPUS="4"
readonly VM_DISK_SIZE="100G"    # 100GB for Windows + CoH files
readonly VM_DISK="${VM_DIR}/${VM_NAME}.qcow2"

# Windows ISO (Windows Server 2022 Evaluation)
readonly WINDOWS_ISO_URL="https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US"
readonly WINDOWS_ISO="${ISO_DIR}/windows_server_2022_eval.iso"

# VirtIO drivers for Windows
readonly VIRTIO_ISO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
readonly VIRTIO_ISO="${ISO_DIR}/virtio-win.iso"

# Ouroboros Volume 2 Self Installer
# Visit https://wiki.ourodev.com/Volume_2_VMs_%26_Self_Installer for current magnet link
readonly COH_TORRENT_FILE="${TORRENT_DIR}/coh_server.torrent"

# Network ports (for VM port forwarding)
readonly COH_AUTH_PORT="2104"
readonly COH_DB_PORT="2105"
readonly COH_GAME_PORT="7000-7100"
readonly COH_WEB_PORT="8080"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Validate prerequisites
check_prerequisites() {
    log_step 1 10 "Checking prerequisites..."

    local deps=("curl" "wget" "screen" "systemctl")

    if ! check_dependencies "${deps[@]}"; then
        log_error "Missing dependencies. Please install them first."
        exit 1
    fi

    # Check CPU virtualization support
    if ! grep -qE '(vmx|svm)' /proc/cpuinfo; then
        log_error "CPU virtualization (VT-x/AMD-V) not supported or not enabled in BIOS"
        exit 1
    fi

    # Check available RAM
    local total_ram
    total_ram=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $total_ram -lt 10000 ]]; then
        log_warn "System has ${total_ram}MB RAM. Recommended: 32GB+ for CoH server"
        log_info "Minimum 8GB allocated to VM, need extra for host system"
    fi

    # Check available disk space
    local free_space
    free_space=$(df -BG /opt 2>/dev/null | awk 'NR==2 {print $4}' | tr -d 'G')
    if [[ ${free_space:-0} -lt 150 ]]; then
        log_warn "Low disk space. Recommended: 150GB+ free"
    fi

    log_success "Prerequisites check complete"
}

# Install virtualization packages
install_virtualization() {
    log_step 2 10 "Installing virtualization packages..."

    # Detect package manager
    if command -v apt-get &>/dev/null; then
        log_info "Installing QEMU/KVM packages (Debian/Ubuntu)..."
        apt-get update
        apt-get install -y \
            qemu-kvm \
            libvirt-daemon-system \
            libvirt-clients \
            virtinst \
            bridge-utils \
            virt-manager \
            ovmf \
            transmission-cli \
            p7zip-full
    elif command -v dnf &>/dev/null; then
        log_info "Installing QEMU/KVM packages (Fedora/RHEL)..."
        dnf install -y \
            qemu-kvm \
            libvirt \
            libvirt-client \
            virt-install \
            virt-manager \
            edk2-ovmf \
            transmission-cli \
            p7zip
    elif command -v pacman &>/dev/null; then
        log_info "Installing QEMU/KVM packages (Arch)..."
        pacman -S --noconfirm \
            qemu-full \
            libvirt \
            virt-install \
            virt-manager \
            edk2-ovmf \
            transmission-cli \
            p7zip
    else
        log_error "Unsupported package manager. Please install QEMU/KVM manually."
        exit 1
    fi

    # Enable and start libvirt
    systemctl enable libvirtd
    systemctl start libvirtd

    log_success "Virtualization packages installed"
}

# Create directory structure
create_directories() {
    log_step 3 10 "Creating directory structure..."

    mkdir -p "$VM_DIR"
    mkdir -p "$ISO_DIR"
    mkdir -p "$TORRENT_DIR"
    mkdir -p "${INSTALL_DIR}/shared"

    log_success "Directories created"
}

# Download Windows Server evaluation ISO
download_windows_iso() {
    log_step 4 10 "Downloading Windows Server 2022 Evaluation ISO..."

    if [[ -f "$WINDOWS_ISO" ]]; then
        log_info "Windows ISO already exists, skipping download"
    else
        log_info "This may take a while (5-6GB download)..."
        log_info "Downloading from Microsoft..."

        # Microsoft requires a form submission, provide manual instructions
        echo ""
        separator "-" 60
        echo -e "${YELLOW}Windows Server ISO Download${RESET}"
        echo ""
        echo "The Windows Server Evaluation ISO requires manual download:"
        echo ""
        echo "1. Visit: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022"
        echo "2. Fill out the registration form"
        echo "3. Download the ISO (64-bit edition)"
        echo "4. Save it as: ${WINDOWS_ISO}"
        echo ""
        echo "Alternatively, download Windows 10/11 Enterprise Evaluation:"
        echo "   https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise"
        echo ""
        separator "-" 60
        echo ""

        echo -en "${CYAN}Press Enter when ISO is downloaded, or 'q' to quit: ${RESET}"
        read -r response
        if [[ "$response" == "q" ]]; then
            log_info "Setup paused. Run script again when ISO is ready."
            exit 0
        fi

        if [[ ! -f "$WINDOWS_ISO" ]]; then
            log_error "Windows ISO not found at: ${WINDOWS_ISO}"
            exit 1
        fi
    fi

    log_success "Windows ISO ready"
}

# Download VirtIO drivers
download_virtio_drivers() {
    log_step 5 10 "Downloading VirtIO drivers for Windows..."

    if [[ -f "$VIRTIO_ISO" ]]; then
        log_info "VirtIO ISO already exists, skipping download"
    else
        log_info "Downloading VirtIO drivers..."
        wget -q --show-progress -O "$VIRTIO_ISO" "$VIRTIO_ISO_URL"
    fi

    log_success "VirtIO drivers ready"
}

# Download City of Heroes server files via torrent
download_coh_files() {
    log_step 6 10 "Downloading City of Heroes server files..."

    echo ""
    separator "-" 60
    echo -e "${YELLOW}City of Heroes Server Files Download${RESET}"
    echo ""
    echo "The CoH server files are distributed via torrent."
    echo ""
    echo "Option 1: Get the magnet link from:"
    echo "   https://wiki.ourodev.com/Volume_2_VMs_%26_Self_Installer"
    echo "   https://wiki.ourodev.com/Magnet_Links"
    echo ""
    echo "Option 2: Download from OuroDev CI site:"
    echo "   https://ourodev.com/"
    echo ""
    echo "Look for: Ouroboros_v2i201_self_installer.7z (or newer version)"
    echo ""
    separator "-" 60
    echo ""

    echo -en "${CYAN}Enter magnet link or path to downloaded .7z file: ${RESET}"
    read -r coh_source

    if [[ "$coh_source" == magnet:* ]]; then
        log_info "Downloading via torrent..."
        transmission-cli -w "${INSTALL_DIR}/shared" "$coh_source"
    elif [[ -f "$coh_source" ]]; then
        log_info "Copying provided file..."
        cp "$coh_source" "${INSTALL_DIR}/shared/"
    else
        log_warn "No valid source provided. You'll need to manually place the CoH files."
        log_info "Place the Ouroboros self-installer .7z in: ${INSTALL_DIR}/shared/"
    fi

    # Extract if 7z file exists
    local coh_archive
    coh_archive=$(find "${INSTALL_DIR}/shared" -name "*.7z" -type f 2>/dev/null | head -1)
    if [[ -n "$coh_archive" ]]; then
        log_info "Extracting CoH files..."
        7z x -o"${INSTALL_DIR}/shared/COH" "$coh_archive" -y
        log_success "CoH files extracted"
    fi

    log_success "CoH files download step complete"
}

# Create the Windows VM
create_windows_vm() {
    log_step 7 10 "Creating Windows VM..."

    # Check if VM already exists
    if virsh list --all | grep -q "$VM_NAME"; then
        log_info "VM '${VM_NAME}' already exists"
        echo -en "${CYAN}Delete and recreate? [y/N]: ${RESET}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            virsh destroy "$VM_NAME" 2>/dev/null || true
            virsh undefine "$VM_NAME" --remove-all-storage 2>/dev/null || true
        else
            log_info "Keeping existing VM"
            return 0
        fi
    fi

    # Create VM disk
    log_info "Creating ${VM_DISK_SIZE} virtual disk..."
    qemu-img create -f qcow2 "$VM_DISK" "$VM_DISK_SIZE"

    # Create the VM with virt-install
    log_info "Creating VM (this will open a console for Windows installation)..."

    virt-install \
        --name "$VM_NAME" \
        --ram "$VM_RAM" \
        --vcpus "$VM_CPUS" \
        --os-variant win2k22 \
        --disk path="$VM_DISK",format=qcow2,bus=virtio \
        --disk path="$VIRTIO_ISO",device=cdrom \
        --cdrom "$WINDOWS_ISO" \
        --network network=default,model=virtio \
        --graphics spice,listen=0.0.0.0 \
        --video qxl \
        --boot uefi \
        --noautoconsole

    log_success "VM created"

    echo ""
    separator "-" 60
    echo -e "${YELLOW}Windows Installation Required${RESET}"
    echo ""
    echo "A Windows VM has been created. You need to:"
    echo ""
    echo "1. Connect to the VM console:"
    echo "   virt-manager  (GUI)"
    echo "   OR"
    echo "   virsh console ${VM_NAME}"
    echo ""
    echo "2. Install Windows Server 2022:"
    echo "   - Select 'Desktop Experience' edition"
    echo "   - When selecting disk, load VirtIO drivers from D:\\amd64\\w2k22\\"
    echo "   - Complete the Windows installation"
    echo ""
    echo "3. After Windows is installed:"
    echo "   - Install VirtIO guest tools from D:\\"
    echo "   - Enable Remote Desktop"
    echo "   - Configure static IP or note the DHCP IP"
    echo ""
    separator "-" 60
    echo ""

    echo -en "${CYAN}Press Enter when Windows installation is complete: ${RESET}"
    read -r
}

# Configure shared folder for file transfer
setup_shared_folder() {
    log_step 8 10 "Setting up file sharing with VM..."

    # Create Samba share for transferring files to Windows
    if command -v apt-get &>/dev/null; then
        apt-get install -y samba
    elif command -v dnf &>/dev/null; then
        dnf install -y samba
    fi

    # Configure Samba share
    cat >> /etc/samba/smb.conf << EOF

[cohshare]
    path = ${INSTALL_DIR}/shared
    browseable = yes
    read only = no
    guest ok = yes
    force user = root
EOF

    systemctl restart smbd 2>/dev/null || systemctl restart smb 2>/dev/null || true

    local host_ip
    host_ip=$(hostname -I | awk '{print $1}')

    echo ""
    separator "-" 60
    echo -e "${YELLOW}File Transfer Instructions${RESET}"
    echo ""
    echo "CoH files are available at: ${INSTALL_DIR}/shared/"
    echo ""
    echo "To access from Windows VM:"
    echo "1. Open File Explorer"
    echo "2. Navigate to: \\\\${host_ip}\\cohshare"
    echo "3. Copy the COH folder to C:\\COH on the Windows VM"
    echo ""
    separator "-" 60
    echo ""

    log_success "File sharing configured"
}

# Provide CoH installation instructions
show_coh_install_instructions() {
    log_step 9 10 "City of Heroes Installation Instructions..."

    echo ""
    separator "=" 60
    echo ""
    echo -e "${BOLD}City of Heroes Server Installation (In Windows VM)${RESET}"
    echo ""
    separator "-" 60
    echo ""
    echo -e "${CYAN}Step 1: Copy Files${RESET}"
    echo "  Copy the COH folder from the network share to C:\\COH"
    echo ""
    echo -e "${CYAN}Step 2: Run Installer${RESET}"
    echo "  1. Open C:\\COH folder"
    echo "  2. Run '1 - install apps.bat'"
    echo "     - Follow each prerequisite installer"
    echo "     - Accept default options"
    echo ""
    echo -e "${CYAN}Step 3: Setup Database${RESET}"
    echo "  Run '2 - Setup DB.bat'"
    echo "  - This creates the SQL Server database"
    echo "  - Wait for completion"
    echo ""
    echo -e "${CYAN}Step 4: Configure Firewall (Optional - for network play)${RESET}"
    echo "  Right-click '3 - Firewall rules (run as admin).bat'"
    echo "  Select 'Run as Administrator'"
    echo ""
    echo -e "${CYAN}Step 5: Start Server${RESET}"
    echo "  Run '4 - Start Server.bat' or 'Start Server.bat'"
    echo ""
    echo -e "${CYAN}Step 6: Create Admin Account${RESET}"
    echo "  Use COHDBTool10 to create accounts:"
    echo "  - Run COHDBTool10.exe"
    echo "  - Create a new account with access level 10 (admin)"
    echo ""
    separator "-" 60
    echo ""
    echo -e "${BOLD}Client Connection:${RESET}"
    echo "  Clients need to point to your server IP"
    echo "  Default server name: Ouroboros"
    echo ""
    echo -e "${BOLD}Ports Used:${RESET}"
    echo "  Auth Server:  TCP ${COH_AUTH_PORT}"
    echo "  DB Server:    TCP ${COH_DB_PORT}"
    echo "  Game:         UDP ${COH_GAME_PORT}"
    echo "  Web Admin:    TCP ${COH_WEB_PORT}"
    echo ""
    separator "=" 60
    echo ""
}

# Generate systemd service for VM auto-start
create_vm_service() {
    log_step 10 10 "Creating VM auto-start service..."

    cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=City of Heroes Windows VM Server
After=libvirtd.service network.target
Requires=libvirtd.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/virsh start ${VM_NAME}
ExecStop=/usr/bin/virsh shutdown ${VM_NAME}
TimeoutStopSec=120

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable "${SERVICE_NAME}"

    log_success "VM auto-start service created"
}

# Display completion summary
show_summary() {
    echo ""
    separator "=" 60
    echo ""
    echo -e "${BOLD}${GAME_NAME} Server Installation Summary${RESET}"
    echo ""
    separator "-" 60
    echo -e "  ${CYAN}VM Name:${RESET}            ${VM_NAME}"
    echo -e "  ${CYAN}VM RAM:${RESET}             ${VM_RAM}MB"
    echo -e "  ${CYAN}VM CPUs:${RESET}            ${VM_CPUS}"
    echo -e "  ${CYAN}VM Disk:${RESET}            ${VM_DISK}"
    echo -e "  ${CYAN}Shared Folder:${RESET}      ${INSTALL_DIR}/shared"
    echo -e "  ${CYAN}Service Name:${RESET}       ${SERVICE_NAME}"
    separator "-" 60
    echo ""
    echo -e "${BOLD}VM Management Commands:${RESET}"
    echo -e "  ${GREEN}Start VM:${RESET}        virsh start ${VM_NAME}"
    echo -e "  ${GREEN}Stop VM:${RESET}         virsh shutdown ${VM_NAME}"
    echo -e "  ${GREEN}Force Stop:${RESET}      virsh destroy ${VM_NAME}"
    echo -e "  ${GREEN}Console:${RESET}         virt-manager (GUI)"
    echo -e "  ${GREEN}Status:${RESET}          virsh list --all"
    echo ""
    echo -e "${BOLD}Service Commands:${RESET}"
    echo -e "  ${GREEN}Start service:${RESET}   systemctl start ${SERVICE_NAME}"
    echo -e "  ${GREEN}Stop service:${RESET}    systemctl stop ${SERVICE_NAME}"
    echo -e "  ${GREEN}Status:${RESET}          systemctl status ${SERVICE_NAME}"
    echo ""
    separator "-" 60
    echo ""
    echo -e "${BOLD}Resources:${RESET}"
    echo -e "  ${DIM}OuroDev Wiki:${RESET}    https://wiki.ourodev.com/"
    echo -e "  ${DIM}Server Setup:${RESET}    https://wiki.ourodev.com/Volume_2_Server_Setup"
    echo -e "  ${DIM}VM Guide:${RESET}        https://wiki.ourodev.com/Volume_2_VMs_%26_Self_Installer"
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
    echo -e "${YELLOW}This script sets up a City of Heroes private server.${RESET}"
    echo -e "${YELLOW}It requires a Windows VM with 8-32GB RAM.${RESET}"
    echo ""
    separator "-" 60
    echo ""
    echo "This setup will:"
    echo "  1. Install QEMU/KVM virtualization"
    echo "  2. Download Windows Server Evaluation ISO"
    echo "  3. Create a Windows VM"
    echo "  4. Download CoH server files"
    echo "  5. Set up file sharing for easy transfer"
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
    install_virtualization
    create_directories
    download_windows_iso
    download_virtio_drivers
    download_coh_files
    create_windows_vm
    setup_shared_folder
    show_coh_install_instructions
    create_vm_service
    show_summary

    return 0
}

# Run main function
main "$@"
