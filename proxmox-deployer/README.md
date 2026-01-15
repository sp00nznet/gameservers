# Silverware Game Server Deployer

<div align="center">

**One-Click Game Server Deployment to Proxmox VE**

[![Games](https://img.shields.io/badge/Games-75+-blue?style=for-the-badge)](https://github.com/sp00nznet/gameservers)
[![Categories](https://img.shields.io/badge/Categories-11-green?style=for-the-badge)](https://github.com/sp00nznet/gameservers)
[![Python](https://img.shields.io/badge/Python-3.8+-yellow?style=for-the-badge&logo=python)](https://python.org)
[![Proxmox](https://img.shields.io/badge/Proxmox-7.0+-orange?style=for-the-badge)](https://proxmox.com)

*Deploy game servers as LXC containers or VMs with a beautiful dark-themed web interface*

</div>

---

## What's This?

A Flask-based web application that lets you deploy game servers to your Proxmox cluster with just a few clicks. No more manually configuring VMs, installing dependencies, or hunting for documentation.

**Pick a game. Click deploy. Play.**

---

## Supported Games (75+)

### Source Engine (11 games)
| Game | Players | Description |
|------|---------|-------------|
| Counter-Strike 2 | 16 | The latest in tactical FPS gaming |
| Counter-Strike 1.6 | 32 | The classic that started it all |
| Team Fortress 2 | 24 | Free-to-play class-based shooter |
| Garry's Mod | 24 | Physics sandbox with endless mods |
| Left 4 Dead 2 | 8 | Co-op zombie survival shooter |
| Black Mesa | 16 | Half-Life reimagined |
| Half-Life 2: DM | 16 | Gravity gun chaos |
| Half-Life DM | 16 | Original arena combat |
| Team Fortress Classic | 24 | The OG team shooter |
| Sven Co-op | 12 | Cooperative Half-Life |
| Synergy | 8 | Co-op HL2 gameplay |

### Survival Games (22 games)
| Game | Players | Description |
|------|---------|-------------|
| Rust | 50+ | Brutal PvP survival |
| Valheim | 10 | Viking exploration & building |
| 7 Days to Die | 8 | Zombie survival with horde nights |
| Project Zomboid | 16 | Isometric zombie apocalypse |
| Palworld | 32 | Pokemon meets survival crafting |
| Enshrouded | 16 | Action RPG survival |
| V Rising | 40 | Vampire survival builder |
| Conan Exiles | 40 | Brutal open-world survival |
| ARK: Survival Ascended | 70 | Dinosaur taming & survival |
| DayZ | 60 | Hardcore zombie survival |
| Sons of the Forest | 8 | Survival horror sequel |
| The Forest | 8 | Survival horror original |
| SCUM | 64 | Open-world prison survival |
| Barotrauma | 16 | Submarine crew survival |
| Icarus | 8 | Session-based planet survival |
| Core Keeper | 8 | Mining sandbox RPG |
| Necesse | 10 | Action RPG survival |
| Soulmask | 50 | Tribal survival crafting |
| Unturned | 24 | Blocky zombie survival |
| Abiotic Factor | 6 | Cooperative sci-fi survival |
| HumanitZ | 32 | Open-world zombie survival |
| Don't Starve Together | 6 | Whimsical survival |

### Military Simulation (7 games)
| Game | Players | Description |
|------|---------|-------------|
| ARMA 3 | 64+ | Ultimate military sandbox |
| Arma Reforger | 128 | Next-gen Arma engine |
| Squad | 100 | Tactical 50v50 warfare |
| Hell Let Loose | 100 | WW2 combined arms |
| Insurgency: Sandstorm | 28 | Modern tactical shooter |
| Post Scriptum | 80 | WW2 realistic combat |
| DayZ | 60 | Post-apocalyptic survival |

### Sandbox & Building (10 games)
| Game | Players | Description |
|------|---------|-------------|
| Minecraft Java | 20+ | The sandbox phenomenon |
| Minecraft Bedrock | 10+ | Cross-platform Minecraft |
| Terraria | 8 | 2D action-adventure sandbox |
| Starbound | 8 | Space exploration sandbox |
| Factorio | Varies | Factory automation |
| Satisfactory | 4 | 3D factory building |
| Space Engineers | 16+ | Space construction |
| Stationeers | 10 | Space station simulation |
| Avorion | 10 | Space sandbox building |
| Unturned | 24 | Blocky survival sandbox |

### Racing & Simulation (4 games)
| Game | Players | Description |
|------|---------|-------------|
| Assetto Corsa | 24 | Racing simulation king |
| Assetto Corsa Competizione | 30 | GT racing simulator |
| Euro Truck Simulator 2 | 8 | European trucking |
| American Truck Simulator | 8 | American trucking |

### Roleplay (3 games)
| Game | Players | Description |
|------|---------|-------------|
| FiveM | 32-2048 | GTA V roleplay platform |
| alt:V | 128+ | Alternative GTA V multiplayer |
| RedM | 32+ | RDR2 roleplay platform |

### Classic Games (8 games)
| Game | Players | Description |
|------|---------|-------------|
| Killing Floor 2 | 6 | Zombie wave survival |
| Killing Floor | 6 | Original zombie waves |
| Unreal Tournament 2004 | 16 | Arena FPS classic |
| Unreal Tournament 99 | 16 | The original UT |
| SA-MP | 50+ | GTA San Andreas MP |
| Quake III Arena | 16 | Arena FPS legend |
| Dota 2 | 10 | Custom lobby/tournament |
| Marvel Rivals | Varies | Hero shooter customs |

### MMO Emulators (3 servers)
| Game | Description |
|------|-------------|
| AzerothCore | WoW 3.3.5a private server |
| SWGEmu | Star Wars Galaxies Pre-CU |
| City of Heroes | Superhero MMO emulator |

### Server Management (4 panels)
| Panel | Description |
|-------|-------------|
| Pterodactyl | Multi-game server panel |
| Crafty Controller | Minecraft management |
| AMP | CubeCoders management |
| Foundry VTT | Virtual tabletop |

---

## Features

### One-Click Deployment
Select your game, configure basic settings, and deploy. The system handles template selection, resource allocation, and service configuration automatically.

### Smart Resource Allocation
Each game has pre-configured CPU, memory, and disk requirements based on real-world testing. No more guessing about specifications.

### Credentials Vault
Securely store:
- Steam Game Server Login Tokens (GSLT)
- Admin passwords
- SSH keys
- Database credentials

### Deployment Types

| Type | Best For | Technology |
|------|----------|------------|
| **LXC Container** | Most games | Lightweight Linux containers with Docker |
| **VM (Proton)** | Windows games on Linux | Full VM with Proton/Wine |
| **VM (Windows)** | Windows-only games | Windows Server with auto-setup |
| **VM (Compiled)** | Emulators | Build toolchain + database |

### Dark Theme UI
Modern, responsive interface built with Bootstrap 5. Works on desktop and mobile.

---

## Quick Start

### Option 1: Development Mode
```bash
cd proxmox-deployer
./start.sh dev
```

### Option 2: Production Mode
```bash
cd proxmox-deployer
./start.sh prod
```

### Option 3: Docker
```bash
cd proxmox-deployer
./start.sh docker
```

Access at: **http://localhost:5000**

---

## First-Time Setup

1. **Start the deployer** using any method above
2. **Navigate to Settings**
3. **Add your Proxmox connection:**
   - Name: `My Proxmox`
   - Host: `192.168.1.100` (your Proxmox IP)
   - Port: `8006`
   - Username: `root@pam`
   - Authentication: Password or API Token
4. **Test the connection**
5. **Browse Game Servers and deploy!**

---

## Requirements

### For the Deployer
- Python 3.8+ (native) or Docker
- Network access to Proxmox API (port 8006)

### For Proxmox
- Proxmox VE 7.0+ or 8.0+
- LXC templates (Ubuntu 22.04 recommended)
- VM templates (for Windows/Proton games)
- Sufficient storage and compute resources

### Recommended Resources

| Server Type | Min CPU | Min RAM | Min Disk |
|-------------|---------|---------|----------|
| Source Engine | 2 cores | 2 GB | 20 GB |
| Survival (small) | 2 cores | 4 GB | 20 GB |
| Survival (large) | 4 cores | 16 GB | 50 GB |
| Military Sim | 4 cores | 8 GB | 50 GB |
| Minecraft | 4 cores | 8 GB | 30 GB |
| ARK/Large Games | 6 cores | 32 GB | 100 GB |
| MMO Emulators | 8 cores | 16 GB | 100 GB |

---

## API Reference

### Connections
```
GET    /api/connections              # List all
POST   /api/connections              # Create new
PUT    /api/connections/<id>         # Update
DELETE /api/connections/<id>         # Delete
POST   /api/connections/<id>/test    # Test connection
GET    /api/connections/<id>/nodes   # Get nodes
```

### Deployments
```
GET    /api/deployments              # List all
POST   /api/deploy                   # Deploy server
GET    /api/deployments/<id>         # Get details
POST   /api/deployments/<id>/start   # Start server
POST   /api/deployments/<id>/stop    # Stop server
DELETE /api/deployments/<id>         # Delete
```

### Servers
```
GET    /api/servers                  # List all games
GET    /api/servers?category=source  # Filter by category
GET    /api/servers/<key>            # Get game details
GET    /api/categories               # List categories
GET    /api/stats                    # Statistics
```

---

## Project Structure

```
proxmox-deployer/
├── app/
│   ├── __init__.py          # Flask app factory
│   ├── models.py            # Database models
│   ├── routes.py            # Web routes & API
│   ├── proxmox_client.py    # Proxmox VE API client
│   ├── game_servers.py      # 75+ game definitions
│   ├── static/              # CSS, JS, images
│   └── templates/           # Jinja2 HTML templates
├── run.py                   # Application entry
├── config.py                # Configuration
├── requirements.txt         # Dependencies
├── Dockerfile               # Container build
├── docker-compose.yml       # Docker setup
├── start.sh                 # Start script
└── stop.sh                  # Stop script
```

---

## Configuration

### Environment Variables

```bash
# Required for production
SECRET_KEY=your-secure-random-key

# Optional
DATABASE_URL=sqlite:///data/deployer.db
FLASK_ENV=production
```

### .env File
```bash
cp .env.example .env
# Edit with your settings
```

---

## Security Notes

- Use API tokens instead of passwords when possible
- Generate a secure `SECRET_KEY` for production
- SSL verification is optional for self-signed certs
- Credentials are stored in SQLite (consider encryption)
- Never expose the deployer to the public internet without authentication

---

## Troubleshooting

### Connection Failed
- Verify Proxmox host and port
- Check firewall allows port 8006
- Ensure user has API permissions
- Try disabling SSL verification

### Deployment Failed
- Check storage pool has space
- Verify template exists
- Review Proxmox task logs
- Ensure network bridge exists

### Container Won't Start
- Check resource allocation
- Verify network config
- Review container logs in Proxmox

---

## Contributing

1. Fork the repository
2. Add new games to `app/game_servers.py`
3. Test deployment
4. Submit pull request

### Adding a New Game

```python
'mygame': {
    'name': 'My Game',
    'hostname': 'mygame-server',
    'description': 'Description here',
    'category': 'survival',  # Match existing category
    'deployment_type': 'lxc',  # or 'vm'
    'steam_app_id': 123456,
    'cores': 2,
    'memory': 4096,
    'disk_size': 20,
    'ports': [27015],
    'protocol': 'UDP',
    'tags': ['survival', 'coop'],
    'icon': 'shield',
    'docker_image': 'cm2network/steamcmd',
    'env_vars': [
        {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'My Server'},
    ],
}
```

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| Backend | Flask (Python) |
| Database | SQLAlchemy + SQLite |
| Frontend | Bootstrap 5 + Icons |
| Proxmox API | proxmoxer |
| Production Server | Gunicorn |
| Containers | Docker |

---

## License

MIT License - See LICENSE file

---

<div align="center">

**Built for gamers, by gamers.**

[Report Issue](https://github.com/sp00nznet/gameservers/issues) |
[Request Game](https://github.com/sp00nznet/gameservers/issues)

</div>
