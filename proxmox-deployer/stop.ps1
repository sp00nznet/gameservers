#Requires -Version 5.1
<#
.SYNOPSIS
    Silverware Game Server Deployer - Stop Script

.DESCRIPTION
    Stops the Silverware Game Server Deployer Docker container.
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "  Silverware Game Server Deployer" -ForegroundColor Blue
Write-Host "  ================================" -ForegroundColor Blue
Write-Host ""
Write-Host "  Stopping the deployer..." -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot

try {
    docker-compose down 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "  [OK] Silverware Deployer has been stopped." -ForegroundColor Green
    }
    else {
        throw "docker-compose failed"
    }
}
catch {
    Write-Host ""
    Write-Host "  [ERROR] Failed to stop. Is Docker running?" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to exit"
