# Supported games

The deployer's catalog: **217 servers** in 14 categories, 72 of them with an install script. The source of truth is `proxmox-deployer/app/game_servers.py`; update this file when you add a game.

**Install script** means the deployer provisions the game after creating the container (`app/install_scripts.py`). Without one, you get an empty container with the right resources and install the game yourself.

## Source Engine (34)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| Counter-Strike 1.6 | `cs16` | 90 | 27015 | yes |
| Counter-Strike 2 | `cs2` | 730 | 27015, 27020 | yes |
| Counter-Strike: Source | `css` | 232330 | 27015 | yes |
| Counter-Strike: Condition Zero | `cscz` | 80 | 27015 | - |
| Counter-Strike: Global Offensive | `csgo` | 740 | 27015 | yes |
| Team Fortress 2 | `tf2` | 232250 | 27015 | yes |
| Team Fortress Classic | `tfc` | 20 | 27015 | - |
| Garry's Mod | `gmod` | 4020 | 27015 | yes |
| Left 4 Dead | `l4d` | 222840 | 27015 | - |
| Left 4 Dead 2 | `l4d2` | 222860 | 27015 | yes |
| Half-Life Deathmatch | `hldm` | 90 | 27015 | - |
| Half-Life 2: Deathmatch | `hl2dm` | 232370 | 27015 | - |
| Half-Life Deathmatch: Source | `hldms` | 360 | 27015 | - |
| Black Mesa | `blackmesa` | 346680 | 27015 | yes |
| Sven Co-op | `svencoop` | 276060 | 27015 | yes |
| Day of Defeat | `dod` | 30 | 27015 | - |
| Day of Defeat: Source | `dods` | 232290 | 27015 | - |
| Fistful of Frags | `fof` | 295230 | 27015 | - |
| Synergy | `synergy` | 17520 | 27015 | - |
| Deathmatch Classic | `dmc` | 40 | 27015 | - |
| Ricochet | `ricochet` | 60 | 27015 | - |
| Opposing Force | `opfor` | 50 | 27015 | - |
| Action Half-Life | `ahl` | - | 27015 | - |
| Action: Source | `ahl2` | - | 27015 | - |
| BrainBread | `bb` | - | 27015 | - |
| BrainBread 2 | `bb2` | - | 27015 | - |
| Dystopia | `dystopia` | - | 27015 | - |
| Empires Mod | `empires` | - | 27015 | - |
| SourceForts Classic | `sfc` | - | 27015 | - |
| The Specialists | `ts` | - | 27015 | - |
| Vampire Slayer | `vs` | - | 27015 | - |
| Zombie Master: Reborn | `zmr` | - | 27015 | - |
| Zombie Panic! Source | `zps` | - | 27015 | - |
| Pirates Vikings & Knights II | `pvkii` | - | 27015 | - |

## Survival Games (43)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| Valheim | `valheim` | 896660 | 2456, 2457, 2458 | yes |
| Rust | `rust` | 258550 | 28015, 28016 | yes |
| 7 Days to Die | `sdtd` | 294420 | 26900, 26901, 26902 | yes |
| Project Zomboid | `pz` | 380870 | 16261, 16262 | yes |
| Palworld | `palworld` | 2394010 | 8211 | yes |
| Enshrouded | `enshrouded` | 2278520 | 15636, 15637 | yes |
| V Rising | `vrising` | 1604030 | 9876, 9877 | yes |
| Conan Exiles | `conanexiles` | 443030 | 7777, 7778, 27015 | yes |
| ARK: Survival Ascended | `arksa` | 2430930 | 7777, 7778, 27015 | - |
| ARK: Survival Evolved | `ark` | 376030 | 7777, 7778, 27015 | yes |
| Don't Starve Together | `dst` | 343050 | 10999, 11000 | yes |
| Sons of the Forest | `sonsoftheforest` | 2465200 | 8766, 27016 | - |
| The Forest | `theforest` | 556450 | 8766, 27016 | - |
| Barotrauma | `barotrauma` | 1026340 | 27015, 27016 | yes |
| SCUM | `scum` | 3792580 | 7042, 7043 | - |
| Core Keeper | `corekeeper` | 1963720 | 27015, 27016 | yes |
| Icarus | `icarus` | 2089300 | 17777 | - |
| Eco | `eco` | 382310 | 3000, 3001 | yes |
| The Isle | `theisle` | 412680 | 7777, 7778 | yes |
| Day of Dragons | `dodr` | - | 7777, 7778 | - |
| Hurtworld | `hurtworld` | 405100 | 12871, 12881 | yes |
| Vintage Story | `vintagestory` | - | 42420 | - |
| Craftopia | `craftopia` | 1307550 | 6587 | yes |
| Empyrion Galactic Survival | `empyrion` | 530870 | 30000, 30001 | - |
| CryoFall | `cryofall` | 829590 | 6000 | - |
| Longvinter | `longvinter` | 1628750 | 7777 | - |
| Nightingale | `nightingale` | 1928980 | 7777 | - |
| The Front | `thefront` | 2285150 | 25010, 25011 | yes |
| Myth of Empires | `mythofempires` | 1371580 | 12888, 12889 | - |
| Last Oasis | `lastoasis` | 920720 | 5555, 5556 | - |
| No One Survived | `noonesurvived` | 1963370 | 7777 | - |
| Soulmask | `soulmask` | 3040080 | 7777, 7778 | - |
| HumanitZ | `humanitz` | 2740380 | 7777 | - |
| Survive the Nights | `stn` | - | 7777 | - |
| Abiotic Factor | `abioticfactor` | - | 7777 | - |
| Frozen Flame | `frozenflame` | - | 7777 | - |
| Dead Matter | `deadmatter` | - | 7777 | - |
| Deadpoly | `deadpoly` | - | 7777 | - |
| Night of the Dead | `nightofthedead` | - | 7777 | - |
| Plains of Pain | `plainsofpain` | - | 7777 | - |
| PixARK | `pixark` | - | 7777 | - |
| ASKA | `aska` | - | 7777 | - |
| Exfil | `exfil` | - | 7777 | - |

## Classic Games (24)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| Killing Floor | `kf` | 215360 | 7707, 7708, 28852 | yes |
| Killing Floor 2 | `kf2` | 232130 | 7777, 27015 | yes |
| Call of Duty | `cod` | - | 28960 | - |
| Call of Duty 2 | `cod2` | - | 28960 | yes |
| Call of Duty 4: MW | `cod4` | - | 28960 | yes |
| Call of Duty: United Offensive | `coduo` | - | 28960 | - |
| Call of Duty: World at War | `codwaw` | - | 28960 | - |
| Battlefield 1942 | `bf1942` | - | 14567, 14690, 23000 | yes |
| Battlefield: Vietnam | `bfv` | - | 15567 | - |
| Medal of Honor: Allied Assault | `mohaa` | - | 12203, 12300 | - |
| Return to Castle Wolfenstein | `rtcw` | - | 27960 | yes |
| Wolfenstein: Enemy Territory | `wet` | - | 27960 | yes |
| ET: Legacy | `etl` | - | 27960 | - |
| Soldier of Fortune 2 | `sof2` | - | 28910 | - |
| Unturned | `unturned` | 304930 | 27015, 27016 | yes |
| Jedi Knight II: Jedi Outcast | `jk2` | - | 28070 | - |
| Jedi Academy | `jka` | - | 29070 | - |
| Doom 2 | `doom2` | - | 5029 | - |
| Red Orchestra: Ostfront | `ro` | - | 7757, 7758 | - |
| Blackwake | `blackwake` | - | 25001 | - |
| Broke Protocol | `brokeprotocol` | - | 5557 | - |
| Reign of Kings | `reignofkings` | - | 7350 | - |
| Eye: Divine Cybermancy | `eyedivine` | - | 27015 | - |
| LOTR: Return to Moria | `lotrmoria` | - | 7777 | - |

## Sandbox & Building (25)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| Minecraft Java | `minecraft` | - | 25565 | yes |
| Minecraft Bedrock | `minecraftbedrock` | - | 19132 | yes |
| PaperMC | `papermc` | - | 25565 | - |
| Velocity Proxy MC | `velocitymc` | - | 25577 | - |
| WaterfallMC | `waterfallmc` | - | 25577 | - |
| Terraria | `terraria` | 105600 | 7777 | yes |
| Starbound | `starbound` | 211820 | 21025 | yes |
| OpenStarbound | `openstarbound` | - | 21025 | - |
| Factorio | `factorio` | 427520 | 34197 | yes |
| Satisfactory | `satisfactory` | 1690800 | 7777, 15000, 15777 | yes |
| Space Engineers | `spaceengineers` | 298740 | 27016 | - |
| Stationeers | `stationeers` | 544550 | 27500, 27015 | yes |
| Avorion | `avorion` | 565060 | 27000, 27003, 27020, 27021 | yes |
| Colony Survival | `colonysurvival` | 366090 | 27016, 27017 | - |
| Rising World | `risingworld` | 324080 | 4255 | - |
| Wurm Unlimited | `wurm` | 366220 | 3724 | - |
| Astroneer | `astroneer` | 728470 | 8777 | - |
| OpenTTD | `openttd` | 1536610 | 3979 | - |
| Minetest | `minetest` | - | 30000 | - |
| Creativerse | `creativerse` | - | 26900 | - |
| Cubic Odyssey | `cubicodes` | - | 7777 | - |
| Portal Knights | `portalknights` | - | 7777 | - |
| Stonehearth | `stonehearth` | - | 7777 | - |
| Astro Colony | `astrocolony` | - | 7777 | - |
| OpenRCT2 | `openrct2` | - | 11753 | - |

## MMO Emulators (6)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| WoW (AzerothCore) | `azerothcore` | - | 3724, 8085 | yes |
| WoW (TrinityCore) | `trinitycore` | - | 3724, 8085 | - |
| SWGEmu | `swgemu` | - | 44419, 44453, 44463 | - |
| SWG: Legends | `swglegends` | - | 44419 | - |
| City of Heroes | `cityofheroes` | - | 2104 | - |
| Impostor (Among Us) | `impostor` | - | 22023 | - |

## Server Management (3)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| Pterodactyl | `pterodactyl` | - | 80, 443, 8080 | yes |
| Crafty Controller | `craftycont` | - | 8443, 8123 | - |
| AMP (CubeCoders) | `amp` | - | 8080 | yes |

## RPG & Tabletop (7)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| Foundry VTT | `foundryvtt` | - | 30000 | - |
| Sapiens | `sapiens` | - | 7777 | - |
| Wartales | `wartales` | - | 7777 | - |
| Stellaris | `stellaris` | - | 23243 | - |
| Dota 2 | `dota2` | - | 27015 | - |
| Subnautica Nitrox | `subnautica` | - | 11000 | - |
| Thrive | `thrive` | - | 7777 | - |

## Military Simulation (13)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| DayZ | `dayz` | 223350 | 2302, 2303, 27016 | yes |
| DayZ Experimental | `dayzexp` | - | 2302, 2303, 27016 | - |
| ARMA 3 | `arma3` | 233780 | 2302, 2303, 2304 | yes |
| Arma Reforger | `armareforger` | 1874900 | 2001 | yes |
| Squad | `squad` | 403240 | 7787, 7788, 27165 | yes |
| Squad 44 | `squad44` | 746200 | 10027 | - |
| Hell Let Loose | `hellletloose` | 1348460 | 7777, 7778, 27015 | - |
| Insurgency: Sandstorm | `insurgencysandstorm` | 581330 | 27102, 27131 | yes |
| Insurgency | `insurgency` | 237410 | 27015 | yes |
| Day of Infamy | `dayofinfamy` | 462310 | 27015 | yes |
| Operation: Harsh Doorstop | `ohd` | - | 7777 | - |
| Ground Branch | `groundbranch` | - | 7777 | - |
| Rising Storm 2: Vietnam | `risingstorm2` | - | 7777, 7778, 27015 | - |

## Racing & Simulation (8)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| Assetto Corsa | `assettocorsa` | 302550 | 9600, 8081 | yes |
| Assetto Corsa Competizione | `acc` | 805550 | 9231 | - |
| Euro Truck Simulator 2 | `ets2` | 227300 | 27015 | yes |
| American Truck Simulator | `ats` | 270880 | 27015 | yes |
| BeamMP | `beammp` | - | 30814 | - |
| Project Cars | `projectcars` | - | 9000 | - |
| Project Cars 2 | `projectcars2` | - | 9000 | - |
| MX Bikes | `mxbikes` | - | 7777 | - |

## Roleplay (9)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| FiveM | `fivem` | - | 30120 | yes |
| alt:V | `altv` | - | 7788 | - |
| RedM | `redm` | - | 30120 | - |
| Multi Theft Auto | `mta` | - | 22003, 22005, 22126 | yes |
| RAGE:MP | `ragemp` | - | 22005 | - |
| SA-MP | `samp` | - | 7777 | yes |
| Just Cause 2 MP | `jc2mp` | - | 7777 | - |
| Just Cause 3 MP | `jc3mp` | - | 7777 | - |
| Onset | `onset` | - | 7777 | - |

## Arena & Competitive (25)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| Quake III Arena | `quake3` | - | 27960 | yes |
| Quake 2 | `quake2` | - | 27910 | - |
| Quake 4 | `quake4` | - | 28004 | - |
| Quake Live | `quakelive` | 349090 | 27960 | yes |
| Quake World | `quakeworld` | - | 27500 | - |
| Xonotic | `xonotic` | - | 26000 | yes |
| Warfork | `warfork` | - | 44400 | - |
| Unreal Tournament 99 | `ut99` | - | 7777 | yes |
| Unreal Tournament 2004 | `ut2004` | - | 7777 | yes |
| Unreal Tournament 3 | `ut3` | - | 7777 | - |
| Chivalry: Medieval Warfare | `chivalry` | 220070 | 7777 | yes |
| MORDHAU | `mordhau` | 629800 | 7777, 15000, 27015 | yes |
| Pavlov VR | `pavlov` | 622970 | 7777 | yes |
| Teeworlds | `teeworlds` | - | 8303 | yes |
| Soldat | `soldat` | - | 23073 | - |
| IOSoccer | `iofootball` | - | 27015 | - |
| Blade Symphony | `bladesymphony` | - | 27015 | - |
| Ballistic Overkill | `ballisticoverkill` | - | 27015 | - |
| BATTALION: Legacy | `battalion` | - | 7777 | - |
| Double Action: Boogaloo | `doubleaction` | - | 27015 | - |
| StickyBots | `stickybots` | - | 27015 | - |
| Base Defense | `basedefense` | - | 27015 | - |
| Cube 2: Sauerbraten | `sauerbraten` | - | 28785 | - |
| Tremulous | `tremulous` | - | 30720 | - |
| OpenRA | `openra` | - | 1234 | - |

## Co-op & Multiplayer (18)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| No More Room in Hell | `nmrih` | 317670 | 27015 | yes |
| Natural Selection | `ns` | - | 27015 | - |
| Natural Selection 2 | `ns2` | 4940 | 27015, 27016 | yes |
| NS2: Combat | `ns2c` | - | 27015 | - |
| SCP: Secret Laboratory | `scpsl` | 996560 | 7777 | yes |
| SCP: Secret Laboratory ServerMod | `scpslsm` | - | 7777 | - |
| Tower Unite | `towerunite` | 439660 | 27015 | yes |
| Risk of Rain 2 | `riskofrain2` | 1180760 | 27015 | - |
| Rimworld Together | `rimworldtogether` | - | 25555 | - |
| Path of Titans | `pathoftitans` | - | 7777 | - |
| Mindustry | `mindustry` | 1127400 | 6567 | - |
| Necesse | `necesse` | - | 14159 | - |
| Nuclear Dawn | `nucleardawn` | - | 27015 | - |
| Codename CURE | `codenamecure` | - | 27015 | - |
| HYPERCHARGE: Unboxed | `hypercharge` | - | 7777 | - |
| Alien Swarm: Reactive Drop | `alienswarm` | - | 27015 | - |
| Clone Hero | `clonehero` | - | 14242 | - |
| Beasts of Bermuda | `beastsofbermuda` | - | 7777 | - |

## Voice & Communication (2)

| Game | Key | Steam App ID | Ports | Install script |
|---|---|---|---|---|
| TeamSpeak 3 | `ts3` | - | 9987, 10011, 30033 | yes |
| Mumble | `mumble` | - | 64738 | - |
