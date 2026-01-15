# Silverware Game Servers

![Games](https://img.shields.io/badge/Games-130+-brightgreen)
![Categories](https://img.shields.io/badge/Categories-14-blue)
![Proxmox](https://img.shields.io/badge/Proxmox-7.x%20%7C%208.x-orange)
![LinuxGSM](https://img.shields.io/badge/LinuxGSM-139%20games-informational)
![AMP](https://img.shields.io/badge/AMP-200%2B%20games-informational)
![License](https://img.shields.io/badge/License-MIT-yellow)

A complete game server deployment platform featuring **130+ dedicated game servers** with one-click deployment to Proxmox VE. Deploy LXC containers or full VMs for any game with a modern web interface.

**Powered by [LinuxGSM](https://linuxgsm.com/) (139 games) and [AMP CubeCoders](https://cubecoders.com/AMP) (200+ games) integrations.**

---

## What This Does

This project provides three ways to run dedicated game servers:

1. **Web-Based Deployer** - A Flask web app that connects to your Proxmox cluster and deploys game servers as LXC containers or VMs with one click
2. **Interactive Setup Script** - Traditional shell script for running game servers directly on a single Linux host
3. **Infrastructure as Code** - Terraform/Packer templates for automated VM provisioning

The web deployer is the recommended approach - it gives you a dark-themed dashboard to manage multiple Proxmox nodes, deploy servers, store credentials securely, and track all your deployments.

---

## Supported Games (130+)

This platform supports **130+ game servers** directly, with access to **139 games via LinuxGSM** and **200+ games via AMP CubeCoders**. Games marked with 🟢 have LinuxGSM support, 🔵 have AMP support.

### Source Engine (16 games)
The classics that started it all. All use SteamCMD for installation.

| Game | Steam App ID | Default Port | Integration |
|------|--------------|--------------|-------------|
| Counter-Strike 2 | 730 | 27015 | 🟢 LinuxGSM |
| Counter-Strike 1.6 | 90 | 27015 | 🟢 LinuxGSM |
| Counter-Strike: Source | 232330 | 27015 | 🟢 LinuxGSM |
| Team Fortress 2 | 232250 | 27015 | 🟢 LinuxGSM |
| Team Fortress Classic | 90 | 27015 | 🟢 LinuxGSM |
| Garry's Mod | 4020 | 27015 | 🟢 LinuxGSM |
| Left 4 Dead 2 | 222860 | 27015 | 🟢 LinuxGSM |
| Half-Life Deathmatch | 90 | 27015 | 🟢 LinuxGSM |
| Half-Life 2: Deathmatch | 232370 | 27015 | 🟢 LinuxGSM |
| Black Mesa | 346680 | 27015 | 🟢 LinuxGSM |
| Sven Co-op | 276060 | 27015 | 🟢 LinuxGSM |
| Day of Defeat | 30 | 27015 | 🟢 LinuxGSM |
| Day of Defeat: Source | 232290 | 27015 | 🟢 LinuxGSM |
| Fistful of Frags | 295230 | 27015 | 🟢 LinuxGSM |
| Synergy | 17520 | 27015 | 🟢 LinuxGSM |

### Survival Games (30+ games)
The most popular category - survival crafting games with dedicated servers.

| Game | Steam App ID | Default Port | Integration |
|------|--------------|--------------|-------------|
| Valheim | 896660 | 2456-2458 | 🟢 LinuxGSM |
| Rust | 258550 | 28015 | 🟢 LinuxGSM |
| 7 Days to Die | 294420 | 26900 | 🟢 LinuxGSM |
| Project Zomboid | 380870 | 16261-16262 | 🟢 LinuxGSM |
| Palworld | 2394010 | 8211 | 🟢 LinuxGSM |
| Enshrouded | 2278520 | 15636-15637 | 🔵 AMP |
| V Rising | 1604030 | 9876-9877 | 🔵 AMP |
| Conan Exiles | 443030 | 7777 | 🔵 AMP |
| ARK: Survival Ascended | 2430930 | 7777 | 🔵 AMP |
| ARK: Survival Evolved | 376030 | 7777 | 🟢 LinuxGSM |
| Don't Starve Together | 343050 | 10999-11000 | 🟢 LinuxGSM |
| Sons of the Forest | 2465200 | 8766 | 🔵 AMP |
| The Forest | 556450 | 8766 | 🔵 AMP |
| Barotrauma | 1026340 | 27015 | 🟢 LinuxGSM |
| SCUM | 3792580 | 7042 | 🔵 AMP |
| Core Keeper | 1963720 | 27015 | 🟢 LinuxGSM |
| Icarus | 2089300 | 17777 | 🔵 AMP |
| Eco | 382310 | 3000 | 🟢 LinuxGSM |
| The Isle | 412680 | 7777 | 🟢 LinuxGSM |
| Hurtworld | 405100 | 12871 | 🟢 LinuxGSM |
| Vintage Story | - | 42420 | 🟢 LinuxGSM |
| Craftopia | 1307550 | 6587 | 🟢 LinuxGSM |
| Empyrion | 530870 | 30000 | 🔵 AMP |
| CryoFall | 829590 | 6000 | 🔵 AMP |
| Longvinter | 1628750 | 7777 | 🔵 AMP |
| Nightingale | 1928980 | 7777 | 🔵 AMP |
| The Front | 2285150 | 25010 | 🟢 LinuxGSM |
| Myth of Empires | 1371580 | 12888 | 🔵 AMP |
| Last Oasis | 920720 | 5555 | 🔵 AMP |
| No One Survived | 1963370 | 7777 | 🔵 AMP |

### Military Simulation (10 games)
Tactical shooters and milsim games with dedicated server support.

| Game | Steam App ID | Default Port | Integration |
|------|--------------|--------------|-------------|
| DayZ | 223350 | 2302 | 🟢 LinuxGSM |
| ARMA 3 | 233780 | 2302 | 🟢 LinuxGSM |
| Arma Reforger | 1874900 | 2001 | 🟢 LinuxGSM |
| Squad | 403240 | 7787 | 🟢 LinuxGSM |
| Squad 44 (Post Scriptum) | 746200 | 10027 | 🟢 LinuxGSM |
| Hell Let Loose | 1348460 | 7777 | 🔵 AMP |
| Insurgency: Sandstorm | 581330 | 27102 | 🟢 LinuxGSM |
| Insurgency | 237410 | 27015 | 🟢 LinuxGSM |
| Day of Infamy | 462310 | 27015 | 🟢 LinuxGSM |

### Sandbox & Building (15 games)
Creative and building-focused games.

| Game | Steam App ID | Default Port | Integration |
|------|--------------|--------------|-------------|
| Minecraft Java | N/A | 25565 | 🟢 LinuxGSM |
| Minecraft Bedrock | N/A | 19132 | 🟢 LinuxGSM |
| Terraria | 105600 | 7777 | 🟢 LinuxGSM |
| Starbound | 211820 | 21025 | 🟢 LinuxGSM |
| Factorio | 427520 | 34197 | 🟢 LinuxGSM |
| Satisfactory | 1690800 | 7777 | 🟢 LinuxGSM |
| Space Engineers | 298740 | 27016 | 🔵 AMP |
| Stationeers | 544550 | 27500 | 🟢 LinuxGSM |
| Avorion | 565060 | 27000 | 🟢 LinuxGSM |
| Colony Survival | 366090 | 27016 | 🟢 LinuxGSM |
| Rising World | 324080 | 4255 | 🟢 LinuxGSM |
| Wurm Unlimited | 366220 | 3724 | 🟢 LinuxGSM |
| Astroneer | 728470 | 8777 | 🔵 AMP |
| OpenTTD | 1536610 | 3979 | 🔵 AMP |
| Minetest | N/A | 30000 | 🔵 AMP |

### Racing & Simulation (5 games)
Racing simulators with dedicated server support.

| Game | Steam App ID | Default Port | Integration |
|------|--------------|--------------|-------------|
| Assetto Corsa | 302550 | 9600 | 🔵 AMP |
| Assetto Corsa Competizione | 805550 | 9231 | 🔵 AMP |
| Euro Truck Simulator 2 | 227300 | 27015 | 🟢 LinuxGSM |
| American Truck Simulator | 270880 | 27015 | 🟢 LinuxGSM |
| BeamMP (BeamNG.drive) | N/A | 30814 | 🔵 AMP |

### Arena & Competitive (12 games)
Classic arena shooters and competitive games.

| Game | Steam App ID | Default Port | Integration |
|------|--------------|--------------|-------------|
| Quake III Arena | N/A | 27960 | 🟢 LinuxGSM |
| Quake 2 | N/A | 27910 | 🟢 LinuxGSM |
| Quake Live | 349090 | 27960 | 🟢 LinuxGSM |
| Xonotic | N/A | 26000 | 🟢 LinuxGSM |
| Unreal Tournament 99 | N/A | 7777 | 🟢 LinuxGSM |
| Unreal Tournament 2004 | N/A | 7777 | 🟢 LinuxGSM |
| Unreal Tournament 3 | N/A | 7777 | 🟢 LinuxGSM |
| Chivalry: Medieval Warfare | 220070 | 7777 | 🟢 LinuxGSM |
| MORDHAU | 629800 | 7777 | 🟢 LinuxGSM |
| Pavlov VR | 622970 | 7777 | 🟢 LinuxGSM |
| Teeworlds | N/A | 8303 | 🟢 LinuxGSM |
| Soldat | N/A | 23073 | 🟢 LinuxGSM |

### Co-op & Multiplayer (8 games)
Co-operative and social multiplayer games.

| Game | Steam App ID | Default Port | Integration |
|------|--------------|--------------|-------------|
| No More Room in Hell | 317670 | 27015 | 🟢 LinuxGSM |
| Natural Selection 2 | 4940 | 27015 | 🟢 LinuxGSM |
| SCP: Secret Laboratory | 996560 | 7777 | 🟢 LinuxGSM |
| Tower Unite | 439660 | 27015 | 🟢 LinuxGSM |
| Risk of Rain 2 | 1180760 | 27015 | 🔵 AMP |
| Rimworld Together | N/A | 25555 | 🔵 AMP |
| Path of Titans | N/A | 7777 | 🔵 AMP |
| Mindustry | 1127400 | 6567 | 🔵 AMP |

### Roleplay (6 games)
GTA and Red Dead multiplayer frameworks.

| Game | Port | Integration |
|------|------|-------------|
| FiveM (GTA V) | 30120 | 🔵 AMP |
| alt:V (GTA V) | 7788 | 🔵 AMP |
| RedM (Red Dead) | 30120 | 🔵 AMP |
| Multi Theft Auto | 22003 | 🟢 LinuxGSM |
| RAGE:MP (GTA V) | 22005 | 🔵 AMP |
| SA-MP | 7777 | 🟢 LinuxGSM |

### Classic Games (15 games)
Older titles that still have active communities.

| Game | Steam App ID | Default Port | Integration |
|------|--------------|--------------|-------------|
| Killing Floor | 215360 | 7707 | 🟢 LinuxGSM |
| Killing Floor 2 | 232130 | 7777 | 🟢 LinuxGSM |
| Call of Duty 4: MW | N/A | 28960 | 🟢 LinuxGSM |
| Call of Duty 2 | N/A | 28960 | 🟢 LinuxGSM |
| Call of Duty: World at War | N/A | 28960 | 🟢 LinuxGSM |
| Battlefield 1942 | N/A | 14567 | 🟢 LinuxGSM |
| Battlefield: Vietnam | N/A | 15567 | 🟢 LinuxGSM |
| Return to Castle Wolfenstein | N/A | 27960 | 🟢 LinuxGSM |
| Wolfenstein: Enemy Territory | N/A | 27960 | 🟢 LinuxGSM |
| Unturned | 304930 | 27015 | 🟢 LinuxGSM |

### Voice & Communication (1 app)
Voice servers for gaming communities.

| App | Ports | Integration |
|-----|-------|-------------|
| TeamSpeak 3 | 9987, 10011, 30033 | 🟢 LinuxGSM |

### RPG & Tabletop (2 games)
Virtual tabletop and RPG servers.

| Game | Port | Notes |
|------|------|-------|
| Foundry VTT | 30000 | Virtual tabletop for D&D, etc. |
| Necesse | 14159 | Action RPG with co-op |

### MMO Emulators (4 games)
Private server emulators for classic MMOs.

| Game | Port | Notes |
|------|------|-------|
| WoW (AzerothCore) | 3724, 8085 | WotLK private server |
| WoW (TrinityCore) | 3724, 8085 | Various expansions |
| SWGEmu | 44419 | Star Wars Galaxies |
| City of Heroes (Homecoming) | 2104 | Superhero MMO |

### Windows Games (Proton/Wine) (3 games)
Games that require Windows or Proton to run.

| Game | Steam App ID | Default Port | Notes |
|------|--------------|--------------|-------|
| Soulmask | 3040080 | 7777 | Requires Proton |
| HumanitZ | 2740380 | 7777 | Zombie survival |
| Longvinter | 1635450 | 7777 | Cozy survival |

### Server Management Panels (4 tools)
Tools to manage multiple game servers.

| Panel | Port | Supported Games |
|-------|------|-----------------|
| [LinuxGSM](https://linuxgsm.com/) | N/A | **139 games** - CLI-based, open source |
| [AMP (CubeCoders)](https://cubecoders.com/AMP) | 8080 | **200+ games** - Web UI, commercial |
| [Pterodactyl](https://pterodactyl.io/) | 80/443 | **200+ eggs** - Web UI, open source |
| [Crafty Controller](https://craftycontrol.com/) | 8443 | Minecraft focus, Python-based |

---

## Web Deployer Features

The Proxmox web deployer (`proxmox-deployer/`) is a Flask application that provides:

### LinuxGSM & AMP Integration
- **LinuxGSM support**: Deploy any of 139 games using [LinuxGSM](https://linuxgsm.com/) scripts
- **AMP templates**: Use [CubeCoders AMP](https://cubecoders.com/AMP) configurations for 200+ games
- **Automatic setup**: The deployer installs and configures LinuxGSM or Docker containers automatically
- **Pre-configured servers**: 130+ games have ready-to-deploy configurations with optimal settings

### One-Click Deployment
- Select a game from the library
- Choose your Proxmox node
- Pick LXC container or full VM
- Configure resources (CPU, RAM, disk)
- Deploy with one click

### Multi-Node Support
- Connect multiple Proxmox clusters
- Deploy across different nodes
- Manage all servers from one dashboard

### Credentials Vault
- Store Steam credentials securely
- Save game-specific passwords
- GSLT tokens for Valve games
- Encrypted storage with Fernet

### Deployment Tracking
- Full history of all deployments
- Status monitoring (running/stopped/error)
- Quick actions (start/stop/restart)
- Resource usage display

### Dark Theme UI
- Modern Bootstrap 5 interface
- Responsive design
- Game icons and categories
- Search and filter games

---

## Quick Start

### Option 1: Web Deployer (Recommended)

```bash
# Clone the repo
git clone https://github.com/sp00nznet/gameservers.git
cd gameservers/proxmox-deployer

# Run with Docker (easiest)
./start.sh docker

# Or run in development mode
./start.sh dev

# Access the web UI
open http://localhost:5000
```

Then:
1. Go to **Settings** and add your Proxmox connection
2. Browse **Servers** to see all 75+ games
3. Click **Deploy** on any game
4. Configure resources and deploy

### Option 2: Interactive Setup Script

For running servers directly on a single Linux host:

```bash
git clone https://github.com/sp00nznet/gameservers.git
cd gameservers
sudo ./setup.sh
```

The interactive menu lets you:
- Install individual game servers
- Check server status
- Start/stop services
- View logs

### Option 3: Infrastructure as Code

For automated Proxmox VM provisioning with Terraform:

```bash
cd infrastructure/packer
packer build ubuntu-gameserver.pkr.hcl

cd ../terraform
terraform init
terraform apply
```

See [infrastructure/README.md](infrastructure/README.md) for details.

---

## Requirements

### For Web Deployer
- **Python 3.8+** or **Docker**
- **Proxmox VE 7.0+** or **8.0+**
- API access to Proxmox (user + token or password)

### For Direct Host Installation
- **Linux** (Debian 11+, Ubuntu 20.04+ recommended)
- **Root access** (sudo)
- **RAM**: 2GB minimum, 16GB+ for heavy games (ARK, Rust, WoW)
- **Storage**: 20GB+ per game server

### For Terraform/Packer
- **Proxmox VE 7.0+**
- **Terraform 1.0+**
- **Packer 1.8+**

---

## How Deployment Works

### LXC Containers (Default)
Most games run in LXC containers - lightweight Linux containers that share the host kernel:

1. Deployer calls Proxmox API to create LXC container
2. Container uses Ubuntu/Debian template
3. Post-install script runs SteamCMD or Docker
4. Game server starts via systemd or Docker Compose
5. Ports are forwarded automatically

**Pros**: Fast startup, low overhead, easy snapshots
**Cons**: Linux only, shared kernel

### Virtual Machines
Some games need full VMs (Windows games, Proton, or isolation):

1. Deployer calls Proxmox API to create QEMU VM
2. VM boots from cloud-init or ISO
3. Post-install script configures the game
4. Server runs natively or under Proton

**Pros**: Full isolation, Windows support, hardware passthrough
**Cons**: Higher resource usage, slower startup

### Docker Mode
Within containers/VMs, many games use Docker:

```yaml
# Example: Valheim in Docker
services:
  valheim:
    image: lloesche/valheim-server
    ports:
      - "2456-2458:2456-2458/udp"
    environment:
      - SERVER_NAME=My Server
      - WORLD_NAME=MyWorld
      - SERVER_PASS=secret
```

---

## Project Structure

```
gameservers/
├── README.md                 # You are here
├── setup.sh                  # Interactive setup script
├── lib/
│   └── common.sh             # Shared shell functions
├── proxmox-deployer/         # Web-based deployment UI
│   ├── app/
│   │   ├── __init__.py       # Flask app factory
│   │   ├── routes.py         # API endpoints
│   │   ├── models.py         # Database models
│   │   ├── proxmox_client.py # Proxmox API client
│   │   └── game_servers.py   # All 75+ game definitions
│   ├── templates/            # Jinja2 HTML templates
│   ├── static/               # CSS, JS, images
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── start.sh              # Startup script
├── docs/
│   ├── game-configuration.md # Per-game settings
│   ├── firewall.md           # Port rules
│   └── troubleshooting.md    # Common issues
├── infrastructure/           # Terraform/Packer IaC
│   ├── packer/               # VM templates
│   └── terraform/            # Deployment configs
└── <game>/                   # Per-game setup scripts
    ├── setup.sh
    ├── docker-compose.yml
    └── config/
```

---

## Configuration

### Adding a Proxmox Connection

In the web UI, go to Settings and add:

| Field | Description |
|-------|-------------|
| Name | Friendly name for this cluster |
| Host | Proxmox IP or hostname |
| Port | API port (default 8006) |
| Username | `root@pam` or API user |
| Password/Token | Authentication credential |
| Verify SSL | Enable for production |

### Game-Specific Settings

Each game has configurable options:

- **Resources**: CPU cores, RAM, disk size
- **Network**: Port mappings, IP assignment
- **Environment**: Server name, passwords, RCON
- **Storage**: Save location, backup settings

See [docs/game-configuration.md](docs/game-configuration.md) for per-game details.

### Firewall Rules

The deployer can configure Proxmox firewall rules automatically, or you can set them manually. See [docs/firewall.md](docs/firewall.md) for all port requirements.

---

## API Reference

The web deployer exposes a REST API:

### Connections
```
GET    /api/connections          # List all Proxmox connections
POST   /api/connections          # Add new connection
GET    /api/connections/:id      # Get connection details
DELETE /api/connections/:id      # Remove connection
POST   /api/connections/:id/test # Test connection
```

### Deployments
```
GET    /api/deployments          # List all deployments
POST   /api/deployments          # Create new deployment
GET    /api/deployments/:id      # Get deployment status
DELETE /api/deployments/:id      # Remove deployment
POST   /api/deployments/:id/start  # Start server
POST   /api/deployments/:id/stop   # Stop server
```

### Servers
```
GET    /api/servers              # List all game servers
GET    /api/servers/:id          # Get server details
GET    /api/servers/category/:cat # Filter by category
GET    /api/servers/search?q=    # Search servers
```

### Credentials
```
GET    /api/credentials          # List stored credentials
POST   /api/credentials          # Store new credential
DELETE /api/credentials/:id      # Remove credential
```

---

## Service Management

For servers installed via the setup script:

```bash
# Systemd commands
sudo systemctl start valheim      # Start server
sudo systemctl stop valheim       # Stop server
sudo systemctl restart valheim    # Restart server
sudo systemctl status valheim     # Check status
sudo journalctl -u valheim -f     # View logs

# Common service names
tf2server, csserver, cs2server, pzserver, arkserver,
valheim, rust, factorio, minecraft, terraria
```

### Console Access

```bash
# Attach to game console (screen)
sudo screen -r valheim

# Detach without stopping
# Press: Ctrl+A, then D

# List all screens
screen -ls
```

---

## Troubleshooting

### Proxmox Connection Failed
- Verify host/port are correct
- Check API user has correct permissions
- Ensure firewall allows port 8006
- Try with `Verify SSL` disabled for self-signed certs

### Container Won't Start
- Check Proxmox task log for errors
- Verify template exists on target storage
- Ensure enough resources are available
- Check network bridge configuration

### Game Server Crashes
- Review logs: `journalctl -u <service> -n 100`
- Check RAM usage - some games need 8GB+
- Verify all required ports are open
- Check game-specific config in docs

See [docs/troubleshooting.md](docs/troubleshooting.md) for more solutions.

---

## Contributing

### Adding a New Game

1. Add the game definition to `proxmox-deployer/app/game_servers.py`:

```python
'newgame': {
    'name': 'New Game',
    'category': 'survival',
    'steam_app_id': 123456,
    'ports': {'game': 27015, 'query': 27016},
    'default_resources': {'cpu': 2, 'memory': 4096, 'disk': 20},
    'docker_image': 'gameserver/newgame',
    'env_vars': {
        'SERVER_NAME': 'My Server',
        'SERVER_PASSWORD': ''
    }
}
```

2. Add setup script in `newgame/setup.sh`
3. Update `docs/game-configuration.md`
4. Update `docs/firewall.md` with ports
5. Submit a pull request

### Development Setup

```bash
cd proxmox-deployer
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
./start.sh dev
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Credits

- [LinuxGSM](https://linuxgsm.com/) - Game server management scripts
- [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) - Steam dedicated server tool
- [Pterodactyl](https://pterodactyl.io/) - Game server panel (eggs referenced)
- [Docker Hub](https://hub.docker.com/) - Container images for many games

---

**Questions?** Open an issue or check the [docs](docs/) folder.
