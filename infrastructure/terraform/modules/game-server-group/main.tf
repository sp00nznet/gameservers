# Game Server Group Module
# Deploys a group of game server VMs of the same type on Proxmox

terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9.0"
    }
  }
}

# Local values for configuration
locals {
  # Default configurations per server type
  server_type_defaults = {
    docker = {
      template     = "ubuntu-docker-template"
      cpu_cores    = 4
      memory_mb    = 8192
      disk_size    = "50G"
      os_type      = "cloud-init"
      cloud_init   = "docker-gameserver.yaml"
    }
    proton = {
      template     = "ubuntu-docker-template"
      cpu_cores    = 4
      memory_mb    = 16384
      disk_size    = "100G"
      os_type      = "cloud-init"
      cloud_init   = "proton-gameserver.yaml"
    }
    compiled = {
      template     = "ubuntu-docker-template"
      cpu_cores    = 8
      memory_mb    = 16384
      disk_size    = "100G"
      os_type      = "cloud-init"
      cloud_init   = "compiled-gameserver.yaml"
    }
    windows = {
      template     = "windows-server-template"
      cpu_cores    = 4
      memory_mb    = 8192
      disk_size    = "100G"
      os_type      = "win11"
      cloud_init   = "windows-gameserver.yaml"
    }
  }

  # Merge defaults with user config
  server_config = merge(
    local.server_type_defaults[var.server_type],
    var.config_overrides
  )

  # Generate server instances
  servers = {
    for idx, server in var.servers :
    server.name => {
      name        = server.name
      vmid        = lookup(server, "vmid", 0)
      cpu_cores   = lookup(server, "cpu_cores", local.server_config.cpu_cores)
      memory_mb   = lookup(server, "memory_mb", local.server_config.memory_mb)
      disk_size   = lookup(server, "disk_size", local.server_config.disk_size)
      ip_address  = lookup(server, "ip_address", null)
      games       = lookup(server, "games", [])
    }
  }
}

# Upload cloud-init configuration
resource "proxmox_cloud_init_disk" "cloudinit" {
  for_each = var.upload_cloud_init ? local.servers : {}

  name     = "${each.key}-cloudinit"
  pve_node = var.proxmox_node
  storage  = var.cloudinit_storage

  meta_data = yamlencode({
    instance-id    = each.key
    local-hostname = each.key
  })

  user_data = var.cloud_init_content != null ? var.cloud_init_content : file("${path.module}/../../../cloud-init/${local.server_config.cloud_init}")

  network_config = yamlencode({
    version = 2
    ethernets = {
      eth0 = each.value.ip_address != null ? {
        addresses = [each.value.ip_address]
        gateway4  = var.gateway
        nameservers = {
          addresses = var.dns_servers
        }
      } : {
        dhcp4 = true
      }
    }
  })
}

# Create VMs for each server in the group
module "game_server" {
  source   = "../proxmox-vm"
  for_each = local.servers

  vm_name       = each.key
  description   = "Game Server: ${var.group_name} - ${each.key}\nGames: ${join(", ", each.value.games)}\nType: ${var.server_type}"
  proxmox_node  = var.proxmox_node
  template_name = local.server_config.template
  vmid          = each.value.vmid

  # Resources
  cpu_cores = each.value.cpu_cores
  memory_mb = each.value.memory_mb

  # Disk configuration
  disks = [
    {
      slot    = "scsi0"
      size    = each.value.disk_size
      storage = var.storage_pool
      type    = "disk"
    }
  ]

  # Network configuration
  networks = [
    {
      model    = "virtio"
      bridge   = var.network_bridge
      vlan_tag = var.vlan_tag
    }
  ]

  # Cloud-init
  os_type   = local.server_config.os_type
  ciuser    = var.ssh_user
  cipassword = var.ssh_password
  ssh_keys  = var.ssh_public_keys
  ipconfig0 = each.value.ip_address != null ? "ip=${each.value.ip_address},gw=${var.gateway}" : "ip=dhcp"
  nameserver   = length(var.dns_servers) > 0 ? var.dns_servers[0] : null
  searchdomain = var.search_domain

  # Settings
  start_on_boot = var.start_on_boot
  qemu_agent    = true

  # Tags
  tags = join(",", concat([var.group_name, var.server_type], each.value.games))
}

# Outputs
output "servers" {
  description = "Map of created game servers"
  value = {
    for name, vm in module.game_server : name => {
      vmid = vm.vm_id
      name = vm.vm_name
      ip   = vm.vm_ip
      node = vm.vm_node
    }
  }
}

output "group_name" {
  description = "Name of the server group"
  value       = var.group_name
}

output "server_type" {
  description = "Type of servers in this group"
  value       = var.server_type
}
