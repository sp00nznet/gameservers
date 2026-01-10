# Windows Server Setup Script for Game Server Template
# This script runs on first boot to configure WinRM and prepare for Packer provisioning

$ErrorActionPreference = "Stop"

Write-Host "Starting Windows Server Game Server Setup..." -ForegroundColor Green

# Disable Windows Firewall temporarily for setup
Write-Host "Configuring Windows Firewall..." -ForegroundColor Yellow
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Enable WinRM
Write-Host "Enabling WinRM..." -ForegroundColor Yellow
Enable-PSRemoting -Force -SkipNetworkProfileCheck

# Configure WinRM
Write-Host "Configuring WinRM service..." -ForegroundColor Yellow
winrm quickconfig -force
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'

# Set WinRM to start automatically
Set-Service -Name WinRM -StartupType Automatic
Start-Service WinRM

# Configure firewall for WinRM
New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow
New-NetFirewallRule -DisplayName "WinRM HTTPS" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# Re-enable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Install VirtIO drivers from mounted ISO
Write-Host "Installing VirtIO drivers..." -ForegroundColor Yellow
$virtio_drives = @("D:", "E:", "F:")
foreach ($drive in $virtio_drives) {
    $virtio_agent = "$drive\guest-agent\qemu-ga-x86_64.msi"
    if (Test-Path $virtio_agent) {
        Write-Host "Found VirtIO drivers on $drive" -ForegroundColor Green
        Start-Process -Wait msiexec.exe -ArgumentList "/i", $virtio_agent, "/quiet", "/norestart"
        break
    }
}

# Enable Remote Desktop
Write-Host "Enabling Remote Desktop..." -ForegroundColor Yellow
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Disable Server Manager at startup
Write-Host "Disabling Server Manager at startup..." -ForegroundColor Yellow
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask

# Set power plan to high performance
Write-Host "Setting power plan to High Performance..." -ForegroundColor Yellow
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable IE Enhanced Security Configuration
Write-Host "Disabling IE ESC..." -ForegroundColor Yellow
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

# Set timezone to UTC
Write-Host "Setting timezone to UTC..." -ForegroundColor Yellow
Set-TimeZone -Id "UTC"

# Create game server directories
Write-Host "Creating game server directories..." -ForegroundColor Yellow
$directories = @(
    "C:\GameServers",
    "C:\GameServers\CityOfHeroes",
    "C:\GameServers\Logs",
    "C:\GameServers\Scripts",
    "C:\GameServers\Backups"
)
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created: $dir" -ForegroundColor Gray
    }
}

# Disable automatic Windows Update (for game server stability)
Write-Host "Configuring Windows Update settings..." -ForegroundColor Yellow
$UpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-not (Test-Path $UpdatePath)) {
    New-Item -Path $UpdatePath -Force | Out-Null
}
Set-ItemProperty -Path $UpdatePath -Name "NoAutoUpdate" -Value 0
Set-ItemProperty -Path $UpdatePath -Name "AUOptions" -Value 3  # Download and notify

Write-Host "Windows Server setup complete!" -ForegroundColor Green
Write-Host "WinRM is now enabled and ready for Packer provisioning." -ForegroundColor Green
