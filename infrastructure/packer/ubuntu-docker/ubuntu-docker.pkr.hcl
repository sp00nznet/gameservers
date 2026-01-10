# Packer Template for Ubuntu Docker Base Image on Proxmox
# This template creates a Ubuntu 22.04 LTS base image with Docker pre-installed
# for running containerized game servers

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
  description = "Proxmox API username (e.g., root@pam or user@pve)"
}

variable "proxmox_password" {
  type        = string
  sensitive   = true
  description = "Proxmox API password or token"
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
  default     = 9000
  description = "VM template ID"
}

variable "vm_name" {
  type        = string
  default     = "ubuntu-docker-template"
  description = "VM template name"
}

variable "ubuntu_iso" {
  type        = string
  default     = "ubuntu-22.04.3-live-server-amd64.iso"
  description = "Ubuntu ISO filename"
}

variable "ssh_username" {
  type        = string
  default     = "gameserver"
  description = "SSH username for provisioning"
}

variable "ssh_password" {
  type        = string
  sensitive   = true
  default     = "gameserver"
  description = "SSH password for provisioning (will be removed)"
}

variable "vm_cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores"
}

variable "vm_memory" {
  type        = number
  default     = 4096
  description = "Memory in MB"
}

variable "vm_disk_size" {
  type        = string
  default     = "32G"
  description = "Disk size"
}

# Local variables
locals {
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
}

# Proxmox source configuration
source "proxmox-iso" "ubuntu-docker" {
  # Proxmox connection settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM settings
  vm_id                = var.vm_id
  vm_name              = var.vm_name
  template_description = "Ubuntu 22.04 LTS with Docker - Game Server Base Image - Built ${local.timestamp}"

  # ISO settings
  iso_file         = "${var.proxmox_iso_storage}:iso/${var.ubuntu_iso}"
  iso_storage_pool = var.proxmox_iso_storage
  unmount_iso      = true

  # System settings
  qemu_agent = true
  scsi_controller = "virtio-scsi-pci"

  # CPU and memory
  cores  = var.vm_cores
  memory = var.vm_memory
  cpu_type = "host"

  # Disk configuration
  disks {
    disk_size         = var.vm_disk_size
    storage_pool      = var.proxmox_storage
    type              = "scsi"
    format            = "raw"
  }

  # Network configuration
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # Cloud-init settings
  cloud_init              = true
  cloud_init_storage_pool = var.proxmox_storage

  # Boot configuration for autoinstall
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  boot      = "c"
  boot_wait = "5s"

  # HTTP server for autoinstall
  http_directory = "http"

  # SSH settings for provisioning
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = "30m"
  ssh_handshake_attempts = 100
}

# Build configuration
build {
  name    = "ubuntu-docker"
  sources = ["source.proxmox-iso.ubuntu-docker"]

  # Wait for cloud-init to complete
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done"
    ]
  }

  # Update system and install Docker
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y ca-certificates curl gnupg lsb-release qemu-guest-agent"
    ]
  }

  # Install Docker
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
    ]
  }

  # Configure Docker
  provisioner "shell" {
    inline = [
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ${var.ssh_username}"
    ]
  }

  # Install common game server dependencies
  provisioner "shell" {
    inline = [
      "sudo dpkg --add-architecture i386",
      "sudo apt-get update",
      "sudo apt-get install -y lib32gcc-s1 lib32stdc++6 libsdl2-2.0-0:i386 screen htop tmux curl wget unzip"
    ]
  }

  # Create game server directories
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/gameservers",
      "sudo mkdir -p /opt/steamcmd",
      "sudo chown -R ${var.ssh_username}:${var.ssh_username} /opt/gameservers /opt/steamcmd"
    ]
  }

  # Clean up for template
  provisioner "shell" {
    inline = [
      "sudo apt-get autoremove -y",
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo cloud-init clean",
      "sudo sync"
    ]
  }
}
