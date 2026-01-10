# Windows Game Server Initialization Script
# Executed by Cloudbase-Init on first boot

$ErrorActionPreference = "Stop"
$LogFile = "C:\GameServers\Logs\init.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $LogFile
    Write-Host $Message
}

# Create log directory
New-Item -ItemType Directory -Path "C:\GameServers\Logs" -Force | Out-Null

Write-Log "Starting Windows Game Server initialization..."

# Create directory structure
$directories = @(
    "C:\GameServers",
    "C:\GameServers\CityOfHeroes",
    "C:\GameServers\CityOfHeroes\Server",
    "C:\GameServers\CityOfHeroes\Data",
    "C:\GameServers\Scripts",
    "C:\GameServers\Backups",
    "C:\GameServers\Logs"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Log "Created directory: $dir"
    }
}

# Configure Windows Firewall for City of Heroes
Write-Log "Configuring Windows Firewall rules..."

# City of Heroes ports
$cohPorts = @{
    "CoH-Auth-TCP" = @{ Port = 2104; Protocol = "TCP" }
    "CoH-DB-TCP" = @{ Port = 2105; Protocol = "TCP" }
    "CoH-Game-TCP" = @{ Port = "7000-7100"; Protocol = "TCP" }
    "CoH-Game-UDP" = @{ Port = "7000-7100"; Protocol = "UDP" }
    "CoH-Web-TCP" = @{ Port = 8080; Protocol = "TCP" }
}

foreach ($ruleName in $cohPorts.Keys) {
    $rule = $cohPorts[$ruleName]
    $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    if (-not $existingRule) {
        New-NetFirewallRule -DisplayName $ruleName `
            -Direction Inbound `
            -Protocol $rule.Protocol `
            -LocalPort $rule.Port `
            -Action Allow
        Write-Log "Created firewall rule: $ruleName"
    }
}

# Install Chocolatey if not present
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install required software
Write-Log "Installing required software..."
$packages = @(
    "7zip",
    "notepadplusplus",
    "vcredist-all",
    "dotnetfx"
)

foreach ($package in $packages) {
    Write-Log "Installing $package..."
    choco install -y $package 2>&1 | Out-Null
}

# Create City of Heroes management scripts
$cohStartScript = @'
# Start City of Heroes Server
$ServerPath = "C:\GameServers\CityOfHeroes\Server"

# Start Auth Server
Start-Process -FilePath "$ServerPath\authserver.exe" -WorkingDirectory $ServerPath -WindowStyle Minimized

# Start DB Server
Start-Process -FilePath "$ServerPath\dbserver.exe" -WorkingDirectory $ServerPath -WindowStyle Minimized

# Start Map Servers (adjust as needed)
Start-Process -FilePath "$ServerPath\mapserver.exe" -ArgumentList "-db city_1" -WorkingDirectory $ServerPath -WindowStyle Minimized

Write-Host "City of Heroes servers started."
'@

$cohStopScript = @'
# Stop City of Heroes Server
Stop-Process -Name "authserver" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "dbserver" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "mapserver" -Force -ErrorAction SilentlyContinue
Write-Host "City of Heroes servers stopped."
'@

Set-Content -Path "C:\GameServers\Scripts\start-coh.ps1" -Value $cohStartScript
Set-Content -Path "C:\GameServers\Scripts\stop-coh.ps1" -Value $cohStopScript
Write-Log "Created CoH management scripts"

# Create scheduled task for auto-start (optional)
$taskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\GameServers\Scripts\start-coh.ps1"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

# Only create if not exists
$existingTask = Get-ScheduledTask -TaskName "CityOfHeroesAutoStart" -ErrorAction SilentlyContinue
if (-not $existingTask) {
    Register-ScheduledTask -TaskName "CityOfHeroesAutoStart" `
        -Action $taskAction `
        -Trigger $taskTrigger `
        -Settings $taskSettings `
        -User "SYSTEM" `
        -RunLevel Highest
    Write-Log "Created auto-start scheduled task"
}

# Set power plan to High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
Write-Log "Set power plan to High Performance"

# Disable Windows Update automatic restart
$windowsUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-not (Test-Path $windowsUpdatePath)) {
    New-Item -Path $windowsUpdatePath -Force | Out-Null
}
Set-ItemProperty -Path $windowsUpdatePath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1
Write-Log "Disabled automatic restart for Windows Update"

# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Write-Log "Enabled Remote Desktop"

Write-Log "Windows Game Server initialization complete!"
