# Proxmox VM Module
# Creates a VM from a template on Proxmox VE

terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9.0"
    }
  }
}

# Clone from template and configure VM
resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  desc        = var.description
  target_node = var.proxmox_node

  # Clone from template
  clone      = var.template_name
  full_clone = var.full_clone

  # VM configuration
  vmid    = var.vmid
  onboot  = var.start_on_boot
  agent   = var.qemu_agent ? 1 : 0
  os_type = var.os_type

  # CPU configuration
  cores   = var.cpu_cores
  sockets = var.cpu_sockets
  cpu     = var.cpu_type

  # Memory configuration
  memory  = var.memory_mb
  balloon = var.balloon_memory ? var.memory_mb / 2 : 0

  # Boot configuration
  boot     = var.boot_order
  bootdisk = var.boot_disk

  # SCSI controller
  scsihw = var.scsi_controller

  # Disk configuration
  dynamic "disk" {
    for_each = var.disks
    content {
      slot     = disk.value.slot
      size     = disk.value.size
      storage  = disk.value.storage
      type     = disk.value.type
      iothread = lookup(disk.value, "iothread", 1)
      discard  = lookup(disk.value, "discard", "on")
      ssd      = lookup(disk.value, "ssd", 1)
    }
  }

  # Network configuration
  dynamic "network" {
    for_each = var.networks
    content {
      model    = network.value.model
      bridge   = network.value.bridge
      tag      = lookup(network.value, "vlan_tag", null)
      firewall = lookup(network.value, "firewall", false)
    }
  }

  # Cloud-init configuration
  cicustom                = var.cicustom
  ciuser                  = var.ciuser
  cipassword              = var.cipassword
  sshkeys                 = var.ssh_keys
  ipconfig0               = var.ipconfig0
  nameserver              = var.nameserver
  searchdomain            = var.searchdomain

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      network,
      cipassword,
    ]
  }

  # Tags
  tags = var.tags
}

# Output the VM details
output "vm_id" {
  description = "The VMID of the created VM"
  value       = proxmox_vm_qemu.vm.vmid
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_vm_qemu.vm.name
}

output "vm_ip" {
  description = "The IP address of the VM (if available)"
  value       = proxmox_vm_qemu.vm.default_ipv4_address
}

output "vm_node" {
  description = "The Proxmox node the VM is running on"
  value       = proxmox_vm_qemu.vm.target_node
}
