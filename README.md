# Silverware Game Servers

![Games](https://img.shields.io/badge/Games-250+-brightgreen)
![Categories](https://img.shields.io/badge/Categories-14-blue)
![Proxmox](https://img.shields.io/badge/Proxmox-7.x%20%7C%208.x-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)

A complete game server deployment platform featuring **250+ dedicated game servers** with one-click deployment to Proxmox VE. Deploy LXC containers or full VMs for any game with a modern web interface.

---

## What This Does

This project provides three ways to run dedicated game servers:

1. **Web-Based Deployer** - A Flask web app that connects to your Proxmox cluster and deploys game servers as LXC containers or VMs with one click
2. **Interactive Setup Script** - Traditional shell script for running game servers directly on a single Linux host
3. **Infrastructure as Code** - Terraform/Packer templates for automated VM provisioning

The web deployer is the recommended approach - it gives you a dark-themed dashboard to manage multiple Proxmox nodes, deploy servers, store credentials securely, and track all your deployments.

---

## Supported Games (250+)

This platform supports **250+ game servers** across 14 categories.

### Source Engine
| Game | Steam App ID | Default Port |
|------|--------------|--------------|
| Counter-Strike 2 | 730 | 27015 |
| Counter-Strike 1.6 | 90 | 27015 |
| Counter-Strike: Source | 232330 | 27015 |
| Counter-Strike: Condition Zero | 80 | 27015 |
| Counter-Strike: Global Offensive | 740 | 27015 |
| Team Fortress 2 | 232250 | 27015 |
| Team Fortress Classic | 90 | 27015 |
| Garry's Mod | 4020 | 27015 |
| Left 4 Dead | 222840 | 27015 |
| Left 4 Dead 2 | 222860 | 27015 |
| Half-Life Deathmatch | 90 | 27015 |
| Half-Life 2: Deathmatch | 232370 | 27015 |
| Half-Life Deathmatch: Source | 360 | 27015 |
| Black Mesa | 346680 | 27015 |
| Sven Co-op | 276060 | 27015 |
| Day of Defeat | 30 | 27015 |
| Day of Defeat: Source | 232290 | 27015 |
| Fistful of Frags | 295230 | 27015 |
| Synergy | 17520 | 27015 |
| Deathmatch Classic | 40 | 27015 |
| Ricochet | 60 | 27015 |
| Opposing Force | 50 | 27015 |
| Action Half-Life | - | 27015 |
| Action: Source | - | 27015 |
| BrainBread | - | 27015 |
| BrainBread 2 | - | 27015 |
| Dystopia | - | 27015 |
| Empires Mod | - | 27015 |
| SourceForts Classic | - | 27015 |
| The Specialists | - | 27015 |
| Vampire Slayer | - | 27015 |
| Zombie Master: Reborn | - | 27015 |
| Zombie Panic! Source | - | 27015 |
| Pirates Vikings & Knights II | - | 27015 |

### Survival Games
| Game | Steam App ID | Default Port |
|------|--------------|--------------|
| Valheim | 896660 | 2456-2458 |
| Rust | 258550 | 28015 |
| 7 Days to Die | 294420 | 26900 |
| Project Zomboid | 380870 | 16261-16262 |
| Palworld | 2394010 | 8211 |
| Enshrouded | 2278520 | 15636-15637 |
| V Rising | 1604030 | 9876-9877 |
| Conan Exiles | 443030 | 7777 |
| ARK: Survival Ascended | 2430930 | 7777 |
| ARK: Survival Evolved | 376030 | 7777 |
| Don't Starve Together | 343050 | 10999-11000 |
| Sons of the Forest | 2465200 | 8766 |
| The Forest | 556450 | 8766 |
| Barotrauma | 1026340 | 27015 |
| SCUM | 3792580 | 7042 |
| Core Keeper | 1963720 | 27015 |
| Icarus | 2089300 | 17777 |
| Eco | 382310 | 3000 |
| The Isle | 412680 | 7777 |
| Day of Dragons | - | 7777 |
| Hurtworld | 405100 | 12871 |
| Vintage Story | - | 42420 |
| Craftopia | 1307550 | 6587 |
| Empyrion | 530870 | 30000 |
| CryoFall | 829590 | 6000 |
| Longvinter | 1628750 | 7777 |
| Nightingale | 1928980 | 7777 |
| The Front | 2285150 | 25010 |
| Myth of Empires | 1371580 | 12888 |
| Last Oasis | 920720 | 5555 |
| No One Survived | 1963370 | 7777 |
| Soulmask | 3040080 | 7777 |
| HumanitZ | 2740380 | 7777 |
| Survive the Nights | - | 7777 |
| Abiotic Factor | - | 7777 |
| Frozen Flame | - | 7777 |
| Dead Matter | - | 7777 |
| Deadpoly | - | 7777 |
| Night of the Dead | - | 7777 |
| Plains of Pain | - | 7777 |
| PixARK | - | 7777 |
| ASKA | - | 7777 |

### Military Simulation
| Game | Steam App ID | Default Port |
|------|--------------|--------------|
| DayZ | 223350 | 2302 |
| DayZ Experimental | - | 2302 |
| ARMA 3 | 233780 | 2302 |
| Arma Reforger | 1874900 | 2001 |
| Squad | 403240 | 7787 |
| Squad 44 (Post Scriptum) | 746200 | 10027 |
| Hell Let Loose | 1348460 | 7777 |
| Insurgency: Sandstorm | 581330 | 27102 |
| Insurgency | 237410 | 27015 |
| Day of Infamy | 462310 | 27015 |
| Operation: Harsh Doorstop | - | 7777 |
| Ground Branch | - | 7777 |
| Rising Storm 2: Vietnam | - | 7777 |

### Sandbox & Building
| Game | Steam App ID | Default Port |
|------|--------------|--------------|
| Minecraft Java | - | 25565 |
| Minecraft Bedrock | - | 19132 |
| PaperMC | - | 25565 |
| Velocity Proxy MC | - | 25577 |
| WaterfallMC | - | 25577 |
| Terraria | 105600 | 7777 |
| Starbound | 211820 | 21025 |
| OpenStarbound | - | 21025 |
| Factorio | 427520 | 34197 |
| Satisfactory | 1690800 | 7777 |
| Space Engineers | 298740 | 27016 |
| Stationeers | 544550 | 27500 |
| Avorion | 565060 | 27000 |
| Colony Survival | 366090 | 27016 |
| Rising World | 324080 | 4255 |
| Wurm Unlimited | 366220 | 3724 |
| Astroneer | 728470 | 8777 |
| OpenTTD | 1536610 | 3979 |
| Minetest | - | 30000 |
| Creativerse | - | 26900 |
| Cubic Odyssey | - | 7777 |
| Portal Knights | - | 7777 |
| Stonehearth | - | 7777 |
| Astro Colony | - | 7777 |

### Racing & Simulation
| Game | Steam App ID | Default Port |
|------|--------------|--------------|
| Assetto Corsa | 302550 | 9600 |
| Assetto Corsa Competizione | 805550 | 9231 |
| Euro Truck Simulator 2 | 227300 | 27015 |
| American Truck Simulator | 270880 | 27015 |
| BeamMP (BeamNG.drive) | - | 30814 |
| Project Cars | - | 9000 |
| Project Cars 2 | - | 9000 |
| MX Bikes | - | 7777 |

### Arena & Competitive
| Game | Steam App ID | Default Port |
|------|--------------|--------------|
| Quake III Arena | - | 27960 |
| Quake 2 | - | 27910 |
| Quake 4 | - | 28004 |
| Quake Live | 349090 | 27960 |
| Quake World | - | 27500 |
| Xonotic | - | 26000 |
| Warfork | - | 44400 |
| Unreal Tournament 99 | - | 7777 |
| Unreal Tournament 2004 | - | 7777 |
| Unreal Tournament 3 | - | 7777 |
| Chivalry: Medieval Warfare | 220070 | 7777 |
| MORDHAU | 629800 | 7777 |
| Pavlov VR | 622970 | 7777 |
| Teeworlds | - | 8303 |
| Soldat | - | 23073 |
| IOSoccer | - | 27015 |
| Blade Symphony | - | 27015 |
| Ballistic Overkill | - | 27015 |
| BATTALION: Legacy | - | 7777 |
| Double Action: Boogaloo | - | 27015 |
| StickyBots | - | 27015 |
| Base Defense | - | 27015 |
| Cube 2: Sauerbraten | - | 28785 |
| Tremulous | - | 30720 |
| OpenRA | - | 1234 |

### Co-op & Multiplayer
| Game | Steam App ID | Default Port |
|------|--------------|--------------|
| No More Room in Hell | 317670 | 27015 |
| Natural Selection | - | 27015 |
| Natural Selection 2 | 4940 | 27015 |
| NS2: Combat | - | 27015 |
| SCP: Secret Laboratory | 996560 | 7777 |
| SCP: Secret Laboratory ServerMod | - | 7777 |
| Tower Unite | 439660 | 27015 |
| Risk of Rain 2 | 1180760 | 27015 |
| Rimworld Together | - | 25555 |
| Path of Titans | - | 7777 |
| Mindustry | 1127400 | 6567 |
| Necesse | 14159 | 14159 |
| Nuclear Dawn | - | 27015 |
| Codename CURE | - | 27015 |
| HYPERCHARGE: Unboxed | - | 7777 |
| Alien Swarm: Reactive Drop | - | 27015 |
| Clone Hero | - | 14242 |
| Beasts of Bermuda | - | 7777 |

### Roleplay
| Game | Port |
|------|------|
| FiveM (GTA V) | 30120 |
| alt:V (GTA V) | 7788 |
| RedM (Red Dead) | 30120 |
| Multi Theft Auto | 22003 |
| RAGE:MP (GTA V) | 22005 |
| SA-MP | 7777 |
| Just Cause 2 MP | 7777 |
| Just Cause 3 MP | 7777 |
| Onset | 7777 |

### Classic Games
| Game | Steam App ID | Default Port |
|------|--------------|--------------|
| Killing Floor | 215360 | 7707 |
| Killing Floor 2 | 232130 | 7777 |
| Call of Duty | - | 28960 |
| Call of Duty 2 | - | 28960 |
| Call of Duty 4: MW | - | 28960 |
| Call of Duty: United Offensive | - | 28960 |
| Call of Duty: World at War | - | 28960 |
| Battlefield 1942 | - | 14567 |
| Battlefield: Vietnam | - | 15567 |
| Medal of Honor: Allied Assault | - | 12203 |
| Return to Castle Wolfenstein | - | 27960 |
| Wolfenstein: Enemy Territory | - | 27960 |
| ET: Legacy | - | 27960 |
| Soldier of Fortune 2 | - | 28910 |
| Unturned | 304930 | 27015 |
| Jedi Knight II: Jedi Outcast | - | 28070 |
| Jedi Academy | - | 29070 |
| Doom 2 | - | 5029 |
| Red Orchestra: Ostfront | - | 7757 |
| Blackwake | - | 25001 |
| Broke Protocol | - | 5557 |
| Reign of Kings | - | 7350 |

### Voice & Communication
| App | Ports |
|-----|-------|
| TeamSpeak 3 | 9987, 10011, 30033 |

### RPG & Tabletop
| Game | Port |
|------|------|
| Foundry VTT | 30000 |
| Sapiens | 7777 |
| Wartales | 7777 |
| Stellaris | 23243 |

### MMO Emulators
| Game | Port |
|------|------|
| WoW (AzerothCore) | 3724, 8085 |
| WoW (TrinityCore) | 3724, 8085 |
| SWGEmu | 44419 |
| SWG: Legends | 44419 |
| City of Heroes | 2104 |

### Server Management Panels
| Panel | Port |
|-------|------|
| Pterodactyl | 80/443 |
| Crafty Controller | 8443 |

---

## Web Deployer Features

The Proxmox web deployer (`proxmox-deployer/`) is a Flask application that provides:

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
open http://localhost:5555
```

Then:
1. Go to **Settings** and add your Proxmox connection
2. Browse **Servers** to see all 250+ games
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
│   │   └── game_servers.py   # All 250+ game definitions
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

- [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) - Steam dedicated server tool
- [Pterodactyl](https://pterodactyl.io/) - Game server panel
- [Docker Hub](https://hub.docker.com/) - Container images for many games

---

**Questions?** Open an issue or check the [docs](docs/) folder.
