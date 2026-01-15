#!/bin/bash
#
# Silverware Game Server Deployer - Stop Script
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Stopping Game Server Deployer..."

# Stop Docker containers if running
if command -v docker &> /dev/null; then
    docker compose down 2>/dev/null || true
fi

# Kill any running Python processes for this app
pkill -f "python.*run.py" 2>/dev/null || true
pkill -f "gunicorn.*run:app" 2>/dev/null || true

echo "Stopped."
