# Packer Template for Windows Server 2022 on Proxmox
# This template creates a Windows Server 2022 base image for game servers
# that require Windows (e.g., City of Heroes)

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variables for customization
variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox API username"
}

variable "proxmox_password" {
  type        = string
  sensitive   = true
  description = "Proxmox API password"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node to build on"
}

variable "proxmox_storage" {
  type        = string
  default     = "local-lvm"
  description = "Storage pool for VM disks"
}

variable "proxmox_iso_storage" {
  type        = string
  default     = "local"
  description = "Storage pool for ISO files"
}

variable "vm_id" {
  type        = number
  default     = 9001
  description = "VM template ID"
}

variable "vm_name" {
  type        = string
  default     = "windows-server-template"
  description = "VM template name"
}

variable "windows_iso" {
  type        = string
  default     = "SERVER_EVAL_x64FRE_en-us.iso"
  description = "Windows Server ISO filename"
}

variable "virtio_iso" {
  type        = string
  default     = "virtio-win.iso"
  description = "VirtIO drivers ISO filename"
}

variable "winrm_username" {
  type        = string
  default     = "Administrator"
  description = "WinRM username for provisioning"
}

variable "winrm_password" {
  type        = string
  sensitive   = true
  default     = "GameServer2024!"
  description = "WinRM password for provisioning"
}

variable "vm_cores" {
  type        = number
  default     = 4
  description = "Number of CPU cores"
}

variable "vm_memory" {
  type        = number
  default     = 8192
  description = "Memory in MB"
}

variable "vm_disk_size" {
  type        = string
  default     = "100G"
  description = "Disk size"
}

# Local variables
locals {
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
}

# Proxmox source configuration
source "proxmox-iso" "windows-server" {
  # Proxmox connection settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM settings
  vm_id                = var.vm_id
  vm_name              = var.vm_name
  template_description = "Windows Server 2022 - Game Server Base Image - Built ${local.timestamp}"

  # ISO settings - Windows install ISO
  iso_file         = "${var.proxmox_iso_storage}:iso/${var.windows_iso}"
  iso_storage_pool = var.proxmox_iso_storage
  unmount_iso      = true

  # Additional ISO for VirtIO drivers
  additional_iso_files {
    device           = "sata1"
    iso_file         = "${var.proxmox_iso_storage}:iso/${var.virtio_iso}"
    unmount          = true
  }

  # System settings
  qemu_agent      = true
  scsi_controller = "virtio-scsi-pci"
  os              = "win11"
  bios            = "ovmf"
  machine         = "q35"

  efi_config {
    efi_storage_pool  = var.proxmox_storage
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  # CPU and memory
  cores    = var.vm_cores
  memory   = var.vm_memory
  cpu_type = "host"

  # Disk configuration
  disks {
    disk_size    = var.vm_disk_size
    storage_pool = var.proxmox_storage
    type         = "scsi"
    format       = "raw"
  }

  # Network configuration
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # Boot configuration
  boot      = "order=scsi0;ide2"
  boot_wait = "3s"

  # Floppy for autounattend.xml
  floppy_files = [
    "autounattend/autounattend.xml",
    "scripts/setup.ps1",
    "scripts/cloudbase-init.ps1"
  ]

  # WinRM communicator settings
  communicator   = "winrm"
  winrm_username = var.winrm_username
  winrm_password = var.winrm_password
  winrm_timeout  = "2h"
  winrm_insecure = true
  winrm_use_ssl  = false
}

# Build configuration
build {
  name    = "windows-server"
  sources = ["source.proxmox-iso.windows-server"]

  # Install QEMU guest agent
  provisioner "powershell" {
    inline = [
      "Write-Host 'Installing QEMU Guest Agent...'",
      "$virtio_drive = (Get-Volume | Where-Object { $_.FileSystemLabel -eq 'virtio-win*' }).DriveLetter",
      "if (-not $virtio_drive) { $virtio_drive = 'E' }",
      "Start-Process -Wait -FilePath \"${virtio_drive}:\\guest-agent\\qemu-ga-x86_64.msi\" -ArgumentList '/quiet'",
      "Start-Service QEMU-GA"
    ]
  }

  # Install Cloudbase-Init for cloud-init support
  provisioner "powershell" {
    inline = [
      "Write-Host 'Installing Cloudbase-Init...'",
      "$url = 'https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi'",
      "$output = 'C:\\Windows\\Temp\\CloudbaseInitSetup.msi'",
      "(New-Object System.Net.WebClient).DownloadFile($url, $output)",
      "Start-Process -Wait msiexec.exe -ArgumentList '/i', $output, '/qn', 'REBOOT=ReallySuppress'"
    ]
  }

  # Configure Cloudbase-Init
  provisioner "powershell" {
    inline = [
      "Write-Host 'Configuring Cloudbase-Init...'",
      "$configPath = 'C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\conf\\cloudbase-init.conf'",
      "@'",
      "[DEFAULT]",
      "username=Administrator",
      "groups=Administrators",
      "inject_user_password=true",
      "config_drive_raw_hhd=true",
      "config_drive_cdrom=true",
      "config_drive_vfat=true",
      "bsdtar_path=C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\bin\\bsdtar.exe",
      "mtools_path=C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\bin\\",
      "metadata_services=cloudbaseinit.metadata.services.configdrive.ConfigDriveService",
      "plugins=cloudbaseinit.plugins.common.mtu.MTUPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin,cloudbaseinit.plugins.windows.createuser.CreateUserPlugin,cloudbaseinit.plugins.common.setuserpassword.SetUserPasswordPlugin,cloudbaseinit.plugins.windows.extendvolumes.ExtendVolumesPlugin,cloudbaseinit.plugins.common.userdata.UserDataPlugin,cloudbaseinit.plugins.common.localscripts.LocalScriptsPlugin",
      "verbose=true",
      "debug=true",
      "logdir=C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\log\\",
      "logfile=cloudbase-init.log",
      "default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN",
      "logging_serial_port_settings=",
      "mtu_use_dhcp_config=true",
      "ntp_use_dhcp_config=true",
      "local_scripts_path=C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\LocalScripts\\",
      "'@ | Set-Content -Path $configPath -Force"
    ]
  }

  # Configure Windows Firewall for game servers
  provisioner "powershell" {
    inline = [
      "Write-Host 'Configuring Windows Firewall...'",
      "# Enable RDP",
      "Set-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server' -Name 'fDenyTSConnections' -Value 0",
      "Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'",
      "# Common game server ports (can be customized per-game)",
      "New-NetFirewallRule -DisplayName 'Game Servers - TCP' -Direction Inbound -Protocol TCP -LocalPort 2104,2105,7000-7100,8080,27015-27050 -Action Allow",
      "New-NetFirewallRule -DisplayName 'Game Servers - UDP' -Direction Inbound -Protocol UDP -LocalPort 7000-7100,27015-27050 -Action Allow"
    ]
  }

  # Install common tools
  provisioner "powershell" {
    inline = [
      "Write-Host 'Installing common tools...'",
      "# Install Chocolatey",
      "Set-ExecutionPolicy Bypass -Scope Process -Force",
      "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072",
      "iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))",
      "# Install common utilities",
      "choco install -y 7zip notepadplusplus git",
      "# Install Visual C++ Redistributables (common game server requirement)",
      "choco install -y vcredist-all"
    ]
  }

  # Create game server directories
  provisioner "powershell" {
    inline = [
      "Write-Host 'Creating game server directories...'",
      "New-Item -ItemType Directory -Path 'C:\\GameServers' -Force",
      "New-Item -ItemType Directory -Path 'C:\\GameServers\\CityOfHeroes' -Force",
      "New-Item -ItemType Directory -Path 'C:\\GameServers\\Logs' -Force"
    ]
  }

  # Cleanup for sysprep
  provisioner "powershell" {
    inline = [
      "Write-Host 'Cleaning up for template...'",
      "# Clear temp files",
      "Remove-Item -Path 'C:\\Windows\\Temp\\*' -Recurse -Force -ErrorAction SilentlyContinue",
      "Remove-Item -Path 'C:\\Users\\*\\AppData\\Local\\Temp\\*' -Recurse -Force -ErrorAction SilentlyContinue",
      "# Clear event logs",
      "wevtutil cl Application",
      "wevtutil cl Security",
      "wevtutil cl System",
      "# Defragment and optimize",
      "Optimize-Volume -DriveLetter C -Defrag"
    ]
  }

  # Sysprep for template
  provisioner "powershell" {
    inline = [
      "Write-Host 'Running Sysprep...'",
      "& 'C:\\Windows\\System32\\Sysprep\\sysprep.exe' /generalize /oobe /shutdown /quiet"
    ]
  }
}
