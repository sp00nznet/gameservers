# Game Server Group Module Variables

# Group identification
variable "group_name" {
  description = "Name of the game server group"
  type        = string
}

variable "server_type" {
  description = "Type of game servers (docker, proton, compiled, windows)"
  type        = string
  validation {
    condition     = contains(["docker", "proton", "compiled", "windows"], var.server_type)
    error_message = "Server type must be one of: docker, proton, compiled, windows"
  }
}

# Server definitions
variable "servers" {
  description = "List of servers to create in this group"
  type = list(object({
    name       = string
    vmid       = optional(number, 0)
    cpu_cores  = optional(number)
    memory_mb  = optional(number)
    disk_size  = optional(string)
    ip_address = optional(string)
    games      = optional(list(string), [])
  }))
}

# Proxmox settings
variable "proxmox_node" {
  description = "Proxmox node to deploy VMs on"
  type        = string
}

variable "storage_pool" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "cloudinit_storage" {
  description = "Storage pool for cloud-init disks"
  type        = string
  default     = "local-lvm"
}

# Network settings
variable "network_bridge" {
  description = "Network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "vlan_tag" {
  description = "VLAN tag for network (null for untagged)"
  type        = number
  default     = null
}

variable "gateway" {
  description = "Default gateway IP"
  type        = string
  default     = ""
}

variable "dns_servers" {
  description = "DNS server IPs"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "search_domain" {
  description = "DNS search domain"
  type        = string
  default     = null
}

# Cloud-init settings
variable "upload_cloud_init" {
  description = "Upload custom cloud-init configuration"
  type        = bool
  default     = false
}

variable "cloud_init_content" {
  description = "Custom cloud-init content (overrides default)"
  type        = string
  default     = null
}

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
  description = "SSH public keys for VM access"
  type        = string
  default     = null
}

# VM settings
variable "start_on_boot" {
  description = "Start VMs when Proxmox host boots"
  type        = bool
  default     = true
}

# Configuration overrides
variable "config_overrides" {
  description = "Override default server type configuration"
  type        = map(any)
  default     = {}
}
