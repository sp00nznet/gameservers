# Production Environment Variables

# ============================================================================
# Proxmox Connection Settings
# ============================================================================
variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://proxmox.example.com:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID (e.g., user@pam!token-name)"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Proxmox node to deploy VMs on"
  type        = string
}

# ============================================================================
# Storage Settings
# ============================================================================
variable "storage_pool" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

# ============================================================================
# Network Settings
# ============================================================================
variable "network_bridge" {
  description = "Network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "game_vlan_tag" {
  description = "VLAN tag for game server network (null for untagged)"
  type        = number
  default     = null
}

variable "gateway" {
  description = "Default gateway IP address"
  type        = string
}

variable "dns_servers" {
  description = "DNS server IP addresses"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# ============================================================================
# SSH Settings
# ============================================================================
variable "ssh_user" {
  description = "SSH username for VMs"
  type        = string
  default     = "gameserver"
}

variable "ssh_password" {
  description = "SSH password for VMs"
  type        = string
  sensitive   = true
  default     = null
}

variable "ssh_public_keys" {
  description = "SSH public keys for VM access (newline separated)"
  type        = string
  default     = null
}

# ============================================================================
# Server IP Addresses (Static IPs for each server group)
# Set to null for DHCP
# ============================================================================
variable "source_engine_ip" {
  description = "IP address for Source Engine server (e.g., 192.168.1.100/24)"
  type        = string
  default     = null
}

variable "survival_ip" {
  description = "IP address for Survival games server (e.g., 192.168.1.101/24)"
  type        = string
  default     = null
}

variable "classic_ip" {
  description = "IP address for Classic games server (e.g., 192.168.1.102/24)"
  type        = string
  default     = null
}

variable "ark_ip" {
  description = "IP address for ARK server (e.g., 192.168.1.103/24)"
  type        = string
  default     = null
}

variable "wow_ip" {
  description = "IP address for WoW (AzerothCore) server (e.g., 192.168.1.104/24)"
  type        = string
  default     = null
}

variable "swgemu_ip" {
  description = "IP address for SWGEmu server (e.g., 192.168.1.105/24)"
  type        = string
  default     = null
}

variable "coh_ip" {
  description = "IP address for City of Heroes server (e.g., 192.168.1.106/24)"
  type        = string
  default     = null
}
