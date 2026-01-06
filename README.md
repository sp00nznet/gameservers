# Silverware Game Servers

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║    ███████╗██╗██╗    ██╗   ██╗███████╗██████╗ ██╗    ██╗ █████╗ ██████╗ ███████╗║
║    ██╔════╝██║██║    ██║   ██║██╔════╝██╔══██╗██║    ██║██╔══██╗██╔══██╗██╔════╝║
║    ███████╗██║██║    ██║   ██║█████╗  ██████╔╝██║ █╗ ██║███████║██████╔╝█████╗  ║
║    ╚════██║██║██║    ╚██╗ ██╔╝██╔══╝  ██╔══██╗██║███╗██║██╔══██║██╔══██╗██╔══╝  ║
║    ███████║██║███████╗╚████╔╝ ███████╗██║  ██║╚███╔███╔╝██║  ██║██║  ██║███████╗║
║    ╚══════╝╚═╝╚══════╝ ╚═══╝  ╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝║
║                                                                               ║
║         ██████╗  █████╗ ███╗   ███╗███████╗    ███████╗███████╗██████╗ ██╗   ██╗║
║        ██╔════╝ ██╔══██╗████╗ ████║██╔════╝    ██╔════╝██╔════╝██╔══██╗██║   ██║║
║        ██║  ███╗███████║██╔████╔██║█████╗      ███████╗█████╗  ██████╔╝██║   ██║║
║        ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝      ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝║
║        ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗    ███████║███████╗██║  ██║ ╚████╔╝ ║
║         ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ║
║                                                                               ║
║                    🎮  Automated Dedicated Server Deployment  🎮               ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

A collection of automated setup scripts for deploying dedicated game servers on Linux. Each script handles the complete installation process including SteamCMD setup, game file downloads, systemd service configuration, and server startup.

## Supported Games

| Game | Script | Steam App ID | Default Port |
|------|--------|--------------|--------------|
| Killing Floor | `killingfloor/kf-server-setup.sh` | 215360 | 7707 |
| Killing Floor 2 | `killingfloor2/kf2-server-setup.sh` | 232130 | 7777 |
| Team Fortress 2 | `teamfortress2/tf2-server-setup.sh` | 232250 | 27015 |
| Project Zomboid | `projectzomboid/pz-server-setup.sh` | 380870 | 16261 |

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/gameservers.git
cd gameservers

# Run the interactive setup menu
sudo ./setup.sh
```

## Requirements

### System Requirements
- Linux (Debian/Ubuntu recommended)
- Root access (sudo)
- Minimum 2GB RAM (4GB+ recommended for Project Zomboid)
- SSD storage recommended for faster load times

### Dependencies
The scripts will check for these dependencies automatically:

- `curl` - For downloading files
- `tar` - For extracting archives
- `screen` - For running servers in detached sessions
- `systemctl` - For service management (systemd)
- `dialog` - Optional, for enhanced menu interface

Install all dependencies on Debian/Ubuntu:
```bash
sudo apt-get update
sudo apt-get install curl tar screen dialog
```

### Game-Specific Requirements

**Team Fortress 2:**
- Steam Game Server Login Token (GSLT) for public server listing
- Get your token at: https://steamcommunity.com/dev/managegameservers

**Project Zomboid:**
- Java 17 or higher
- 32-bit libraries on 64-bit systems
```bash
sudo apt-get install openjdk-17-jre-headless lib32gcc-s1
```

## Project Structure

```
gameservers/
├── setup.sh                      # Main interactive menu
├── README.md                     # This file
├── lib/
│   └── common.sh                 # Shared functions and utilities
├── killingfloor/
│   └── kf-server-setup.sh        # Killing Floor 1 setup
├── killingfloor2/
│   └── kf2-server-setup.sh       # Killing Floor 2 setup
├── teamfortress2/
│   └── tf2-server-setup.sh       # Team Fortress 2 setup
└── projectzomboid/
    └── pz-server-setup.sh        # Project Zomboid setup
```

## How It Works

### Main Menu (`setup.sh`)

The main entry point provides an interactive menu to select which game server to install:

```bash
sudo ./setup.sh              # Interactive menu (uses dialog if available)
sudo ./setup.sh --text       # Force text-based menu
sudo ./setup.sh --list       # List available servers
sudo ./setup.sh --help       # Show help
```

Features:
- ASCII art banner
- Supports both `dialog` (ncurses) and plain text menus
- Command-line options for scripting
- Session logging to `/var/log/gameservers/setup.log`

### Shared Library (`lib/common.sh`)

All scripts source this library which provides:

**Logging Functions:**
- `log_info "message"` - Blue informational messages
- `log_success "message"` - Green success messages
- `log_warn "message"` - Yellow warning messages
- `log_error "message"` - Red error messages
- `log_step 1 5 "message"` - Step progress indicator [1/5]
- `log_header "title"` - Section headers

**Utility Functions:**
- `check_root` - Verify running as root
- `check_dependencies` - Verify required commands exist
- `install_steamcmd` - Download and install SteamCMD
- `run_steamcmd` - Run SteamCMD to download/update games
- `create_systemd_service` - Create a systemd unit file
- `enable_service` - Enable and start a systemd service
- `confirm` - Interactive yes/no prompt

**Color Variables:**
- `RED`, `GREEN`, `YELLOW`, `BLUE`, `CYAN`, `MAGENTA`, `WHITE`
- `BOLD`, `DIM`, `RESET`

### Game Server Scripts

Each game server script follows the same pattern:

1. **Configuration Section** - All settings defined as variables at the top
2. **Prerequisites Check** - Verify dependencies are installed
3. **SteamCMD Setup** - Install SteamCMD if not present
4. **Game Download** - Download/update game files via SteamCMD
5. **Server Configuration** - Create config files (game-specific)
6. **Service Creation** - Generate systemd service file
7. **Service Start** - Enable and start the server
8. **Summary** - Display installation summary and useful commands

## Installation Directories

| Component | Location |
|-----------|----------|
| SteamCMD | `/opt/steamcmd/` |
| Killing Floor | `/opt/kf1server/` |
| Killing Floor 2 | `/opt/kf2server/` |
| Team Fortress 2 | `/opt/tf2server/` |
| Project Zomboid | `/opt/pzserver/` |
| Log Files | `/var/log/gameservers/` |

## Service Management

All servers are managed via systemd. Common commands:

```bash
# Start a server
sudo systemctl start <service-name>

# Stop a server
sudo systemctl stop <service-name>

# Restart a server
sudo systemctl restart <service-name>

# Check server status
sudo systemctl status <service-name>

# Enable auto-start on boot
sudo systemctl enable <service-name>

# Disable auto-start
sudo systemctl disable <service-name>

# View service logs
sudo journalctl -u <service-name> -f
```

Service names:
- `kf1server` - Killing Floor
- `kf2server` - Killing Floor 2
- `tf2server` - Team Fortress 2
- `pzserver` - Project Zomboid

## Console Access

All servers run inside `screen` sessions. To access the server console:

```bash
# Attach to screen session
sudo screen -r <session-name>

# Detach from screen (without stopping server)
# Press: Ctrl+A, then D

# List running screen sessions
screen -ls
```

Session names match the service names (e.g., `kf1server`, `tf2server`).

## Configuration

### Killing Floor

- **Config Location:** `/opt/kf1server/System/`
- **Default Map:** KF-WestLondon.rom
- **Max Players:** 6

### Killing Floor 2

- **Config Location:** `/opt/kf2server/KFGame/Config/`
- **Web Admin:** Port 8080 (configure in `KFWeb.ini`)
- **Default Map:** KF-BioticsLab
- **Max Players:** 6

### Team Fortress 2

- **Config Location:** `/opt/tf2server/tf/cfg/server.cfg`
- **GSLT Config:** `/opt/tf2server/tf2server.conf`
- **Default Map:** ctf_2fort
- **Max Players:** 24

To make the server public, add your GSLT:
```bash
# Edit the config file
sudo nano /opt/tf2server/tf2server.conf

# Add your token
STEAM_GSLT_TOKEN="your_token_here"

# Restart the server
sudo systemctl restart tf2server
```

### Project Zomboid

- **Config Location:** `/home/pzuser/Zomboid/Server/`
- **Main Config:** `pzserver.ini`
- **Sandbox Settings:** `pzserver_SandboxVars.lua`
- **Default Map:** Muldraugh, KY
- **Max Players:** 16
- **Memory:** 2GB min, 4GB max (adjustable in script)

**Important:** Change default passwords after installation:
```bash
sudo nano /home/pzuser/Zomboid/Server/pzserver.ini
```

## Firewall Configuration

If using UFW (Uncomplicated Firewall):

```bash
# Killing Floor
sudo ufw allow 7707/udp
sudo ufw allow 7708/udp
sudo ufw allow 7717/udp
sudo ufw allow 28852/tcp
sudo ufw allow 28852/udp

# Killing Floor 2
sudo ufw allow 7777/udp
sudo ufw allow 27015/udp
sudo ufw allow 8080/tcp    # Web admin

# Team Fortress 2
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp

# Project Zomboid
sudo ufw allow 16261/udp
sudo ufw allow 16262/udp
sudo ufw allow 27015/tcp   # RCON
```

## Logging

All setup operations are logged to `/var/log/gameservers/setup.log`:

```bash
# View recent logs
tail -f /var/log/gameservers/setup.log

# Search logs
grep "ERROR" /var/log/gameservers/setup.log
```

Log format:
```
[2024-01-15 14:30:22] [INFO] Starting server installation
[2024-01-15 14:30:23] [SUCCESS] SteamCMD installed successfully
[2024-01-15 14:35:45] [ERROR] Failed to download game files
```

## Troubleshooting

### Server won't start

1. Check the systemd status:
   ```bash
   sudo systemctl status <service-name>
   ```

2. Check the journal logs:
   ```bash
   sudo journalctl -u <service-name> -n 50
   ```

3. Try running manually:
   ```bash
   cd /opt/<server-dir>
   ./start-server.sh
   ```

### SteamCMD download fails

1. Verify network connectivity
2. Check disk space: `df -h`
3. Try running SteamCMD manually:
   ```bash
   /opt/steamcmd/steamcmd.sh +login anonymous +quit
   ```

### Permission errors

Ensure proper ownership:
```bash
sudo chown -R root:root /opt/<server-dir>
# For Project Zomboid:
sudo chown -R pzuser:pzuser /opt/pzserver
```

### Server not appearing in browser

- **TF2:** Verify GSLT token is configured correctly
- **All:** Check firewall rules allow the required ports
- **All:** Verify the server is actually running: `screen -ls`

## Updating Game Servers

To update a game server to the latest version:

```bash
# Stop the server
sudo systemctl stop <service-name>

# Run SteamCMD update
/opt/steamcmd/steamcmd.sh +force_install_dir /opt/<server-dir> +login anonymous +app_update <app-id> validate +quit

# Start the server
sudo systemctl start <service-name>
```

## Uninstallation

To completely remove a game server:

```bash
# Stop and disable the service
sudo systemctl stop <service-name>
sudo systemctl disable <service-name>

# Remove the service file
sudo rm /etc/systemd/system/<service-name>.service
sudo systemctl daemon-reload

# Remove game files
sudo rm -rf /opt/<server-dir>
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

When adding a new game server:
1. Create a new directory: `gamename/`
2. Create the setup script following the existing pattern
3. Add the game to `setup.sh` menu options
4. Update this README

## License

MIT License - See LICENSE file for details.
