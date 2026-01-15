# Silverware Game Servers

Automated setup scripts and web-based deployer for dedicated game servers on Linux and Proxmox.

## Quick Start

### Option 1: Web-Based Deployer (Recommended)

Deploy game servers to Proxmox with a modern web interface:

```bash
cd proxmox-deployer
./start.sh dev
# Access at http://localhost:5000
```

### Option 2: Interactive Setup Script

Run servers directly on a single host:

```bash
git clone https://github.com/yourusername/gameservers.git
cd gameservers
sudo ./setup.sh
```

## Supported Games (40+)

### Source Engine
| Game | Port | Game | Port |
|------|------|------|------|
| Counter-Strike 1.6 | 27015 | Counter-Strike 2 | 27015 |
| Team Fortress 2 | 27015 | Team Fortress Classic | 27015 |
| Half-Life DM | 27015 | Half-Life 2: DM | 27015 |
| Black Mesa | 27015 | Sven Co-op | 27015 |
| Synergy | 27015 | Garry's Mod | 27015 |
| Left 4 Dead 2 | 27015 | | |

### Survival Games
| Game | Port | Game | Port |
|------|------|------|------|
| Valheim | 2456-2458 | Rust | 28015 |
| 7 Days to Die | 26900 | Project Zomboid | 16261 |
| Palworld | 8211 | Enshrouded | 15636 |
| V Rising | 9876 | Conan Exiles | 7777 |
| ARK: Survival Ascended | 7777 | Abiotic Factor | 7777 |
| HumanitZ | 7777 | Don't Starve Together | 10999 |

### Sandbox & Building
| Game | Port | Game | Port |
|------|------|------|------|
| Minecraft Java | 25565 | Minecraft Bedrock | 19132 |
| Terraria | 7777 | Starbound | 21025 |
| Factorio | 34197 | Satisfactory | 7777 |

### Classic Games
| Game | Port | Game | Port |
|------|------|------|------|
| Killing Floor | 7707 | Killing Floor 2 | 7777 |
| UT99 | 7777 | UT2004 | 7777 |
| SA-MP | 7777 | Quake III Arena | 27960 |

### MMO Emulators
| Game | Port | Game | Port |
|------|------|------|------|
| WoW (AzerothCore) | 3724 | SWGEmu | 44419 |
| City of Heroes | 2104 | | |

### Server Management
| Panel | Port |
|-------|------|
| Pterodactyl | 80/443 |
| Crafty Controller | 8443 |
| AMP (CubeCoders) | 8080 |
| Foundry VTT | 30000 |

## Deployment Options

### 1. Web-Based Deployer (New!)

A Flask-based web application for one-click game server deployment to Proxmox:

- **40+ pre-configured game servers**
- **Dark-themed responsive UI**
- **Credentials vault** for Steam tokens and passwords
- **Deployment history** with status tracking
- **Multi-Proxmox support**

```bash
cd proxmox-deployer
./start.sh docker  # Run with Docker
```

See [proxmox-deployer/README.md](proxmox-deployer/README.md) for details.

### 2. Single Host (Traditional)

Run all servers on one machine using Docker containers or systemd services:

```bash
sudo ./setup.sh              # Interactive menu
sudo ./setup.sh --list       # List servers
sudo ./setup.sh --status     # Check running servers
```

### 3. Proxmox IaC (Advanced)

Deploy per-game-type VMs using Terraform and Packer. See [infrastructure/](infrastructure/) for details.

## Requirements

- **Linux** (Debian/Ubuntu recommended)
- **Root access** (sudo)
- **2GB+ RAM** (16GB+ for ARK, WoW, etc.)

For web deployer:
- **Python 3.8+** or **Docker**
- **Proxmox VE 7.0+** or **8.0+**

## Service Management

```bash
sudo systemctl start <service>    # Start
sudo systemctl stop <service>     # Stop
sudo systemctl status <service>   # Status
sudo systemctl restart <service>  # Restart
```

**Service names:** `tf2server`, `csserver`, `cs2server`, `pzserver`, `arkserver`, `valheim`, etc.

## Console Access

```bash
sudo screen -r <service>    # Attach to console
# Ctrl+A, D                 # Detach (keep running)
```

## Documentation

| Document | Description |
|----------|-------------|
| [Web Deployer](proxmox-deployer/README.md) | Proxmox web-based deployment UI |
| [Game Configuration](docs/game-configuration.md) | Server settings for each game |
| [Firewall Rules](docs/firewall.md) | Port configuration |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and fixes |
| [Infrastructure](infrastructure/README.md) | Terraform/Packer deployment |

## Project Structure

```
gameservers/
├── setup.sh              # Main interactive menu
├── lib/common.sh         # Shared functions
├── proxmox-deployer/     # Web-based deployment UI (NEW)
│   ├── app/              # Flask application
│   ├── start.sh          # Startup script
│   └── README.md         # Deployer documentation
├── docs/                 # Documentation
├── infrastructure/       # Terraform/Packer (optional)
└── <game>/               # Game-specific setup scripts
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add game directory with setup script
4. Update `setup.sh` menu and game_servers.py
5. Submit pull request

## License

MIT License
