# Game Server Configuration Guide

Detailed configuration options for each supported game server.

## Table of Contents

- [ARK: Survival Ascended](#ark-survival-ascended)
- [Black Mesa](#black-mesa)
- [City of Heroes](#city-of-heroes)
- [Counter-Strike](#counter-strike)
- [Counter-Strike 2](#counter-strike-2)
- [Half-Life Deathmatch](#half-life-deathmatch)
- [Half-Life 2: Deathmatch](#half-life-2-deathmatch)
- [Killing Floor](#killing-floor)
- [Killing Floor 2](#killing-floor-2)
- [Project Zomboid](#project-zomboid)
- [Team Fortress 2](#team-fortress-2)
- [Team Fortress Classic](#team-fortress-classic)
- [Synergy](#synergy)
- [Sven Co-op](#sven-co-op)
- [Abiotic Factor](#abiotic-factor)
- [HumanitZ](#humanitz)
- [San Andreas Multiplayer](#san-andreas-multiplayer)
- [Starbound](#starbound)
- [Unreal Tournament 99](#unreal-tournament-99)
- [Unreal Tournament 2004](#unreal-tournament-2004)
- [Star Wars Galaxies EMU](#star-wars-galaxies-emu)
- [World of Warcraft](#world-of-warcraft-azerothcore)

---

## ARK: Survival Ascended

| Setting | Value |
|---------|-------|
| Config Location | `/opt/arkserver/ShooterGame/Saved/Config/WindowsServer/` |
| Main Config | `GameUserSettings.ini` |
| Game Rules | `Game.ini` |
| Default Map | TheIsland_WP |
| Max Players | 70 |

**Available Maps:**
- `TheIsland_WP`, `ScorchedEarth_WP`, `Aberration_WP`
- `TheCenter_WP`, `Ragnarok_WP`, `Extinction_WP`

**Adding Mods:**
```bash
# Edit the setup script
sudo nano /home/user/gameservers/arkasa/ark-server-setup.sh
# Find: MODS=""
# Change to: MODS="928793,900062"
```

---

## Black Mesa

| Setting | Value |
|---------|-------|
| Config Location | `/opt/bmserver/bms/cfg/server.cfg` |
| GSLT Config | `/opt/bmserver/bmserver.conf` |
| Default Map | dm_bounce |
| Max Players | 16 |

**Available Maps:**
`dm_bounce`, `dm_chopper`, `dm_crossfire`, `dm_gasworks`, `dm_lambdabunker`, `dm_power`, `dm_rail`, `dm_stack`, `dm_stalkyard`, `dm_subtransit`, `dm_undertow`

---

## City of Heroes

| Setting | Value |
|---------|-------|
| Type | Windows VM (QEMU/KVM or Proxmox) |
| VM Location | `/opt/cohserver/vm/` |
| Shared Files | `/opt/cohserver/shared/` |
| Auth Port | 2104 |
| DB Port | 2105 |
| Game Ports | 7000-7100 |
| RAM Required | 8GB min, 32GB recommended |

**VM Management:**
```bash
virsh start coh-windows-server
virsh shutdown coh-windows-server
virt-manager  # GUI
```

**Resources:**
- [OuroDev Wiki](https://wiki.ourodev.com/)
- [Server Setup Guide](https://wiki.ourodev.com/Volume_2_Server_Setup)

---

## Counter-Strike

| Setting | Value |
|---------|-------|
| Config Location | `/opt/csserver/cstrike/server.cfg` |
| Default Map | de_dust2 |
| Max Players | 20 |

---

## Counter-Strike 2

| Setting | Value |
|---------|-------|
| Config Location | `/opt/cs2server/game/csgo/cfg/server.cfg` |
| GSLT Config | `/opt/cs2server/cs2server.conf` |
| Default Map | de_dust2 |
| Max Players | 20 |

**Game Modes:**
| Mode | game_type | game_mode |
|------|-----------|-----------|
| Casual | 0 | 0 |
| Competitive | 0 | 1 |
| Arms Race | 1 | 0 |
| Demolition | 1 | 1 |
| Deathmatch | 1 | 2 |

---

## Half-Life Deathmatch

| Setting | Value |
|---------|-------|
| Config Location | `/opt/hldmserver/valve/server.cfg` |
| Default Map | crossfire |
| Max Players | 16 |

---

## Half-Life 2: Deathmatch

| Setting | Value |
|---------|-------|
| Config Location | `/opt/hl2dmserver/hl2mp/cfg/server.cfg` |
| GSLT Config | `/opt/hl2dmserver/hl2dmserver.conf` |
| Default Map | dm_lockdown |
| Max Players | 16 |

---

## Killing Floor

| Setting | Value |
|---------|-------|
| Config Location | `/opt/kf1server/System/` |
| Default Map | KF-WestLondon.rom |
| Max Players | 6 |

---

## Killing Floor 2

| Setting | Value |
|---------|-------|
| Config Location | `/opt/kf2server/KFGame/Config/` |
| Web Admin | Port 8080 |
| Default Map | KF-BioticsLab |
| Max Players | 6 |

---

## Project Zomboid

| Setting | Value |
|---------|-------|
| Config Location | `/home/pzuser/Zomboid/Server/` |
| Main Config | `pzserver.ini` |
| Sandbox Settings | `pzserver_SandboxVars.lua` |
| Default Map | Muldraugh, KY |
| Max Players | 16 |

**Important:** Change default passwords after installation:
```bash
sudo nano /home/pzuser/Zomboid/Server/pzserver.ini
```

---

## Team Fortress 2

| Setting | Value |
|---------|-------|
| Config Location | `/opt/tf2server/tf/cfg/server.cfg` |
| GSLT Config | `/opt/tf2server/tf2server.conf` |
| Default Map | ctf_2fort |
| Max Players | 24 |

**Making Server Public:**
```bash
sudo nano /opt/tf2server/tf2server.conf
# Add: STEAM_GSLT_TOKEN="your_token_here"
sudo systemctl restart tf2server
```

---

## Team Fortress Classic

| Setting | Value |
|---------|-------|
| Config Location | `/opt/tfcserver/tfc/server.cfg` |
| Default Map | 2fort |
| Max Players | 24 |

---

## Synergy

| Setting | Value |
|---------|-------|
| Config Location | `/opt/synergyserver/synergy/cfg/server.cfg` |
| Default Map | d1_trainstation_01 |
| Max Players | 8 |

---

## Sven Co-op

| Setting | Value |
|---------|-------|
| Config Location | `/opt/svencoopserver/svencoop/server.cfg` |
| Default Map | svencoop1 |
| Max Players | 12 |

---

## Abiotic Factor

| Setting | Value |
|---------|-------|
| Default Port | 7777 |
| Query Port | 27015 |
| Max Players | 6 |

---

## HumanitZ

| Setting | Value |
|---------|-------|
| Default Port | 7777 |
| Query Port | 27015 |
| Max Players | 16 |

---

## San Andreas Multiplayer

| Setting | Value |
|---------|-------|
| Config Location | `/opt/sampserver/server.cfg` |
| Gamemodes | `/opt/sampserver/gamemodes/` |
| Default Port | 7777 |
| Max Players | 50 |

---

## Starbound

| Setting | Value |
|---------|-------|
| Config Location | `/opt/starboundserver/storage/starbound_server.config` |
| Default Port | 21025 |
| Max Players | 8 |

---

## Unreal Tournament 99

| Setting | Value |
|---------|-------|
| Config Location | `/opt/ut99server/System/UnrealTournament.ini` |
| Default Map | DM-Deck16][ |
| Ports | 7777 (game), 7778 (query) |
| Max Players | 16 |

**Game Modes:**
- Deathmatch: `Botpack.DeathMatchPlus`
- Team DM: `Botpack.TeamGamePlus`
- CTF: `Botpack.CTFGame`
- Assault: `Botpack.Assault`
- Domination: `Botpack.Domination`

---

## Unreal Tournament 2004

| Setting | Value |
|---------|-------|
| Config Location | `/opt/ut2004server/System/UT2004.ini` |
| Default Map | DM-Rankin |
| Ports | 7777 (game), 7778 (query), 8075 (web admin) |
| Max Players | 16 |

**Game Modes:**
- Deathmatch: `XGame.xDeathMatch`
- Team DM: `XGame.xTeamGame`
- CTF: `XGame.xCTFGame`
- Onslaught: `Onslaught.ONSOnslaughtGame`

---

## Star Wars Galaxies EMU

| Setting | Value |
|---------|-------|
| Install Location | `/opt/swgemu/` |
| Config File | `bin/conf/config-local.lua` |
| TRE Files | `/opt/swgemu/tre/` |
| Login Port | 44419 |
| Zone Port | 44453 |
| Status Port | 44455 |

**Requirements:** Debian 12+, Clang 19, MariaDB, 8GB+ RAM

**Resources:**
- [GitHub](https://github.com/swgemu/Core3)
- [SWGEmu Wiki](https://www.swgemu.com/wiki/)

---

## World of Warcraft (AzerothCore)

| Setting | Value |
|---------|-------|
| Install Location | `/opt/azerothcore/` |
| Auth Config | `/opt/azerothcore/server/etc/authserver.conf` |
| World Config | `/opt/azerothcore/server/etc/worldserver.conf` |
| Auth Port | 3724 |
| World Port | 8085 |

**Databases:** `acore_auth`, `acore_world`, `acore_characters`

**Create Account:**
```bash
/opt/azerothcore/server/bin/create_account.sh <user> <pass> [gmlevel]
# gmlevel: 0=player, 1=mod, 2=gm, 3=admin
```

**Client Setup:** Edit `realmlist.wtf`:
```
set realmlist <your-server-ip>
```

**Resources:**
- [AzerothCore Wiki](https://www.azerothcore.org/wiki/)
- [GitHub](https://github.com/azerothcore/azerothcore-wotlk)
