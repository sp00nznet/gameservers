# Silverware Games

A collection of automated setup scripts for deploying dedicated game servers on Linux. Each script handles the complete installation process including SteamCMD setup, game file downloads, systemd service configuration, and server startup.

## Supported Games

| Game | Script | Steam App ID | Default Port |
|------|--------|--------------|--------------|
| Abiotic Factor | `abioticfactor/af-server-setup.sh` | 2857200 | 7777 |
| ARK: Survival Ascended | `arkasa/ark-server-setup.sh` | 2430930 | 7777 |
| Black Mesa | `blackmesa/bm-server-setup.sh` | 346680 | 27015 |
| City of Heroes | `cityofheroes/coh-server-setup.sh` | N/A (VM) | 2104 |
| Counter-Strike | `counterstrike/cs-server-setup.sh` | 90 | 27015 |
| Counter-Strike 2 | `counterstrike2/cs2-server-setup.sh` | 730 | 27015 |
| Half-Life Deathmatch | `hldm/hldm-server-setup.sh` | 90 | 27015 |
| Half-Life 2: Deathmatch | `hl2dm/hl2dm-server-setup.sh` | 232370 | 27015 |
| HumanitZ | `humanitz/humanitz-server-setup.sh` | 2372920 | 7777 |
| Killing Floor | `killingfloor/kf-server-setup.sh` | 215360 | 7707 |
| Killing Floor 2 | `killingfloor2/kf2-server-setup.sh` | 232130 | 7777 |
| Project Zomboid | `projectzomboid/pz-server-setup.sh` | 380870 | 16261 |
| San Andreas Multiplayer | `samp/samp-server-setup.sh` | N/A | 7777 |
| Starbound | `starbound/starbound-server-setup.sh` | 211820 | 21025 |
| Sven Co-op | `svencoop/svencoop-server-setup.sh` | 276060 | 27015 |
| Synergy | `synergy/synergy-server-setup.sh` | 17520 | 27015 |
| Team Fortress Classic | `tfc/tfc-server-setup.sh` | 20 | 27015 |
| Team Fortress 2 | `teamfortress2/tf2-server-setup.sh` | 232250 | 27015 |
| Unreal Tournament 99 | `ut99/ut99-server-setup.sh` | N/A | 7777 |
| Unreal Tournament 2004 | `ut2004/ut2004-server-setup.sh` | N/A | 7777 |

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
- Minimum 2GB RAM (4GB+ for Project Zomboid, 16GB+ for ARK ASA)
- SSD storage recommended (ARK ASA requires ~50GB+)

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

**GoldSrc Games (Half-Life DM, TFC):**
- 32-bit libraries on 64-bit systems
```bash
sudo apt-get install lib32gcc-s1
```

**Source Games (HL2DM, TF2, Synergy):**
- 32-bit libraries on 64-bit systems
- GSLT recommended for public server listing
- Get tokens at: https://steamcommunity.com/dev/managegameservers

**Project Zomboid:**
- Java 17 or higher
- 32-bit libraries on 64-bit systems
```bash
sudo apt-get install openjdk-17-jre-headless lib32gcc-s1
```

**ARK: Survival Ascended:**
- Minimum 16GB RAM (32GB recommended)
- 50GB+ free disk space
- Proton GE (automatically installed by script)
- wget for downloading Proton
```bash
sudo apt-get install wget
```

## Project Structure

```
gameservers/
├── setup.sh                      # Main interactive menu
├── README.md                     # This file
├── lib/
│   └── common.sh                 # Shared functions and utilities
├── abioticfactor/
│   └── af-server-setup.sh        # Abiotic Factor
├── arkasa/
│   └── ark-server-setup.sh       # ARK: Survival Ascended
├── blackmesa/
│   └── bm-server-setup.sh        # Black Mesa
├── cityofheroes/
│   └── coh-server-setup.sh       # City of Heroes (Windows VM)
├── counterstrike/
│   └── cs-server-setup.sh        # Counter-Strike
├── counterstrike2/
│   └── cs2-server-setup.sh       # Counter-Strike 2
├── hl2dm/
│   └── hl2dm-server-setup.sh     # Half-Life 2: Deathmatch
├── hldm/
│   └── hldm-server-setup.sh      # Half-Life Deathmatch
├── humanitz/
│   └── humanitz-server-setup.sh  # HumanitZ
├── killingfloor/
│   └── kf-server-setup.sh        # Killing Floor
├── killingfloor2/
│   └── kf2-server-setup.sh       # Killing Floor 2
├── projectzomboid/
│   └── pz-server-setup.sh        # Project Zomboid
├── samp/
│   └── samp-server-setup.sh      # San Andreas Multiplayer
├── starbound/
│   └── starbound-server-setup.sh # Starbound
├── svencoop/
│   └── svencoop-server-setup.sh  # Sven Co-op
├── synergy/
│   └── synergy-server-setup.sh   # Synergy
├── teamfortress2/
│   └── tf2-server-setup.sh       # Team Fortress 2
├── tfc/
│   └── tfc-server-setup.sh       # Team Fortress Classic
├── ut99/
│   └── ut99-server-setup.sh      # Unreal Tournament 99
└── ut2004/
    └── ut2004-server-setup.sh    # Unreal Tournament 2004
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
| Abiotic Factor | `/opt/afserver/` |
| ARK: Survival Ascended | `/opt/arkserver/` |
| Black Mesa | `/opt/bmserver/` |
| City of Heroes | `/opt/cohserver/` (VM + files) |
| Counter-Strike | `/opt/csserver/` |
| Counter-Strike 2 | `/opt/cs2server/` |
| Half-Life Deathmatch | `/opt/hldmserver/` |
| Half-Life 2: Deathmatch | `/opt/hl2dmserver/` |
| HumanitZ | `/opt/humanitzserver/` |
| Killing Floor | `/opt/kf1server/` |
| Killing Floor 2 | `/opt/kf2server/` |
| Project Zomboid | `/opt/pzserver/` |
| San Andreas Multiplayer | `/opt/sampserver/` |
| Starbound | `/opt/starboundserver/` |
| Sven Co-op | `/opt/svencoopserver/` |
| Synergy | `/opt/synergyserver/` |
| Team Fortress Classic | `/opt/tfcserver/` |
| Team Fortress 2 | `/opt/tf2server/` |
| Unreal Tournament 99 | `/opt/ut99server/` |
| Unreal Tournament 2004 | `/opt/ut2004server/` |
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
- `afserver` - Abiotic Factor
- `arkserver` - ARK: Survival Ascended
- `bmserver` - Black Mesa
- `cohserver` - City of Heroes (VM auto-start)
- `csserver` - Counter-Strike
- `cs2server` - Counter-Strike 2
- `hldmserver` - Half-Life Deathmatch
- `hl2dmserver` - Half-Life 2: Deathmatch
- `humanitzserver` - HumanitZ
- `kf1server` - Killing Floor
- `kf2server` - Killing Floor 2
- `pzserver` - Project Zomboid
- `sampserver` - San Andreas Multiplayer
- `starboundserver` - Starbound
- `svencoopserver` - Sven Co-op
- `synergyserver` - Synergy
- `tfcserver` - Team Fortress Classic
- `tf2server` - Team Fortress 2
- `ut99server` - Unreal Tournament 99
- `ut2004server` - Unreal Tournament 2004

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

### ARK: Survival Ascended

- **Config Location:** `/opt/arkserver/ShooterGame/Saved/Config/WindowsServer/`
- **Main Config:** `GameUserSettings.ini`
- **Game Rules:** `Game.ini`
- **Default Map:** TheIsland_WP
- **Max Players:** 70
- **Requires:** Proton GE for Windows compatibility

**Available Maps:**
- `TheIsland_WP` - The Island
- `ScorchedEarth_WP` - Scorched Earth
- `Aberration_WP` - Aberration
- `TheCenter_WP` - The Center
- `Ragnarok_WP` - Ragnarok
- `Extinction_WP` - Extinction

**Adding Mods:** Edit the `MODS` variable in the setup script:
```bash
sudo nano /home/user/gameservers/arkasa/ark-server-setup.sh
# Find and edit: MODS=""
# Example: MODS="928793,900062"
```

### Black Mesa

- **Config Location:** `/opt/bmserver/bms/cfg/server.cfg`
- **GSLT Config:** `/opt/bmserver/bmserver.conf`
- **Default Map:** dm_bounce
- **Max Players:** 16

**Available Maps:**
- `dm_bounce`, `dm_chopper`, `dm_crossfire`, `dm_gasworks`
- `dm_lambdabunker`, `dm_power`, `dm_rail`, `dm_stack`
- `dm_stalkyard`, `dm_subtransit`, `dm_undertow`

### City of Heroes

- **Type:** Windows VM (QEMU/KVM)
- **VM Location:** `/opt/cohserver/vm/`
- **Shared Files:** `/opt/cohserver/shared/`
- **Auth Port:** 2104
- **DB Port:** 2105
- **Game Ports:** 7000-7100
- **RAM Required:** 8GB minimum, 32GB recommended
- **Note:** Runs Ouroboros Volume 2 server in Windows VM

**Setup Overview:**
1. Script creates a Windows VM using QEMU/KVM
2. Download Windows Server Evaluation ISO
3. Download CoH files from OuroDev (torrent or CI site)
4. Install Windows in VM
5. Run Ouroboros self-installer batch files in VM

**VM Management:**
```bash
virsh start coh-windows-server    # Start VM
virsh shutdown coh-windows-server # Stop VM
virt-manager                      # GUI management
```

**Resources:**
- OuroDev Wiki: https://wiki.ourodev.com/
- Server Setup: https://wiki.ourodev.com/Volume_2_Server_Setup
- VM Guide: https://wiki.ourodev.com/Volume_2_VMs_%26_Self_Installer

### Counter-Strike

- **Config Location:** `/opt/csserver/cstrike/server.cfg`
- **Default Map:** de_dust2
- **Max Players:** 20
- **Note:** Classic tactical shooter; uses GoldSrc engine

### Counter-Strike 2

- **Config Location:** `/opt/cs2server/game/csgo/cfg/server.cfg`
- **GSLT Config:** `/opt/cs2server/cs2server.conf`
- **Default Map:** de_dust2
- **Max Players:** 20
- **Note:** GSLT is required for server to function properly

**Game Modes:**
- `game_type 0, game_mode 0` - Casual
- `game_type 0, game_mode 1` - Competitive
- `game_type 1, game_mode 0` - Arms Race
- `game_type 1, game_mode 1` - Demolition
- `game_type 1, game_mode 2` - Deathmatch

### Half-Life Deathmatch

- **Config Location:** `/opt/hldmserver/valve/server.cfg`
- **Default Map:** crossfire
- **Max Players:** 16

### Half-Life 2: Deathmatch

- **Config Location:** `/opt/hl2dmserver/hl2mp/cfg/server.cfg`
- **GSLT Config:** `/opt/hl2dmserver/hl2dmserver.conf`
- **Default Map:** dm_lockdown
- **Max Players:** 16

### Killing Floor

- **Config Location:** `/opt/kf1server/System/`
- **Default Map:** KF-WestLondon.rom
- **Max Players:** 6

### Killing Floor 2

- **Config Location:** `/opt/kf2server/KFGame/Config/`
- **Web Admin:** Port 8080 (configure in `KFWeb.ini`)
- **Default Map:** KF-BioticsLab
- **Max Players:** 6

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

### Synergy

- **Config Location:** `/opt/synergyserver/synergy/cfg/server.cfg`
- **Default Map:** d1_trainstation_01
- **Max Players:** 8
- **Note:** Co-op mod for Half-Life 2; players need HL2 to play

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

### Team Fortress Classic

- **Config Location:** `/opt/tfcserver/tfc/server.cfg`
- **Default Map:** 2fort
- **Max Players:** 24

### Abiotic Factor

- **Config Location:** Edit startup parameters in systemd service
- **Default Port:** 7777
- **Query Port:** 27015
- **Max Players:** 6
- **Note:** Co-op sci-fi survival crafting game

### HumanitZ

- **Config Location:** Edit startup parameters in systemd service
- **Default Port:** 7777
- **Query Port:** 27015
- **Max Players:** 16
- **Note:** Open-world zombie survival game

### San Andreas Multiplayer

- **Config Location:** `/opt/sampserver/server.cfg`
- **Default Port:** 7777
- **Max Players:** 50
- **Gamemodes:** Located in `/opt/sampserver/gamemodes/`
- **Note:** GTA San Andreas multiplayer mod

### Starbound

- **Config Location:** `/opt/starboundserver/storage/starbound_server.config`
- **Default Port:** 21025
- **Max Players:** 8
- **Note:** Sandbox exploration adventure

### Sven Co-op

- **Config Location:** `/opt/svencoopserver/svencoop/server.cfg`
- **Default Map:** svencoop1
- **Default Port:** 27015
- **Max Players:** 12
- **Note:** Half-Life co-op mod

### Unreal Tournament 99

- **Config Location:** `/opt/ut99server/System/UnrealTournament.ini`
- **Default Map:** DM-Deck16][
- **Default Port:** 7777
- **Query Port:** 7778
- **Max Players:** 16
- **Note:** Requires original game files

**Game Modes:**
- Deathmatch: `Botpack.DeathMatchPlus`
- Team DM: `Botpack.TeamGamePlus`
- CTF: `Botpack.CTFGame`
- Assault: `Botpack.Assault`
- Domination: `Botpack.Domination`

### Unreal Tournament 2004

- **Config Location:** `/opt/ut2004server/System/UT2004.ini`
- **Default Map:** DM-Rankin
- **Default Port:** 7777
- **Query Port:** 7778
- **Web Admin Port:** 8075
- **Max Players:** 16
- **Note:** Requires original game files

**Game Modes:**
- Deathmatch: `XGame.xDeathMatch`
- Team DM: `XGame.xTeamGame`
- CTF: `XGame.xCTFGame`
- Bombing Run: `XGame.xBombingRun`
- Onslaught: `Onslaught.ONSOnslaughtGame`
- Assault: `UT2k4Assault.UT2k4AssaultGame`

## Firewall Configuration

If using UFW (Uncomplicated Firewall):

```bash
# ARK: Survival Ascended
sudo ufw allow 7777/udp    # Game port
sudo ufw allow 27015/udp   # Query port
sudo ufw allow 27020/tcp   # RCON

# Black Mesa
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp

# City of Heroes (forward to VM)
sudo ufw allow 2104/tcp    # Auth server
sudo ufw allow 2105/tcp    # DB server
sudo ufw allow 7000:7100/udp  # Game ports
sudo ufw allow 8080/tcp    # Web admin

# Counter-Strike
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp

# Counter-Strike 2
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp
sudo ufw allow 27020/udp   # SourceTV

# Half-Life Deathmatch
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp

# Half-Life 2: Deathmatch
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp

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

# Project Zomboid
sudo ufw allow 16261/udp
sudo ufw allow 16262/udp
sudo ufw allow 27015/tcp   # RCON

# Synergy
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp

# Team Fortress 2
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp

# Team Fortress Classic
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp

# Abiotic Factor
sudo ufw allow 7777/udp
sudo ufw allow 27015/udp   # Query port

# HumanitZ
sudo ufw allow 7777/udp
sudo ufw allow 27015/udp   # Query port

# San Andreas Multiplayer
sudo ufw allow 7777/udp

# Starbound
sudo ufw allow 21025/tcp

# Sven Co-op
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp

# Unreal Tournament 99
sudo ufw allow 7777/udp
sudo ufw allow 7778/udp    # Query port

# Unreal Tournament 2004
sudo ufw allow 7777/udp
sudo ufw allow 7778/udp    # Query port
sudo ufw allow 8075/tcp    # Web admin
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
