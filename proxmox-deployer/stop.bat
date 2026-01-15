@echo off
:: Silverware Game Server Deployer - Stop Script

title Stopping Silverware Deployer

echo.
echo   Silverware Game Server Deployer
echo   ================================
echo.
echo   Stopping the deployer...
echo.

cd /d "%~dp0"

docker-compose down

if %errorlevel% equ 0 (
    echo.
    echo   [OK] Silverware Deployer has been stopped.
) else (
    echo.
    echo   [ERROR] Failed to stop. Is Docker running?
)

echo.
pause
