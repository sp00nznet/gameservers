# Silverware Game Servers

Automated setup scripts for deploying dedicated game servers on Linux.

## Quick Start

```bash
git clone https://github.com/yourusername/gameservers.git
cd gameservers
sudo ./setup.sh
```

## Supported Games

| Game | Port | Game | Port |
|------|------|------|------|
| Counter-Strike | 27015 | Counter-Strike 2 | 27015 |
| Team Fortress 2 | 27015 | Team Fortress Classic | 27015 |
| Half-Life DM | 27015 | Half-Life 2: DM | 27015 |
| Black Mesa | 27015 | Sven Co-op | 27015 |
| Synergy | 27015 | Project Zomboid | 16261 |
| Killing Floor | 7707 | Killing Floor 2 | 7777 |
| ARK: Survival Ascended | 7777 | Abiotic Factor | 7777 |
| HumanitZ | 7777 | Starbound | 21025 |
| UT99 | 7777 | UT2004 | 7777 |
| SA-MP | 7777 | City of Heroes | 2104 |
| SWGEmu | 44419 | WoW (AzerothCore) | 3724 |

## Requirements

- Linux (Debian/Ubuntu recommended)
- Root access (sudo)
- 2GB+ RAM (16GB+ for ARK)

```bash
sudo apt-get install curl tar screen dialog
```

## Usage

```bash
sudo ./setup.sh              # Interactive menu
sudo ./setup.sh --list       # List servers
sudo ./setup.sh --status     # Check running servers
sudo ./setup.sh --monitor    # Server monitoring
```

## Service Management

```bash
sudo systemctl start <service>    # Start
sudo systemctl stop <service>     # Stop
sudo systemctl status <service>   # Status
sudo systemctl restart <service>  # Restart
```

**Service names:** `tf2server`, `csserver`, `cs2server`, `pzserver`, `arkserver`, etc.

## Console Access

```bash
sudo screen -r <service>    # Attach to console
# Ctrl+A, D                 # Detach (keep running)
```

## Deployment Options

### Single Host (Default)
Run all servers on one machine using Docker containers or systemd services.

### Proxmox Cluster
Deploy per-game-type VMs using Terraform. See [infrastructure/](infrastructure/) for details.

## Documentation

| Document | Description |
|----------|-------------|
| [Game Configuration](docs/game-configuration.md) | Server settings for each game |
| [Firewall Rules](docs/firewall.md) | Port configuration |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and fixes |
| [Infrastructure](infrastructure/README.md) | Proxmox/Terraform deployment |

## Project Structure

```
gameservers/
├── setup.sh           # Main menu
├── lib/common.sh      # Shared functions
├── docs/              # Documentation
├── infrastructure/    # Terraform/Packer (optional)
└── <game>/            # Game-specific setup scripts
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add game directory with setup script
4. Update `setup.sh` menu
5. Submit pull request

## License

MIT License
