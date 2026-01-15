# Silverware Game Server Deployer

A web-based interface for deploying game servers to Proxmox VE with one-click simplicity.

## Features

- **40+ Pre-configured Game Servers** across 8 categories
- **One-click Deployment** to Proxmox LXC containers or VMs
- **Dark-themed Web UI** with responsive design
- **Credentials Vault** for storing Steam tokens, passwords, and SSH keys
- **Deployment History** with status tracking and management
- **Multi-connection Support** for multiple Proxmox servers

## Game Server Categories

| Category | Games | Description |
|----------|-------|-------------|
| Source Engine | CS 1.6, CS2, TF2, GMod, L4D2 | Valve Source/GoldSrc engine games |
| Survival | Valheim, Rust, 7DTD, PZ, Palworld | Survival and crafting games |
| Sandbox | Minecraft, Terraria, Factorio, Satisfactory | Building and automation |
| Classic | Killing Floor, UT99, UT2004, Quake 3 | Classic FPS and arena shooters |
| MMO Emulators | AzerothCore (WoW), SWGEmu | Private server emulators |
| Management | Pterodactyl, Crafty, AMP | Server management panels |
| RPG & Tabletop | Foundry VTT | Virtual tabletop platforms |
| Windows | City of Heroes | Windows-only game servers |

## Quick Start

### Option 1: Development Mode
```bash
./start.sh dev
```

### Option 2: Production Mode
```bash
./start.sh prod
```

### Option 3: Docker
```bash
./start.sh docker
```

Access the deployer at: **http://localhost:5000**

## Requirements

- **Python 3.8+** (for native installation)
- **Docker** (for containerized deployment)
- **Proxmox VE 7.0+** or **8.0+**
- Network access to Proxmox API (port 8006)

## Configuration

1. Copy `.env.example` to `.env`
2. Set a secure `SECRET_KEY` for production
3. Configure your database URL if not using SQLite

```bash
cp .env.example .env
# Edit .env with your settings
```

## First-Time Setup

1. Start the deployer using one of the methods above
2. Navigate to **Settings** in the web UI
3. Add your Proxmox connection:
   - Connection name
   - Proxmox host/IP and port (default: 8006)
   - Username (e.g., `root@pam`)
   - Password or API token
4. Test the connection
5. Browse **Game Servers** and deploy!

## Project Structure

```
proxmox-deployer/
├── app/
│   ├── __init__.py          # Flask application factory
│   ├── models.py            # Database models
│   ├── routes.py            # Flask routes and API endpoints
│   ├── proxmox_client.py    # Proxmox API client
│   ├── game_servers.py      # Game server definitions
│   └── templates/           # Jinja2 HTML templates
├── run.py                   # Application entry point
├── config.py                # Configuration classes
├── requirements.txt         # Python dependencies
├── Dockerfile               # Container image definition
├── docker-compose.yml       # Docker Compose config
├── start.sh                 # Startup script
└── stop.sh                  # Shutdown script
```

## API Endpoints

### Connections
- `GET /api/connections` - List all connections
- `POST /api/connections` - Create connection
- `PUT /api/connections/<id>` - Update connection
- `DELETE /api/connections/<id>` - Delete connection
- `POST /api/connections/<id>/test` - Test connection
- `GET /api/connections/<id>/nodes` - Get available nodes
- `GET /api/connections/<id>/nodes/<node>/templates` - Get templates
- `GET /api/connections/<id>/nodes/<node>/storage` - Get storage pools
- `GET /api/connections/<id>/nodes/<node>/networks` - Get network bridges

### Deployments
- `GET /api/deployments` - List all deployments
- `POST /api/deploy` - Deploy a game server
- `GET /api/deployments/<id>` - Get deployment details
- `POST /api/deployments/<id>/start` - Start server
- `POST /api/deployments/<id>/stop` - Stop server
- `GET /api/deployments/<id>/status` - Get current status
- `DELETE /api/deployments/<id>` - Delete deployment

### Servers
- `GET /api/servers` - List all game servers
- `GET /api/servers/<key>` - Get server definition
- `GET /api/categories` - List categories
- `GET /api/stats` - Get statistics

## Technology Stack

- **Backend**: Flask (Python)
- **Database**: SQLAlchemy with SQLite
- **Frontend**: Bootstrap 5, Bootstrap Icons
- **Proxmox API**: proxmoxer library
- **Production Server**: Gunicorn

## Deployment Types

### LXC Containers
Lightweight Linux containers for Docker-based game servers. Most efficient for:
- Source engine games
- Minecraft (Java/Bedrock)
- Most survival games
- Management panels

### Virtual Machines
Full VMs for games requiring:
- Proton/Wine compatibility (ARK ASA)
- Compiled server software (WoW, SWGEmu)
- Windows-only games (City of Heroes)

## Security Notes

- Use API tokens instead of passwords when possible
- Generate a secure `SECRET_KEY` for production
- Credentials are stored encrypted in the database
- SSL verification is optional but recommended

## Troubleshooting

### Connection Failed
- Verify Proxmox host and port are correct
- Check firewall allows access to port 8006
- Ensure API user has appropriate permissions
- Try disabling SSL verification for self-signed certs

### Deployment Failed
- Check storage pool has sufficient space
- Verify template exists on target node
- Review Proxmox task logs for details
- Ensure network bridge exists

### Container Won't Start
- Check resource allocation (memory, CPU)
- Verify network configuration
- Review container logs via Proxmox console

## License

MIT License - See LICENSE file for details.
