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
├── README.md                         # This file
├── packer/                           # VM template builders
│   ├── ubuntu-docker/                # Ubuntu 22.04 + Docker template
│   │   ├── ubuntu-docker.pkr.hcl     # Packer template
│   │   ├── variables.pkrvars.hcl.example
│   │   ├── http/                     # Autoinstall files
│   │   └── README.md
│   └── windows-server/               # Windows Server 2022 template
│       ├── windows-server.pkr.hcl    # Packer template
│       ├── variables.pkrvars.hcl.example
│       ├── autounattend/             # Unattended install config
│       ├── scripts/                  # Setup scripts
│       └── README.md
├── terraform/                        # VM deployment configurations
│   ├── modules/                      # Reusable Terraform modules
│   │   ├── proxmox-vm/               # Base VM module
│   │   └── game-server-group/        # Game server group deployment
│   └── environments/                 # Environment-specific configs
│       ├── production/               # Production game servers
│       └── staging/                  # Staging/test environment
└── cloud-init/                       # Cloud-init templates
    ├── docker-gameserver.yaml        # For containerized games
    ├── proton-gameserver.yaml        # For Windows games via Proton
    ├── compiled-gameserver.yaml      # For compiled servers (WoW, SWGEmu)
    ├── windows-gameserver.yaml       # For Windows VMs
    └── windows-gameserver-userdata.ps1
```

## Game Server Groupings

VMs are organized by game type/requirements:

| Group | Server Type | Template | Games |
|-------|-------------|----------|-------|
| Source Engine | Docker | Ubuntu Docker | CS 1.6, CS2, TF2, HL2:DM, TFC, Black Mesa, Sven Co-op, Synergy |
| Survival | Docker | Ubuntu Docker | Project Zomboid, Abiotic Factor, HumanitZ |
| Classic | Docker | Ubuntu Docker | Killing Floor 1/2, UT99, UT2004, Starbound, SAMP |
| ARK | Proton | Ubuntu Docker | ARK: Survival Ascended |
| MMO Emulators | Compiled | Ubuntu Docker | AzerothCore (WoW), SWGEmu |
| Windows Games | Windows | Windows Server | City of Heroes |

## Quick Start

### Prerequisites

Before you begin, ensure you have:

1. **Proxmox VE** cluster (version 7.0+) with API access enabled
2. **Packer** >= 1.8.0 ([Install guide](https://developer.hashicorp.com/packer/downloads))
3. **Terraform** >= 1.0.0 ([Install guide](https://developer.hashicorp.com/terraform/downloads))
4. **ISO files** uploaded to Proxmox storage:
   - Ubuntu 22.04 Server ISO
   - Windows Server 2022 Evaluation ISO
   - VirtIO drivers ISO

### Step 1: Create Proxmox API Token

1. Log into Proxmox web UI
2. Navigate to **Datacenter > Permissions > API Tokens**
3. Click **Add** and create a token:
   - User: `root@pam` (or your admin user)
   - Token ID: `terraform`
   - Privilege Separation: unchecked (for simplicity)
4. Save the token secret securely

### Step 2: Upload Required ISOs

```bash
# On your Proxmox host, download ISOs to the ISO storage
cd /var/lib/vz/template/iso/

# Ubuntu 22.04 Server
wget https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso

# VirtIO drivers for Windows
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

# Windows Server 2022 - requires manual download from Microsoft
# Visit: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022
```

### Step 3: Build VM Templates with Packer

#### Build Ubuntu Docker Template

```bash
cd infrastructure/packer/ubuntu-docker

# Create configuration
cp variables.pkrvars.hcl.example variables.pkrvars.hcl

# Edit with your Proxmox settings
nano variables.pkrvars.hcl
```

Configure `variables.pkrvars.hcl`:
```hcl
proxmox_url      = "https://your-proxmox:8006/api2/json"
proxmox_username = "root@pam!terraform"
proxmox_password = "your-api-token-secret"
proxmox_node     = "pve"

proxmox_storage     = "local-lvm"
proxmox_iso_storage = "local"

vm_id   = 9000
vm_name = "ubuntu-docker-template"
ubuntu_iso = "ubuntu-22.04.3-live-server-amd64.iso"
```

Build the template:
```bash
packer init ubuntu-docker.pkr.hcl
packer build -var-file=variables.pkrvars.hcl ubuntu-docker.pkr.hcl
```

#### Build Windows Server Template (for City of Heroes)

```bash
cd ../windows-server

cp variables.pkrvars.hcl.example variables.pkrvars.hcl
nano variables.pkrvars.hcl
```

Configure and build:
```bash
packer init windows-server.pkr.hcl
packer build -var-file=variables.pkrvars.hcl windows-server.pkr.hcl
```

### Step 4: Deploy VMs with Terraform

```bash
cd ../../terraform/environments/production

# Create configuration
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Configure `terraform.tfvars`:
```hcl
# Proxmox connection
proxmox_api_url          = "https://your-proxmox:8006/api2/json"
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = "your-api-token-secret"
proxmox_node             = "pve"

# Network
gateway     = "192.168.1.1"
dns_servers = ["8.8.8.8", "1.1.1.1"]

# SSH access
ssh_user        = "gameserver"
ssh_public_keys = <<-EOT
  ssh-ed25519 AAAAC3... your-key
EOT

# Server IPs (use CIDR notation, or null for DHCP)
source_engine_ip = "192.168.1.100/24"
survival_ip      = "192.168.1.101/24"
classic_ip       = "192.168.1.102/24"
ark_ip           = "192.168.1.103/24"
wow_ip           = "192.168.1.104/24"
swgemu_ip        = "192.168.1.105/24"
coh_ip           = "192.168.1.106/24"
```

Deploy the infrastructure:
```bash
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

### Step 5: Configure Game Servers

After VMs are deployed, SSH/RDP into them and run the game setup scripts:

```bash
# SSH to a Linux VM
ssh gameserver@192.168.1.100

# Clone the gameservers repo
git clone https://github.com/your-org/gameservers.git
cd gameservers

# Run the setup menu
sudo ./setup.sh
```

For Windows VMs (City of Heroes):
1. RDP to the VM IP
2. Follow the CoH setup instructions displayed by Terraform
3. Download and run the Ouroboros self-installer

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Proxmox VE Cluster                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    VM Templates (Packer)                          │  │
│  │  ┌─────────────────────┐     ┌─────────────────────────────┐     │  │
│  │  │ ubuntu-docker-9000  │     │ windows-server-9001         │     │  │
│  │  │ • Ubuntu 22.04 LTS  │     │ • Windows Server 2022       │     │  │
│  │  │ • Docker CE         │     │ • Cloudbase-Init            │     │  │
│  │  │ • SteamCMD libs     │     │ • VirtIO drivers            │     │  │
│  │  └─────────────────────┘     └─────────────────────────────┘     │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                    │                                    │
│                                    ▼                                    │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                   Game Server VMs (Terraform)                     │  │
│  │                                                                   │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │  │
│  │  │ source-engine-01│  │   survival-01   │  │   classic-01    │   │  │
│  │  │   VMID: 200     │  │   VMID: 210     │  │   VMID: 220     │   │  │
│  │  │   (Docker)      │  │   (Docker)      │  │   (Docker)      │   │  │
│  │  │ • CS 1.6, CS2   │  │ • Project Zomboid│ │ • Killing Floor │   │  │
│  │  │ • TF2, TFC      │  │ • Abiotic Factor│  │ • UT99, UT2004  │   │  │
│  │  │ • HL2:DM        │  │ • HumanitZ      │  │ • Starbound     │   │  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘   │  │
│  │                                                                   │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │  │
│  │  │     ark-01      │  │     wow-01      │  │   swgemu-01     │   │  │
│  │  │   VMID: 230     │  │   VMID: 240     │  │   VMID: 241     │   │  │
│  │  │   (Proton)      │  │   (Compiled)    │  │   (Compiled)    │   │  │
│  │  │ • ARK: SA       │  │ • AzerothCore   │  │ • SWGEmu Core3  │   │  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘   │  │
│  │                                                                   │  │
│  │  ┌─────────────────┐                                             │  │
│  │  │     coh-01      │                                             │  │
│  │  │   VMID: 250     │                                             │  │
│  │  │   (Windows)     │                                             │  │
│  │  │ • City of Heroes│                                             │  │
│  │  └─────────────────┘                                             │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
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

  networks = [{
    model  = "virtio"
    bridge = "vmbr0"
  }]

  # Cloud-init
  ciuser    = "gameserver"
  ssh_keys  = "ssh-ed25519 AAAA..."
  ipconfig0 = "ip=192.168.1.100/24,gw=192.168.1.1"
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
      name       = "server-01"
      vmid       = 200
      cpu_cores  = 4
      memory_mb  = 8192
      disk_size  = "100G"
      ip_address = "192.168.1.100/24"
      games      = ["counter-strike", "teamfortress2"]
    },
    {
      name       = "server-02"
      vmid       = 201
      cpu_cores  = 4
      memory_mb  = 8192
      games      = ["half-life2dm", "synergy"]
    }
  ]

  gateway     = "192.168.1.1"
  dns_servers = ["8.8.8.8"]

  ssh_user        = "gameserver"
  ssh_public_keys = "ssh-ed25519 AAAA..."
}
```

## Cloud-Init Templates

| Template | Server Type | Description |
|----------|-------------|-------------|
| `docker-gameserver.yaml` | Docker | Docker + SteamCMD for containerized games |
| `proton-gameserver.yaml` | Proton | Proton/Wine for Windows games on Linux |
| `compiled-gameserver.yaml` | Compiled | Build tools + MariaDB for compiled servers |
| `windows-gameserver.yaml` | Windows | Cloudbase-Init configuration for Windows |

### Template Features

**docker-gameserver.yaml:**
- Docker CE with compose plugin
- SteamCMD pre-installed
- 32-bit library support
- Systemd service templates for game containers

**proton-gameserver.yaml:**
- Proton GE installation script
- Wine dependencies
- Vulkan support
- Screen session management

**compiled-gameserver.yaml:**
- Clang/GCC compilers
- CMake, Ninja build tools
- MariaDB server
- Boost, OpenSSL libraries

## Network Ports Reference

| Game/Server | Ports | Protocol |
|-------------|-------|----------|
| Counter-Strike 1.6/2 | 27015 | TCP/UDP |
| Team Fortress 2 | 27015 | TCP/UDP |
| Project Zomboid | 16261-16262 | UDP |
| ARK: Survival Ascended | 7777-7778, 27015 | UDP |
| Killing Floor 2 | 7777, 27015, 8080 | UDP/TCP |
| AzerothCore (WoW) | 3724, 8085 | TCP |
| SWGEmu | 44419, 44453, 44455, 44462 | TCP/UDP |
| City of Heroes | 2104-2105, 7000-7100, 8080 | TCP/UDP |

## Management Commands

### Terraform

```bash
# View current state
terraform show

# List all resources
terraform state list

# View specific VM details
terraform state show 'module.source_engine_servers.module.game_server["source-engine-01"]'

# Destroy specific server group
terraform destroy -target=module.ark_servers

# Recreate a VM (taint + apply)
terraform taint 'module.mmo_servers.module.game_server["wow-01"]'
terraform apply

# Import existing VM
terraform import 'module.source_engine_servers.module.game_server["source-engine-01"].proxmox_vm_qemu.vm' pve/qemu/200
```

### Packer

```bash
# Validate template
packer validate -var-file=variables.pkrvars.hcl template.pkr.hcl

# Build with debug output
PACKER_LOG=1 packer build -var-file=variables.pkrvars.hcl template.pkr.hcl

# Force rebuild (overwrite existing)
packer build -force -var-file=variables.pkrvars.hcl template.pkr.hcl
```

## Maintenance

### Updating VM Templates

When OS or package updates are needed:

```bash
# Rebuild the template
cd packer/ubuntu-docker
packer build -var-file=variables.pkrvars.hcl ubuntu-docker.pkr.hcl

# Recreate VMs from new template
cd ../../terraform/environments/production
terraform taint 'module.source_engine_servers.module.game_server["source-engine-01"]'
terraform apply -target=module.source_engine_servers
```

### Scaling Game Servers

Add more servers to a group by updating `main.tf`:

```hcl
module "source_engine_servers" {
  # ...
  servers = [
    { name = "source-engine-01", ... },
    { name = "source-engine-02", ... },  # Add new server
  ]
}
```

Then apply:
```bash
terraform apply -target=module.source_engine_servers
```

### Backup Considerations

Important data to backup:
- Terraform state files (`terraform.tfstate`)
- Game server configuration files
- Database dumps (for WoW, SWGEmu)
- Player data and save files

## Troubleshooting

### Terraform Can't Connect to Proxmox

1. Verify API token permissions
2. Check `pm_tls_insecure = true` if using self-signed certs
3. Test API access:
   ```bash
   curl -k -H "Authorization: PVEAPIToken=root@pam!terraform=your-token" \
     https://proxmox:8006/api2/json/version
   ```

### VM Fails to Boot

1. Check Proxmox console for boot errors
2. Verify template was built correctly
3. Check cloud-init logs: `cat /var/log/cloud-init.log`

### Cloud-Init Not Running

1. Ensure QEMU guest agent is installed
2. Check cloud-init disk is attached
3. Verify cloud-init service: `systemctl status cloud-init`

### Windows VM Issues

1. Check VirtIO drivers are loaded
2. Verify Cloudbase-Init service is running
3. Review logs: `C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\`

## Security Best Practices

1. **Use API tokens** instead of password authentication
2. **Rotate passwords** after initial deployment
3. **Enable firewall** on both Proxmox and VMs
4. **Use SSH keys** instead of passwords for Linux VMs
5. **Limit network access** to game ports only
6. **Regular updates** - rebuild templates monthly

## Contributing

When adding new game server types:

1. Determine the server type (docker, proton, compiled, windows)
2. Add cloud-init configuration if special setup is needed
3. Update the Terraform production configuration
4. Document port requirements
5. Test deployment end-to-end
6. Update this README

## Related Documentation

- [Main README](../README.md) - Project overview and game server scripts
- [Ubuntu Docker Packer](packer/ubuntu-docker/README.md) - Linux template details
- [Windows Server Packer](packer/windows-server/README.md) - Windows template details
- [Proxmox Documentation](https://pve.proxmox.com/pve-docs/)
- [Terraform Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
