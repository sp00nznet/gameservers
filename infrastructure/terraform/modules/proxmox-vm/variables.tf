# Proxmox VM Module Variables

# Basic VM settings
variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "description" {
  description = "Description of the VM"
  type        = string
  default     = ""
}

variable "proxmox_node" {
  description = "Proxmox node to create the VM on"
  type        = string
}

variable "template_name" {
  description = "Name of the template to clone from"
  type        = string
}

variable "vmid" {
  description = "VM ID (0 for auto-assign)"
  type        = number
  default     = 0
}

variable "full_clone" {
  description = "Create a full clone (true) or linked clone (false)"
  type        = bool
  default     = true
}

variable "start_on_boot" {
  description = "Start VM when Proxmox host boots"
  type        = bool
  default     = true
}

variable "qemu_agent" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = true
}

variable "os_type" {
  description = "OS type (cloud-init)"
  type        = string
  default     = "cloud-init"
}

# CPU settings
variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "cpu_type" {
  description = "CPU type"
  type        = string
  default     = "host"
}

# Memory settings
variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 4096
}

variable "balloon_memory" {
  description = "Enable memory ballooning"
  type        = bool
  default     = false
}

# Boot settings
variable "boot_order" {
  description = "Boot order"
  type        = string
  default     = "order=scsi0"
}

variable "boot_disk" {
  description = "Boot disk"
  type        = string
  default     = "scsi0"
}

variable "scsi_controller" {
  description = "SCSI controller type"
  type        = string
  default     = "virtio-scsi-pci"
}

# Disk configuration
variable "disks" {
  description = "List of disk configurations"
  type = list(object({
    slot     = string
    size     = string
    storage  = string
    type     = string
    iothread = optional(number, 1)
    discard  = optional(string, "on")
    ssd      = optional(number, 1)
  }))
  default = [{
    slot    = "scsi0"
    size    = "32G"
    storage = "local-lvm"
    type    = "disk"
  }]
}

# Network configuration
variable "networks" {
  description = "List of network configurations"
  type = list(object({
    model    = string
    bridge   = string
    vlan_tag = optional(number)
    firewall = optional(bool, false)
  }))
  default = [{
    model  = "virtio"
    bridge = "vmbr0"
  }]
}

# Cloud-init settings
variable "cicustom" {
  description = "Custom cloud-init configuration (storage:path format)"
  type        = string
  default     = null
}

variable "ciuser" {
  description = "Cloud-init user"
  type        = string
  default     = null
}

variable "cipassword" {
  description = "Cloud-init password"
  type        = string
  sensitive   = true
  default     = null
}

variable "ssh_keys" {
  description = "SSH public keys for cloud-init"
  type        = string
  default     = null
}

variable "ipconfig0" {
  description = "IP configuration for first network interface"
  type        = string
  default     = "ip=dhcp"
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = null
}

variable "searchdomain" {
  description = "DNS search domain"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags for the VM"
  type        = string
  default     = ""
}
