# Windows Server Packer Template

This Packer template creates a Windows Server 2022 VM template for running Windows-only game servers (like City of Heroes) on Proxmox VE.

## Features

- Windows Server 2022 Evaluation base
- UEFI boot with Secure Boot
- VirtIO drivers for optimal performance
- Cloudbase-Init for cloud-init compatibility
- Pre-configured firewall rules for game servers
- Chocolatey package manager
- Visual C++ Redistributables
- Remote Desktop enabled

## Prerequisites

1. **Proxmox VE** server with API access
2. **Packer** >= 1.8.0 installed locally
3. **Windows Server 2022 Evaluation ISO** uploaded to Proxmox
   - Download from: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022
4. **VirtIO drivers ISO** uploaded to Proxmox
   - Download from: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

## Quick Start

### 1. Download Required ISOs

1. **Windows Server 2022 Evaluation**
   - Visit the Microsoft Evaluation Center
   - Register and download the ISO
   - Upload to Proxmox: `Datacenter > Storage > ISO Images`

2. **VirtIO Drivers**
   ```bash
   wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
   # Upload to Proxmox ISO storage
   ```

### 2. Configure Variables

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
vm_id   = 9001
vm_name = "windows-server-template"

# ISO filenames (as shown in Proxmox)
windows_iso = "SERVER_EVAL_x64FRE_en-us.iso"
virtio_iso  = "virtio-win.iso"

# WinRM credentials (for Packer provisioning)
winrm_username = "Administrator"
winrm_password = "GameServer2024!"
```

### 3. Build the Template

```bash
packer init windows-server.pkr.hcl
packer validate -var-file=variables.pkrvars.hcl windows-server.pkr.hcl
packer build -var-file=variables.pkrvars.hcl windows-server.pkr.hcl
```

The build process takes approximately 30-45 minutes.

## Configuration Options

| Variable | Default | Description |
|----------|---------|-------------|
| `proxmox_url` | - | Proxmox API URL |
| `proxmox_username` | - | API username |
| `proxmox_password` | - | API password |
| `proxmox_node` | - | Target Proxmox node |
| `windows_iso` | - | Windows ISO filename |
| `virtio_iso` | - | VirtIO drivers ISO filename |
| `vm_id` | `9001` | Template VM ID |
| `vm_name` | `windows-server-template` | Template name |
| `vm_cores` | `4` | Build VM CPU cores |
| `vm_memory` | `8192` | Build VM memory (MB) |
| `vm_disk_size` | `100G` | Disk size |
| `winrm_username` | `Administrator` | WinRM user |
| `winrm_password` | `GameServer2024!` | WinRM password |

## What's Installed

### System Configuration
- Windows Server 2022 Standard (Desktop Experience)
- UEFI boot mode
- VirtIO storage and network drivers
- QEMU guest agent
- Remote Desktop enabled
- High Performance power plan

### Software
- **Cloudbase-Init** - Cloud-init compatibility
- **Chocolatey** - Package manager
- **7-Zip** - Archive extraction
- **Notepad++** - Text editor
- **Git** - Version control
- **Visual C++ Redistributables** - Runtime libraries

### Firewall Rules
Pre-configured for common game server ports:
- TCP 2104, 2105 (City of Heroes auth/db)
- TCP/UDP 7000-7100 (City of Heroes game)
- TCP 8080 (Web admin)
- TCP/UDP 27015-27050 (Steam games)
- TCP 3389 (Remote Desktop)

### Directory Structure
```
C:\
├── GameServers\           # Game server installations
│   ├── CityOfHeroes\     # CoH server files
│   ├── Scripts\          # Management scripts
│   ├── Backups\          # Backup storage
│   └── Logs\             # Server logs
└── Program Files\
    └── Cloudbase Solutions\
        └── Cloudbase-Init\    # Cloud-init agent
```

## Autounattend Configuration

The `autounattend/autounattend.xml` file provides unattended Windows installation:

- Automatic disk partitioning (UEFI)
- VirtIO driver loading
- Administrator account creation
- First-boot script execution

## Customization

### Changing Administrator Password

Update in `autounattend/autounattend.xml`:

```xml
<AdministratorPassword>
    <Value>YourNewPassword!</Value>
    <PlainText>true</PlainText>
</AdministratorPassword>
```

And in `variables.pkrvars.hcl`:

```hcl
winrm_password = "YourNewPassword!"
```

### Adding Software

Edit provisioner in `windows-server.pkr.hcl`:

```hcl
provisioner "powershell" {
  inline = [
    "choco install -y your-package"
  ]
}
```

### Different Windows Edition

Modify `autounattend/autounattend.xml`:

```xml
<MetaData wcm:action="add">
    <Key>/IMAGE/NAME</Key>
    <Value>Windows Server 2022 SERVERDATACENTER</Value>
</MetaData>
```

## Cloud-Init Support

Cloudbase-Init provides cloud-init compatibility for Windows:

### Supported Features
- Hostname setting
- User creation/password reset
- Network configuration
- User data scripts (PowerShell)
- SSH key injection

### Configuration Location
```
C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf
```

### Custom User Data

Terraform can pass PowerShell scripts:

```hcl
module "windows_vm" {
  # ...
  cicustom = "user=local:snippets/setup.ps1"
}
```

## Troubleshooting

### Build hangs during Windows installation

1. Watch Proxmox console for installation progress
2. Verify autounattend.xml is loaded from floppy
3. Check VirtIO drivers are accessible

### WinRM connection fails

1. Ensure firewall is temporarily disabled during build
2. Verify WinRM service is started
3. Check network connectivity
4. Try increasing `winrm_timeout`

### Sysprep fails

1. Check for pending Windows updates
2. Verify no user sessions are active
3. Review sysprep logs: `C:\Windows\System32\Sysprep\Panther\`

### VirtIO drivers not loading

1. Verify VirtIO ISO is attached as second CD-ROM
2. Check driver paths in autounattend.xml match ISO structure
3. Try different driver versions (w10 vs w11)

## Maintenance

### Windows Updates

The template is built without updates for speed. After deployment:

```powershell
# In the deployed VM
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
```

### Extending Evaluation Period

Windows Server Evaluation is valid for 180 days:

```powershell
# Check remaining days
slmgr /dli

# Reset evaluation period (up to 3 times)
slmgr /rearm
```

### Converting to Licensed

For production use, apply a valid license:

```powershell
slmgr /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
slmgr /ato
```

## Security Notes

1. **Change default password** after deployment
2. **Enable Windows Firewall** for production
3. **Apply Windows Updates** regularly
4. **Use strong passwords** for Administrator and game accounts
5. **Limit RDP access** to trusted IPs
