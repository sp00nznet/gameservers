# Game Server Infrastructure

This directory contains Infrastructure-as-Code (IaC) configurations for deploying game servers on Proxmox VE using Packer and Terraform.

## Overview

The infrastructure is designed to support per-game-type VM deployments on Proxmox, replacing the previous single-host container approach. This provides:

- **Isolation**: Each game type runs on dedicated VMs
- **Scalability**: Easy to add more VMs per game type
- **Reproducibility**: Infrastructure defined as code
- **Flexibility**: Support for both Linux and Windows workloads

## Directory Structure

```
infrastructure/
├── packer/                    # VM template builders
│   ├── ubuntu-docker/         # Ubuntu with Docker for containerized games
│   └── windows-server/        # Windows Server for games requiring Windows
├── terraform/                 # VM deployment configurations
│   ├── modules/               # Reusable Terraform modules
│   │   ├── proxmox-vm/        # Base Proxmox VM module
│   │   └── game-server-group/ # Game server group deployment
│   └── environments/          # Environment-specific configurations
│       ├── production/        # Production game servers
│       └── staging/           # Staging/test environment
└── cloud-init/                # Cloud-init templates for VM provisioning
```

## Game Server Groupings

VMs are organized by game type/requirements:

| Group | VM Type | Games |
|-------|---------|-------|
| Source Engine | Docker | CS 1.6, CS2, TF2, HL2:DM, TFC, Black Mesa |
| Survival | Docker | Project Zomboid, Abiotic Factor, HumanitZ |
| Classic | Docker | Killing Floor 1/2, UT99, UT2004, Starbound, SAMP |
| ARK | Proton | ARK: Survival Ascended |
| MMO Emulators | Compiled | AzerothCore (WoW), SWGEmu |
| Windows Games | Windows | City of Heroes |

## Quick Start

### Prerequisites

1. **Proxmox VE** cluster with API access
2. **Packer** >= 1.8.0
3. **Terraform** >= 1.0.0
4. **ISO files** uploaded to Proxmox storage:
   - Ubuntu 22.04 Server ISO
   - Windows Server 2022 Evaluation ISO
   - VirtIO drivers ISO

### Step 1: Build VM Templates with Packer

```bash
# Build Ubuntu Docker template
cd packer/ubuntu-docker
cp variables.pkrvars.hcl.example variables.pkrvars.hcl
# Edit variables.pkrvars.hcl with your Proxmox settings
packer build -var-file=variables.pkrvars.hcl ubuntu-docker.pkr.hcl

# Build Windows Server template
cd ../windows-server
cp variables.pkrvars.hcl.example variables.pkrvars.hcl
# Edit variables.pkrvars.hcl
packer build -var-file=variables.pkrvars.hcl windows-server.pkr.hcl
```

### Step 2: Deploy VMs with Terraform

```bash
cd terraform/environments/production
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy all game servers
terraform apply

# Or deploy specific groups
terraform apply -target=module.source_engine_servers
terraform apply -target=module.windows_servers
```

### Step 3: Configure Game Servers

After VMs are deployed, SSH/RDP into them and run the game server setup scripts:

```bash
# Example: On the Source Engine VM
ssh gameserver@<source-engine-ip>
cd /home/user/gameservers
sudo ./setup.sh
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Proxmox VE Cluster                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ source-engine-01│  │   survival-01   │  │   classic-01    │  │
│  │   (Docker VM)   │  │   (Docker VM)   │  │   (Docker VM)   │  │
│  │ • CS 1.6, CS2   │  │ • Project Zomboid│  │ • Killing Floor │  │
│  │ • TF2, TFC      │  │ • Abiotic Factor│  │ • UT99, UT2004  │  │
│  │ • HL2:DM        │  │ • HumanitZ      │  │ • Starbound     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │     ark-01      │  │     wow-01      │  │     coh-01      │  │
│  │  (Proton VM)    │  │ (Compiled VM)   │  │  (Windows VM)   │  │
│  │ • ARK: SA       │  │ • AzerothCore   │  │ • City of Heroes│  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                  │
│  ┌─────────────────┐                                            │
│  │   swgemu-01     │                                            │
│  │ (Compiled VM)   │                                            │
│  │ • SWGEmu Core3  │                                            │
│  └─────────────────┘                                            │
└─────────────────────────────────────────────────────────────────┘
```

## Terraform Modules

### proxmox-vm

Base module for creating Proxmox VMs with cloud-init support.

```hcl
module "my_vm" {
  source = "../../modules/proxmox-vm"

  vm_name       = "my-server"
  proxmox_node  = "pve"
  template_name = "ubuntu-docker-template"

  cpu_cores = 4
  memory_mb = 8192

  disks = [{
    slot    = "scsi0"
    size    = "50G"
    storage = "local-lvm"
    type    = "disk"
  }]
}
```

### game-server-group

Higher-level module for deploying groups of game servers.

```hcl
module "my_game_servers" {
  source = "../../modules/game-server-group"

  group_name   = "my-games"
  server_type  = "docker"  # docker, proton, compiled, windows
  proxmox_node = "pve"

  servers = [
    {
      name      = "server-01"
      cpu_cores = 4
      memory_mb = 8192
      games     = ["game1", "game2"]
    }
  ]
}
```

## Cloud-Init Templates

| Template | Description |
|----------|-------------|
| `docker-gameserver.yaml` | Docker + SteamCMD for containerized games |
| `proton-gameserver.yaml` | Proton/Wine for Windows games on Linux |
| `compiled-gameserver.yaml` | Build tools + MariaDB for compiled servers |
| `windows-gameserver.yaml` | Windows Server configuration via Cloudbase-Init |

## Network Ports

Default ports used by game servers:

| Game | Ports |
|------|-------|
| Counter-Strike | 27015 TCP/UDP |
| Team Fortress 2 | 27015 TCP/UDP |
| Project Zomboid | 16261-16262 UDP |
| ARK: SA | 7777-7778 UDP, 27015 UDP |
| AzerothCore | 3724 TCP, 8085 TCP |
| SWGEmu | 44419, 44453, 44455 TCP |
| City of Heroes | 2104-2105 TCP, 7000-7100 UDP |

## Maintenance

### Updating Templates

```bash
# Rebuild Ubuntu template with updates
cd packer/ubuntu-docker
packer build -var-file=variables.pkrvars.hcl ubuntu-docker.pkr.hcl

# Update running VMs (recreate from new template)
cd terraform/environments/production
terraform taint module.source_engine_servers.module.game_server["source-engine-01"]
terraform apply
```

### Scaling

Add more servers to a group in `terraform.tfvars`:

```hcl
# In main.tf, add to servers list:
servers = [
  { name = "source-engine-01", ... },
  { name = "source-engine-02", ... },  # New server
]
```

### Backup

Consider backing up:
- Terraform state files
- Game server data volumes
- Database dumps for MMO servers

## Troubleshooting

### Terraform can't connect to Proxmox

1. Verify API token has correct permissions
2. Check `pm_tls_insecure` if using self-signed certs
3. Ensure network connectivity to Proxmox API

### VM fails to boot

1. Check Proxmox console for boot errors
2. Verify template was built correctly
3. Check cloud-init logs: `/var/log/cloud-init.log`

### Cloud-init not running

1. Ensure QEMU guest agent is installed
2. Check cloud-init disk is attached
3. Verify cloud-init service is enabled

## Contributing

When adding new game server types:

1. Determine the server type (docker, proton, compiled, windows)
2. Add cloud-init configuration if needed
3. Update the Terraform configuration
4. Document port requirements
5. Test deployment end-to-end
