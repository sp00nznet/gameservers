# Ubuntu Docker Packer Template

This Packer template creates an Ubuntu 22.04 LTS VM template with Docker pre-installed, optimized for running containerized game servers on Proxmox VE.

## Features

- Ubuntu 22.04 LTS Server base
- Docker CE with compose plugin
- 32-bit library support for SteamCMD
- QEMU guest agent for Proxmox integration
- Cloud-init support for automated provisioning
- Pre-created game server directories

## Prerequisites

1. **Proxmox VE** server with API access
2. **Packer** >= 1.8.0 installed locally
3. **Ubuntu 22.04 Server ISO** uploaded to Proxmox
   - Download from: https://ubuntu.com/download/server
   - Upload to Proxmox: Datacenter > Storage > ISO Images

## Quick Start

### 1. Configure Variables

```bash
cp variables.pkrvars.hcl.example variables.pkrvars.hcl
```

Edit `variables.pkrvars.hcl`:

```hcl
# Proxmox connection
proxmox_url      = "https://proxmox.example.com:8006/api2/json"
proxmox_username = "root@pam"
proxmox_password = "your-password"
proxmox_node     = "pve"

# Storage
proxmox_storage     = "local-lvm"
proxmox_iso_storage = "local"

# Template settings
vm_id   = 9000
vm_name = "ubuntu-docker-template"

# Ubuntu ISO filename (as shown in Proxmox)
ubuntu_iso = "ubuntu-22.04.3-live-server-amd64.iso"
```

### 2. Build the Template

```bash
packer init ubuntu-docker.pkr.hcl
packer validate -var-file=variables.pkrvars.hcl ubuntu-docker.pkr.hcl
packer build -var-file=variables.pkrvars.hcl ubuntu-docker.pkr.hcl
```

The build process takes approximately 15-20 minutes.

### 3. Use the Template

The template can now be cloned in Terraform or manually in Proxmox.

## Configuration Options

| Variable | Default | Description |
|----------|---------|-------------|
| `proxmox_url` | - | Proxmox API URL |
| `proxmox_username` | - | API username |
| `proxmox_password` | - | API password |
| `proxmox_node` | - | Target Proxmox node |
| `proxmox_storage` | `local-lvm` | Storage for VM disk |
| `proxmox_iso_storage` | `local` | Storage containing ISO |
| `vm_id` | `9000` | Template VM ID |
| `vm_name` | `ubuntu-docker-template` | Template name |
| `ubuntu_iso` | - | ISO filename |
| `vm_cores` | `2` | Build VM CPU cores |
| `vm_memory` | `4096` | Build VM memory (MB) |
| `vm_disk_size` | `32G` | Disk size |
| `ssh_username` | `gameserver` | Provisioning user |
| `ssh_password` | `gameserver` | Provisioning password |

## What's Installed

### System Packages
- `qemu-guest-agent` - Proxmox VM integration
- `cloud-init` - Automated provisioning
- `curl`, `wget`, `unzip` - Common utilities
- `screen`, `htop`, `tmux` - Process management

### Docker
- Docker CE (latest stable)
- Docker Compose plugin
- User added to docker group

### 32-bit Libraries (for SteamCMD)
- `lib32gcc-s1`
- `lib32stdc++6`
- `libsdl2-2.0-0:i386`

### Directory Structure
```
/opt/
├── gameservers/    # Game server data
└── steamcmd/       # SteamCMD installation
```

## Autoinstall Configuration

The `http/` directory contains Ubuntu autoinstall configuration:

- `user-data` - Cloud-init autoinstall config
- `meta-data` - Instance metadata

These files are served via HTTP during installation for automated setup.

## Customization

### Adding Packages

Edit the provisioner in `ubuntu-docker.pkr.hcl`:

```hcl
provisioner "shell" {
  inline = [
    "sudo apt-get install -y your-package"
  ]
}
```

### Changing Default User

Update `ssh_username` in variables and modify `http/user-data`:

```yaml
identity:
  username: your-username
  password: "hashed-password"
```

### Larger Disk

Increase `vm_disk_size` in variables:

```hcl
vm_disk_size = "64G"
```

## Troubleshooting

### Build hangs at "Waiting for SSH"

1. Check Proxmox console for the VM
2. Verify boot command is being entered correctly
3. Ensure autoinstall files are being served (check HTTP server logs)

### Cloud-init errors during build

1. Verify `http/user-data` YAML syntax
2. Check network connectivity from VM to build machine
3. Try increasing `ssh_timeout`

### Template doesn't have cloud-init

1. Ensure `cloud_init = true` in source config
2. Verify cloud-init package was installed during build
3. Check that cloud-init wasn't cleaned too aggressively

## Maintenance

### Updating the Template

When Ubuntu releases security updates:

```bash
# Rebuild template
packer build -var-file=variables.pkrvars.hcl ubuntu-docker.pkr.hcl

# Old template is replaced automatically
```

### Template Versioning

To keep multiple versions, change `vm_id` and `vm_name`:

```hcl
vm_id   = 9001
vm_name = "ubuntu-docker-template-v2"
```
