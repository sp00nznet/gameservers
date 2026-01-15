# Game Server Configuration Guide

Detailed configuration options for each supported game server.

## Table of Contents

### Source Engine
- [Counter-Strike 1.6](#counter-strike-16)
- [Counter-Strike 2](#counter-strike-2)
- [Team Fortress 2](#team-fortress-2)
- [Team Fortress Classic](#team-fortress-classic)
- [Half-Life Deathmatch](#half-life-deathmatch)
- [Half-Life 2: Deathmatch](#half-life-2-deathmatch)
- [Black Mesa](#black-mesa)
- [Sven Co-op](#sven-co-op)
- [Synergy](#synergy)
- [Garry's Mod](#garrys-mod)
- [Left 4 Dead 2](#left-4-dead-2)

### Survival Games
- [Valheim](#valheim)
- [Rust](#rust)
- [7 Days to Die](#7-days-to-die)
- [Project Zomboid](#project-zomboid)
- [Palworld](#palworld)
- [Enshrouded](#enshrouded)
- [V Rising](#v-rising)
- [Conan Exiles](#conan-exiles)
- [ARK: Survival Ascended](#ark-survival-ascended)
- [Abiotic Factor](#abiotic-factor)
- [HumanitZ](#humanitz)
- [Don't Starve Together](#dont-starve-together)

### Sandbox & Building
- [Minecraft Java](#minecraft-java)
- [Minecraft Bedrock](#minecraft-bedrock)
- [Terraria](#terraria)
- [Starbound](#starbound)
- [Factorio](#factorio)
- [Satisfactory](#satisfactory)

### Classic Games
- [Killing Floor](#killing-floor)
- [Killing Floor 2](#killing-floor-2)
- [Unreal Tournament 99](#unreal-tournament-99)
- [Unreal Tournament 2004](#unreal-tournament-2004)
- [San Andreas Multiplayer](#san-andreas-multiplayer)
- [Quake III Arena](#quake-iii-arena)

### MMO Emulators
- [World of Warcraft (AzerothCore)](#world-of-warcraft-azerothcore)
- [Star Wars Galaxies EMU](#star-wars-galaxies-emu)
- [City of Heroes](#city-of-heroes)

### Server Management
- [Pterodactyl Panel](#pterodactyl-panel)
- [Crafty Controller](#crafty-controller)
- [Foundry VTT](#foundry-vtt)

---

## Source Engine Games

### Counter-Strike 1.6

| Setting | Value |
|---------|-------|
| Config Location | `/opt/csserver/cstrike/server.cfg` |
| Default Map | de_dust2 |
| Max Players | 32 |
| Port | 27015 (UDP/TCP) |

---

### Counter-Strike 2

| Setting | Value |
|---------|-------|
| Config Location | `/opt/cs2server/game/csgo/cfg/server.cfg` |
| GSLT Config | `/opt/cs2server/cs2server.conf` |
| Default Map | de_dust2 |
| Max Players | 16 |
| Port | 27015 (UDP/TCP) |

**Game Modes:**
| Mode | game_type | game_mode |
|------|-----------|-----------|
| Casual | 0 | 0 |
| Competitive | 0 | 1 |
| Arms Race | 1 | 0 |
| Demolition | 1 | 1 |
| Deathmatch | 1 | 2 |

---

### Team Fortress 2

| Setting | Value |
|---------|-------|
| Config Location | `/opt/tf2server/tf/cfg/server.cfg` |
| GSLT Config | `/opt/tf2server/tf2server.conf` |
| Default Map | ctf_2fort |
| Max Players | 24 |
| Port | 27015 (UDP/TCP) |

---

### Team Fortress Classic

| Setting | Value |
|---------|-------|
| Config Location | `/opt/tfcserver/tfc/server.cfg` |
| Default Map | 2fort |
| Max Players | 24 |
| Port | 27015 (UDP/TCP) |

---

### Half-Life Deathmatch

| Setting | Value |
|---------|-------|
| Config Location | `/opt/hldmserver/valve/server.cfg` |
| Default Map | crossfire |
| Max Players | 16 |
| Port | 27015 (UDP/TCP) |

---

### Half-Life 2: Deathmatch

| Setting | Value |
|---------|-------|
| Config Location | `/opt/hl2dmserver/hl2mp/cfg/server.cfg` |
| GSLT Config | `/opt/hl2dmserver/hl2dmserver.conf` |
| Default Map | dm_lockdown |
| Max Players | 16 |
| Port | 27015 (UDP/TCP) |

---

### Black Mesa

| Setting | Value |
|---------|-------|
| Config Location | `/opt/bmserver/bms/cfg/server.cfg` |
| GSLT Config | `/opt/bmserver/bmserver.conf` |
| Default Map | dm_bounce |
| Max Players | 16 |
| Port | 27015 (UDP/TCP) |

**Available Maps:**
`dm_bounce`, `dm_chopper`, `dm_crossfire`, `dm_gasworks`, `dm_lambdabunker`, `dm_power`, `dm_rail`, `dm_stack`, `dm_stalkyard`, `dm_subtransit`, `dm_undertow`

---

### Sven Co-op

| Setting | Value |
|---------|-------|
| Config Location | `/opt/svencoopserver/svencoop/server.cfg` |
| Default Map | svencoop1 |
| Max Players | 12 |
| Port | 27015 (UDP/TCP) |

---

### Synergy

| Setting | Value |
|---------|-------|
| Config Location | `/opt/synergyserver/synergy/cfg/server.cfg` |
| Default Map | d1_trainstation_01 |
| Max Players | 8 |
| Port | 27015 (UDP/TCP) |

---

### Garry's Mod

| Setting | Value |
|---------|-------|
| Config Location | `/opt/gmodserver/garrysmod/cfg/server.cfg` |
| GSLT Required | Yes |
| Default Map | gm_construct |
| Max Players | 24 |
| Ports | 27015, 27005 (UDP/TCP) |

**Game Modes:** sandbox, terrortown, prophunt, darkrp, murder

---

### Left 4 Dead 2

| Setting | Value |
|---------|-------|
| Config Location | `/opt/l4d2server/left4dead2/cfg/server.cfg` |
| Default Map | c1m1_hotel |
| Max Players | 8 |
| Port | 27015 (UDP/TCP) |

---

## Survival Games

### Valheim

| Setting | Value |
|---------|-------|
| Docker Image | `lloesche/valheim-server` |
| Default World | Dedicated |
| Max Players | 10 |
| Ports | 2456-2458 (UDP) |
| Password Required | Yes (min 5 chars) |

**Environment Variables:**
```bash
SERVER_NAME="My Valheim Server"
SERVER_PASSWORD="mypassword"
WORLD_NAME="Dedicated"
SERVER_PUBLIC=0
```

---

### Rust

| Setting | Value |
|---------|-------|
| Docker Image | `didstopia/rust-server` |
| World Size | 3500 (default) |
| Max Players | 50 |
| Ports | 28015 (UDP), 28016 (TCP), 28082 (TCP) |

---

### 7 Days to Die

| Setting | Value |
|---------|-------|
| Docker Image | `vinanrra/7dtd-server` |
| Difficulty | 0-5 (default: 2) |
| Max Players | 8 |
| Ports | 26900-26902 (UDP/TCP) |

---

### Project Zomboid

| Setting | Value |
|---------|-------|
| Config Location | `/home/pzuser/Zomboid/Server/` |
| Main Config | `pzserver.ini` |
| Sandbox Settings | `pzserver_SandboxVars.lua` |
| Default Map | Muldraugh, KY |
| Max Players | 16 |
| Ports | 16261-16262 (UDP) |

**Important:** Change default passwords after installation.

---

### Palworld

| Setting | Value |
|---------|-------|
| Docker Image | `thijsvanloef/palworld-server-docker` |
| Max Players | 32 |
| Ports | 8211 (UDP), 27015 (UDP) |

---

### Enshrouded

| Setting | Value |
|---------|-------|
| Docker Image | `sknnr/enshrouded-dedicated-server` |
| Max Players | 16 |
| Ports | 15636-15637 (UDP) |

---

### V Rising

| Setting | Value |
|---------|-------|
| Docker Image | `trueosiris/vrising` |
| Max Players | 40 |
| Ports | 9876-9877 (UDP) |
| Game Presets | StandardPvP, StandardPvE, HardcorePvP |

---

### Conan Exiles

| Setting | Value |
|---------|-------|
| Docker Image | `alinmear/docker-conanexiles` |
| Max Players | 40 |
| Ports | 7777-7778 (UDP), 27015 (UDP) |

---

### ARK: Survival Ascended

| Setting | Value |
|---------|-------|
| Config Location | `/opt/arkserver/ShooterGame/Saved/Config/WindowsServer/` |
| Main Config | `GameUserSettings.ini` |
| Game Rules | `Game.ini` |
| Default Map | TheIsland_WP |
| Max Players | 70 |
| Ports | 7777-7778 (UDP), 27015 (UDP) |
| Deployment | VM (Proton) |

**Available Maps:**
- `TheIsland_WP`, `ScorchedEarth_WP`, `Aberration_WP`
- `TheCenter_WP`, `Ragnarok_WP`, `Extinction_WP`

---

### Abiotic Factor

| Setting | Value |
|---------|-------|
| Default Port | 7777 (UDP) |
| Query Port | 27015 (UDP) |
| Max Players | 6 |

---

### HumanitZ

| Setting | Value |
|---------|-------|
| Default Port | 7777 (UDP) |
| Query Port | 27015 (UDP) |
| Max Players | 32 |

---

### Don't Starve Together

| Setting | Value |
|---------|-------|
| Docker Image | `jamesits/dst-server` |
| Max Players | Varies |
| Ports | 10999, 10998 (UDP) |
| Token Required | Yes (Klei account) |

---

## Sandbox & Building

### Minecraft Java

| Setting | Value |
|---------|-------|
| Docker Image | `itzg/minecraft-server` |
| Server Types | VANILLA, PAPER, FORGE, FABRIC |
| Max Players | 20 |
| Ports | 25565 (TCP), 25575 (TCP RCON) |

**Environment Variables:**
```bash
EULA=TRUE
TYPE=PAPER
VERSION=LATEST
MEMORY=4G
```

---

### Minecraft Bedrock

| Setting | Value |
|---------|-------|
| Docker Image | `itzg/minecraft-bedrock-server` |
| Max Players | 10 |
| Port | 19132 (UDP) |

---

### Terraria

| Setting | Value |
|---------|-------|
| Docker Image | `ryshe/terraria` |
| Max Players | 8 |
| Port | 7777 (TCP) |
| Difficulty | 0=classic, 1=expert, 2=master, 3=journey |

---

### Starbound

| Setting | Value |
|---------|-------|
| Config Location | `/opt/starboundserver/storage/starbound_server.config` |
| Max Players | 8 |
| Port | 21025 (TCP) |

---

### Factorio

| Setting | Value |
|---------|-------|
| Docker Image | `factoriotools/factorio` |
| Port | 34197 (UDP) |

---

### Satisfactory

| Setting | Value |
|---------|-------|
| Docker Image | `wolveix/satisfactory-server` |
| Max Players | 4 |
| Ports | 7777 (UDP), 15000 (UDP), 15777 (UDP) |

---

## Classic Games

### Killing Floor

| Setting | Value |
|---------|-------|
| Config Location | `/opt/kf1server/System/` |
| Default Map | KF-WestLondon.rom |
| Max Players | 6 |
| Ports | 7707-7708, 7717, 28852 (UDP) |

---

### Killing Floor 2

| Setting | Value |
|---------|-------|
| Config Location | `/opt/kf2server/KFGame/Config/` |
| Web Admin | Port 8080 |
| Default Map | KF-BioticsLab |
| Max Players | 6 |
| Ports | 7777 (UDP), 27015 (UDP), 8080 (TCP), 20560 (UDP) |
| Difficulty | 0=Normal, 1=Hard, 2=Suicidal, 3=HOE |

---

### Unreal Tournament 99

| Setting | Value |
|---------|-------|
| Config Location | `/opt/ut99server/System/UnrealTournament.ini` |
| Default Map | DM-Deck16][ |
| Max Players | 16 |
| Ports | 7777-7779 (UDP), 27900 (UDP) |

**Game Modes:**
- Deathmatch: `Botpack.DeathMatchPlus`
- Team DM: `Botpack.TeamGamePlus`
- CTF: `Botpack.CTFGame`
- Assault: `Botpack.Assault`

---

### Unreal Tournament 2004

| Setting | Value |
|---------|-------|
| Config Location | `/opt/ut2004server/System/UT2004.ini` |
| Default Map | DM-Rankin |
| Max Players | 16 |
| Ports | 7777-7778, 7787, 28902 (UDP) |

---

### San Andreas Multiplayer

| Setting | Value |
|---------|-------|
| Config Location | `/opt/sampserver/server.cfg` |
| Gamemodes | `/opt/sampserver/gamemodes/` |
| Max Players | 50 |
| Port | 7777 (UDP) |

---

### Quake III Arena

| Setting | Value |
|---------|-------|
| Docker Image | `jberrenberg/quake3` |
| Max Players | 16 |
| Port | 27960 (UDP) |

---

## MMO Emulators

### World of Warcraft (AzerothCore)

| Setting | Value |
|---------|-------|
| Install Location | `/opt/azerothcore/` |
| Auth Config | `/opt/azerothcore/server/etc/authserver.conf` |
| World Config | `/opt/azerothcore/server/etc/worldserver.conf` |
| Auth Port | 3724 (TCP) |
| World Port | 8085 (TCP) |
| Deployment | VM (Compiled) |

**Databases:** `acore_auth`, `acore_world`, `acore_characters`

**Create Account:**
```bash
/opt/azerothcore/server/bin/create_account.sh <user> <pass> [gmlevel]
# gmlevel: 0=player, 1=mod, 2=gm, 3=admin
```

---

### Star Wars Galaxies EMU

| Setting | Value |
|---------|-------|
| Install Location | `/opt/swgemu/` |
| Config File | `bin/conf/config-local.lua` |
| TRE Files | `/opt/swgemu/tre/` |
| Login Port | 44419 (TCP) |
| Zone Port | 44453 (TCP) |
| Status Port | 44455 (TCP) |
| Deployment | VM (Compiled) |

**Requirements:** Debian 12+, Clang 19, MariaDB, 8GB+ RAM

---

### City of Heroes

| Setting | Value |
|---------|-------|
| Type | Windows VM |
| Auth Port | 2104 (TCP) |
| DB Port | 2105 (TCP) |
| Game Ports | 7000-7100 (TCP/UDP) |
| RAM Required | 8GB min, 32GB recommended |
| Deployment | VM (Windows Server) |

---

## Server Management

### Pterodactyl Panel

| Setting | Value |
|---------|-------|
| Docker Image | `ghcr.io/pterodactyl/panel:latest` |
| Ports | 80, 443, 8080, 2022 (TCP) |

Web-based game server management panel supporting multiple games.

---

### Crafty Controller

| Setting | Value |
|---------|-------|
| Docker Image | `registry.gitlab.com/crafty-controller/crafty-4:latest` |
| Ports | 8443, 8123, 25500, 25565 (TCP) |

Minecraft-focused server management panel.

---

### Foundry VTT

| Setting | Value |
|---------|-------|
| Docker Image | `felddy/foundryvtt` |
| Port | 30000 (TCP) |
| License Required | Yes (Foundry account) |

Virtual tabletop for D&D, Pathfinder, and other RPGs.
