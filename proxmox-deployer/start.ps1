#Requires -Version 5.1
<#
.SYNOPSIS
    Silverware Game Server Deployer - PowerShell Launcher

.DESCRIPTION
    Builds and launches the Silverware Game Server Deployer using Docker.
    Provides health checking, automatic browser launch, and status feedback.

.PARAMETER Rebuild
    Force rebuild of the Docker image even if container is running.

.PARAMETER NoBrowser
    Skip the prompt to open browser after successful start.

.EXAMPLE
    .\start.ps1
    Standard launch with prompts.

.EXAMPLE
    .\start.ps1 -Rebuild
    Force rebuild and restart the container.

.EXAMPLE
    .\start.ps1 -NoBrowser
    Start without browser prompt.
#>

param(
    [switch]$Rebuild,
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"
$DeployerPort = 5555
$ContainerName = "silverware-deployer"

# Colors and formatting
function Write-Step { param($msg) Write-Host "[$([char]0x2192)] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Banner
Write-Host ""
Write-Host "  ____  _ _                                      " -ForegroundColor Blue
Write-Host " / ___(_) |_   _____ _ ____      ____ _ _ __ ___ " -ForegroundColor Blue
Write-Host " \___ \| | \ \ / / _ \ '__\ \ /\ / / _`` | '__/ _ \" -ForegroundColor Blue
Write-Host "  ___) | | |\ V /  __/ |   \ V  V / (_| | | |  __/" -ForegroundColor Blue
Write-Host " |____/|_|_| \_/ \___|_|    \_/\_/ \__,_|_|  \___|" -ForegroundColor Blue
Write-Host ""
Write-Host "         Game Server Deployer - PowerShell Launcher" -ForegroundColor White
Write-Host ""

# Change to script directory
Set-Location $PSScriptRoot

# Check Docker
Write-Step "Checking Docker installation..."
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Docker not found" }
    Write-Success "Docker found: $dockerVersion"
}
catch {
    Write-Err "Docker is not installed or not in PATH."
    Write-Host ""
    Write-Host "Please install Docker Desktop from:" -ForegroundColor Yellow
    Write-Host "  https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Docker daemon
Write-Step "Checking Docker daemon..."
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Docker daemon not running" }
    Write-Success "Docker daemon is running."
}
catch {
    Write-Err "Docker daemon is not running."
    Write-Host ""
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check/create .env file
Write-Step "Checking environment configuration..."
if (-not (Test-Path ".env")) {
    Write-Warn ".env file not found. Creating from template..."

    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
    }
    else {
        # Generate secure random key
        $secretKey = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
        @"
SECRET_KEY=$secretKey
FLASK_ENV=production
TZ=UTC
"@ | Out-File -FilePath ".env" -Encoding UTF8
    }
    Write-Success "Created .env file. Edit it to customize settings."
}
else {
    Write-Success ".env file exists."
}

# Check if container is running
Write-Step "Checking for existing container..."
$runningContainer = docker ps --filter "name=$ContainerName" --format "{{.Names}}" 2>$null

if ($runningContainer -eq $ContainerName -and -not $Rebuild) {
    Write-Warn "Silverware Deployer is already running."
    Write-Host ""
    $restart = Read-Host "Do you want to restart it? (Y/N)"

    if ($restart -eq 'Y' -or $restart -eq 'y') {
        Write-Step "Stopping existing container..."
        docker-compose down 2>&1 | Out-Null
        Write-Success "Container stopped."
    }
    else {
        Write-Host ""
        Write-Success "Deployer is running at: http://localhost:$DeployerPort"

        if (-not $NoBrowser) {
            $open = Read-Host "Open in browser? (Y/N)"
            if ($open -eq 'Y' -or $open -eq 'y') {
                Start-Process "http://localhost:$DeployerPort"
            }
        }
        exit 0
    }
}
elseif ($Rebuild) {
    Write-Step "Forcing rebuild..."
    docker-compose down 2>&1 | Out-Null
}

# Build and start
Write-Host ""
Write-Step "Building and starting Silverware Game Server Deployer..."
Write-Host "  This may take a few minutes on first run..." -ForegroundColor DarkGray
Write-Host ""

try {
    if ($Rebuild) {
        docker-compose up --build -d --force-recreate 2>&1
    }
    else {
        docker-compose up --build -d 2>&1
    }

    if ($LASTEXITCODE -ne 0) {
        throw "docker-compose failed"
    }
}
catch {
    Write-Err "Failed to start the deployer."
    Write-Host ""
    Write-Host "Check the logs with: docker-compose logs" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Health check loop
Write-Host ""
Write-Step "Waiting for container to be healthy..."

$maxAttempts = 30
$attempt = 0
$healthy = $false

while ($attempt -lt $maxAttempts -and -not $healthy) {
    $attempt++
    Start-Sleep -Seconds 2

    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$DeployerPort/" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $healthy = $true
        }
    }
    catch {
        Write-Host "  Waiting... (attempt $attempt/$maxAttempts)" -ForegroundColor DarkGray
    }
}

if (-not $healthy) {
    Write-Warn "Container is taking longer than expected to start."
    Write-Host "  Check logs with: docker-compose logs" -ForegroundColor Yellow
}

# Success
Write-Host ""
Write-Success "Silverware Game Server Deployer is running!"
Write-Host ""
Write-Host "============================================" -ForegroundColor DarkCyan
Write-Host " Access the deployer at:" -ForegroundColor White
Write-Host ""
Write-Host "   http://localhost:$DeployerPort" -ForegroundColor Green
Write-Host ""
Write-Host " Useful commands:" -ForegroundColor White
Write-Host "   View logs:  docker-compose logs -f" -ForegroundColor DarkGray
Write-Host "   Stop:       docker-compose down" -ForegroundColor DarkGray
Write-Host "   Restart:    docker-compose restart" -ForegroundColor DarkGray
Write-Host "============================================" -ForegroundColor DarkCyan
Write-Host ""

# Prompt to open browser
if (-not $NoBrowser) {
    $open = Read-Host "Open in browser? (Y/N)"
    if ($open -eq 'Y' -or $open -eq 'y' -or $open -eq '') {
        Start-Process "http://localhost:$DeployerPort"
    }
}

Write-Host ""
