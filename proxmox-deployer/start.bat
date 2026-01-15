@echo off
setlocal enabledelayedexpansion

:: Silverware Game Server Deployer - Windows Launcher
:: Double-click this file to start the deployer

title Silverware Game Server Deployer

echo.
echo   ____  _ _
echo  / ___^|(_) ^|_   _____ _ ____      ____ _ _ __ ___
echo  \___ \^| ^| \ \ / / _ \ '__\ \ /\ / / _` ^| '__/ _ \
echo   ___) ^| ^| ^|\ V /  __/ ^|   \ V  V / (_^| ^| ^| ^|  __/
echo  ^|____/^|_^|_^| \_/ \___^|_^|    \_/\_/ \__,_^|_^|  \___^|
echo.
echo          Game Server Deployer - Windows Launcher
echo.

:: Check for Docker
echo [INFO] Checking for Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Docker is not installed or not in PATH.
    echo.
    echo Please install Docker Desktop from:
    echo   https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)

:: Check if Docker daemon is running
docker info >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Docker daemon is not running.
    echo.
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)
echo [OK] Docker is available.

:: Change to script directory
cd /d "%~dp0"

:: Check for .env file
if not exist ".env" (
    echo [INFO] Creating .env file from template...
    if exist ".env.example" (
        copy ".env.example" ".env" >nul
    ) else (
        echo SECRET_KEY=change-me-in-production-%RANDOM%%RANDOM%> .env
        echo FLASK_ENV=production>> .env
    )
    echo [OK] Created .env file. Edit it to customize settings.
)

:: Check if container is already running
docker ps --format "{{.Names}}" 2>nul | findstr /i "silverware-deployer" >nul
if not errorlevel 1 (
    echo.
    echo [WARN] Silverware Deployer is already running.
    echo.
    set /p RESTART="Do you want to restart it? (Y/N): "
    if /i "!RESTART!"=="Y" (
        echo.
        echo [INFO] Stopping existing container...
        docker-compose down
    ) else (
        echo.
        echo [INFO] Opening deployer in browser...
        start http://localhost:5555
        echo.
        echo Access the deployer at: http://localhost:5555
        echo.
        pause
        exit /b 0
    )
)

:: Build and start
echo.
echo [INFO] Building and starting Silverware Game Server Deployer...
echo [INFO] This may take a few minutes on first run...
echo.

docker-compose up --build -d

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to start the deployer.
    echo.
    echo Check the logs with: docker-compose logs
    echo.
    pause
    exit /b 1
)

:: Wait for container to be healthy
echo.
echo [INFO] Waiting for container to be ready...
set ATTEMPTS=0
:healthcheck
set /a ATTEMPTS+=1
if %ATTEMPTS% gtr 30 (
    echo.
    echo [WARN] Container is taking longer than expected to start.
    echo [WARN] Check logs with: docker-compose logs
    goto :done
)

timeout /t 2 /nobreak >nul

curl -s -o nul http://localhost:5555/ 2>nul
if errorlevel 1 (
    echo [INFO] Waiting... ^(attempt %ATTEMPTS%/30^)
    goto :healthcheck
)

:done
echo.
echo [OK] Silverware Game Server Deployer is running!
echo.
echo ============================================
echo  Access the deployer at:
echo.
echo    http://localhost:5555
echo.
echo  Useful commands:
echo    View logs:  docker-compose logs -f
echo    Stop:       docker-compose down
echo    Restart:    docker-compose restart
echo ============================================
echo.

set /p OPEN="Open in browser? (Y/N): "
if /i "!OPEN!"=="Y" (
    start http://localhost:5555
)

echo.
pause
