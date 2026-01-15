#!/bin/bash
#
# Silverware Game Server Deployer - Startup Script
# Usage: ./start.sh [dev|prod|docker]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "  ____  _ _                                      "
echo " / ___|(_) |_   _____ _ ____      ____ _ _ __ ___ "
echo " \___ \| | \ \ / / _ \ '__\ \ /\ / / _\` | '__/ _ \\"
echo "  ___) | | |\ V /  __/ |   \ V  V / (_| | | |  __/"
echo " |____/|_|_| \_/ \___|_|    \_/\_/ \__,_|_|  \___|"
echo ""
echo "         Game Server Deployer"
echo -e "${NC}"

MODE="${1:-dev}"

case "$MODE" in
    dev|development)
        echo -e "${GREEN}Starting in development mode...${NC}"

        # Check for Python
        if ! command -v python3 &> /dev/null; then
            echo "Python 3 is required. Please install it first."
            exit 1
        fi

        # Create virtual environment if needed
        if [ ! -d "venv" ]; then
            echo "Creating virtual environment..."
            python3 -m venv venv
        fi

        # Activate and install dependencies
        source venv/bin/activate
        pip install -q -r requirements.txt

        echo -e "${GREEN}Starting Flask development server...${NC}"
        echo -e "${YELLOW}Access the deployer at: http://localhost:5000${NC}"
        echo ""

        export FLASK_APP=run.py
        export FLASK_ENV=development
        export FLASK_DEBUG=1
        python run.py
        ;;

    prod|production)
        echo -e "${GREEN}Starting in production mode...${NC}"

        # Check for Python
        if ! command -v python3 &> /dev/null; then
            echo "Python 3 is required. Please install it first."
            exit 1
        fi

        # Create virtual environment if needed
        if [ ! -d "venv" ]; then
            echo "Creating virtual environment..."
            python3 -m venv venv
        fi

        # Activate and install dependencies
        source venv/bin/activate
        pip install -q -r requirements.txt

        echo -e "${GREEN}Starting Gunicorn server...${NC}"
        echo -e "${YELLOW}Access the deployer at: http://localhost:5000${NC}"
        echo ""

        export FLASK_ENV=production
        gunicorn --bind 0.0.0.0:5000 --workers 2 run:app
        ;;

    docker)
        echo -e "${GREEN}Starting with Docker Compose...${NC}"

        if ! command -v docker &> /dev/null; then
            echo "Docker is required. Please install it first."
            exit 1
        fi

        docker compose up --build -d

        echo -e "${GREEN}Container started!${NC}"
        echo -e "${YELLOW}Access the deployer at: http://localhost:5000${NC}"
        echo ""
        echo "View logs: docker compose logs -f"
        echo "Stop: docker compose down"
        ;;

    *)
        echo "Usage: $0 [dev|prod|docker]"
        echo ""
        echo "Modes:"
        echo "  dev    - Development mode with Flask debug server"
        echo "  prod   - Production mode with Gunicorn"
        echo "  docker - Build and run with Docker Compose"
        exit 1
        ;;
esac
