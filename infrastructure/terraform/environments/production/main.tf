# Production Game Server Infrastructure
# Deploys game server VMs grouped by type on Proxmox

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9.0"
    }
  }

  # Optional: Configure remote backend for state
  # backend "s3" {
  #   bucket = "gameservers-terraform-state"
  #   key    = "production/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Proxmox provider configuration
provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = var.proxmox_tls_insecure

  # Optional: Parallel operations
  pm_parallel = 4
}

# ============================================================================
# Game Server Group: Source Engine (Docker)
# Counter-Strike 1.6, Counter-Strike 2, TF2, TFC, Half-Life DM, etc.
# ============================================================================
module "source_engine_servers" {
  source = "../../modules/game-server-group"

  group_name   = "source-engine"
  server_type  = "docker"
  proxmox_node = var.proxmox_node

  servers = [
    {
      name      = "source-engine-01"
      vmid      = 200
      cpu_cores = 4
      memory_mb = 8192
      disk_size = "100G"
      ip_address = var.source_engine_ip
      games = [
        "counter-strike",
        "counter-strike2",
        "teamfortress2",
        "tfc",
        "hldm",
        "hl2dm",
        "svencoop",
        "synergy",
        "blackmesa"
      ]
    }
  ]

  # Network configuration
  network_bridge = var.network_bridge
  vlan_tag       = var.game_vlan_tag
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  # SSH access
  ssh_user        = var.ssh_user
  ssh_password    = var.ssh_password
  ssh_public_keys = var.ssh_public_keys

  # Storage
  storage_pool = var.storage_pool
}

# ============================================================================
# Game Server Group: Survival Games (Docker)
# Project Zomboid, Abiotic Factor, HumanitZ
# ============================================================================
module "survival_servers" {
  source = "../../modules/game-server-group"

  group_name   = "survival-games"
  server_type  = "docker"
  proxmox_node = var.proxmox_node

  servers = [
    {
      name      = "survival-01"
      vmid      = 210
      cpu_cores = 4
      memory_mb = 16384
      disk_size = "100G"
      ip_address = var.survival_ip
      games = [
        "projectzomboid",
        "abioticfactor",
        "humanitz"
      ]
    }
  ]

  network_bridge = var.network_bridge
  vlan_tag       = var.game_vlan_tag
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  ssh_user        = var.ssh_user
  ssh_password    = var.ssh_password
  ssh_public_keys = var.ssh_public_keys

  storage_pool = var.storage_pool
}

# ============================================================================
# Game Server Group: Classic Games (Docker)
# Killing Floor 1/2, Unreal Tournament 99/2004, Starbound, SAMP
# ============================================================================
module "classic_servers" {
  source = "../../modules/game-server-group"

  group_name   = "classic-games"
  server_type  = "docker"
  proxmox_node = var.proxmox_node

  servers = [
    {
      name      = "classic-01"
      vmid      = 220
      cpu_cores = 4
      memory_mb = 8192
      disk_size = "80G"
      ip_address = var.classic_ip
      games = [
        "killingfloor",
        "killingfloor2",
        "ut99",
        "ut2004",
        "starbound",
        "samp"
      ]
    }
  ]

  network_bridge = var.network_bridge
  vlan_tag       = var.game_vlan_tag
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  ssh_user        = var.ssh_user
  ssh_password    = var.ssh_password
  ssh_public_keys = var.ssh_public_keys

  storage_pool = var.storage_pool
}

# ============================================================================
# Game Server Group: ARK (Proton)
# ARK: Survival Ascended - requires Proton for Windows binaries
# ============================================================================
module "ark_servers" {
  source = "../../modules/game-server-group"

  group_name   = "ark"
  server_type  = "proton"
  proxmox_node = var.proxmox_node

  servers = [
    {
      name      = "ark-01"
      vmid      = 230
      cpu_cores = 8
      memory_mb = 32768  # ARK requires significant memory
      disk_size = "200G"
      ip_address = var.ark_ip
      games = ["arkasa"]
    }
  ]

  network_bridge = var.network_bridge
  vlan_tag       = var.game_vlan_tag
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  ssh_user        = var.ssh_user
  ssh_password    = var.ssh_password
  ssh_public_keys = var.ssh_public_keys

  storage_pool = var.storage_pool
}

# ============================================================================
# Game Server Group: MMO Emulators (Compiled)
# AzerothCore (WoW), SWGEmu - require compilation and database servers
# ============================================================================
module "mmo_servers" {
  source = "../../modules/game-server-group"

  group_name   = "mmo-emulators"
  server_type  = "compiled"
  proxmox_node = var.proxmox_node

  servers = [
    {
      name      = "wow-01"
      vmid      = 240
      cpu_cores = 8
      memory_mb = 16384
      disk_size = "150G"
      ip_address = var.wow_ip
      games = ["azerothcore"]
    },
    {
      name      = "swgemu-01"
      vmid      = 241
      cpu_cores = 8
      memory_mb = 16384
      disk_size = "150G"
      ip_address = var.swgemu_ip
      games = ["swgemu"]
    }
  ]

  network_bridge = var.network_bridge
  vlan_tag       = var.game_vlan_tag
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  ssh_user        = var.ssh_user
  ssh_password    = var.ssh_password
  ssh_public_keys = var.ssh_public_keys

  storage_pool = var.storage_pool
}

# ============================================================================
# Game Server Group: Windows Games
# City of Heroes - requires full Windows VM
# ============================================================================
module "windows_servers" {
  source = "../../modules/game-server-group"

  group_name   = "windows-games"
  server_type  = "windows"
  proxmox_node = var.proxmox_node

  servers = [
    {
      name      = "coh-01"
      vmid      = 250
      cpu_cores = 4
      memory_mb = 8192
      disk_size = "100G"
      ip_address = var.coh_ip
      games = ["cityofheroes"]
    }
  ]

  network_bridge = var.network_bridge
  vlan_tag       = var.game_vlan_tag
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  ssh_user        = var.ssh_user
  ssh_password    = var.ssh_password
  ssh_public_keys = var.ssh_public_keys

  storage_pool = var.storage_pool
}

# ============================================================================
# Outputs
# ============================================================================
output "source_engine_servers" {
  description = "Source Engine game server details"
  value       = module.source_engine_servers.servers
}

output "survival_servers" {
  description = "Survival game server details"
  value       = module.survival_servers.servers
}

output "classic_servers" {
  description = "Classic game server details"
  value       = module.classic_servers.servers
}

output "ark_servers" {
  description = "ARK game server details"
  value       = module.ark_servers.servers
}

output "mmo_servers" {
  description = "MMO emulator server details"
  value       = module.mmo_servers.servers
}

output "windows_servers" {
  description = "Windows game server details"
  value       = module.windows_servers.servers
}

output "all_server_ips" {
  description = "Map of all server names to IP addresses"
  value = merge(
    { for name, server in module.source_engine_servers.servers : name => server.ip },
    { for name, server in module.survival_servers.servers : name => server.ip },
    { for name, server in module.classic_servers.servers : name => server.ip },
    { for name, server in module.ark_servers.servers : name => server.ip },
    { for name, server in module.mmo_servers.servers : name => server.ip },
    { for name, server in module.windows_servers.servers : name => server.ip }
  )
}
