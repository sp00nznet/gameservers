# Firewall Configuration

UFW (Uncomplicated Firewall) rules for all supported game servers.

## Quick Reference

### Source Engine Games
| Game | Ports | Protocol |
|------|-------|----------|
| Counter-Strike 1.6 | 27015 | TCP/UDP |
| Counter-Strike 2 | 27015, 27020 | TCP/UDP |
| Team Fortress 2 | 27015 | TCP/UDP |
| Team Fortress Classic | 27015 | TCP/UDP |
| Half-Life DM | 27015 | TCP/UDP |
| Half-Life 2: DM | 27015 | TCP/UDP |
| Black Mesa | 27015 | TCP/UDP |
| Sven Co-op | 27015 | TCP/UDP |
| Synergy | 27015 | TCP/UDP |
| Garry's Mod | 27015, 27005 | TCP/UDP |
| Left 4 Dead 2 | 27015 | TCP/UDP |

### Survival Games
| Game | Ports | Protocol |
|------|-------|----------|
| Valheim | 2456-2458 | UDP |
| Rust | 28015, 28016, 28082 | UDP/TCP |
| 7 Days to Die | 26900-26902 | UDP/TCP |
| Project Zomboid | 16261-16262, 27015 | UDP/TCP |
| Palworld | 8211, 27015 | UDP |
| Enshrouded | 15636-15637 | UDP |
| V Rising | 9876-9877 | UDP |
| Conan Exiles | 7777-7778, 27015 | UDP |
| ARK: SA | 7777-7778, 27015, 27020 | UDP/TCP |
| Abiotic Factor | 7777, 27015 | UDP |
| HumanitZ | 7777, 27015 | UDP |
| Don't Starve Together | 10999, 10998 | UDP |

### Sandbox & Building
| Game | Ports | Protocol |
|------|-------|----------|
| Minecraft Java | 25565, 25575 | TCP |
| Minecraft Bedrock | 19132 | UDP |
| Terraria | 7777 | TCP |
| Starbound | 21025 | TCP |
| Factorio | 34197 | UDP |
| Satisfactory | 7777, 15000, 15777 | UDP |

### Classic Games
| Game | Ports | Protocol |
|------|-------|----------|
| Killing Floor | 7707-7708, 7717, 28852 | TCP/UDP |
| Killing Floor 2 | 7777, 27015, 8080, 20560 | TCP/UDP |
| UT99 | 7777-7779, 27900 | UDP |
| UT2004 | 7777-7778, 7787, 28902 | UDP/TCP |
| SA-MP | 7777 | UDP |
| Quake III Arena | 27960 | UDP |

### MMO Emulators
| Game | Ports | Protocol |
|------|-------|----------|
| WoW (AzerothCore) | 3724, 8085, 7878 | TCP |
| SWGEmu | 44453-44463 | TCP/UDP |
| City of Heroes | 2104-2106, 7000-7100, 11228 | TCP/UDP |

### Server Management
| Service | Ports | Protocol |
|---------|-------|----------|
| Pterodactyl | 80, 443, 8080, 2022 | TCP |
| Crafty Controller | 8443, 8123, 25500 | TCP |
| AMP | 8080, 8081 | TCP |
| Foundry VTT | 30000 | TCP |

---

## UFW Commands by Game

### Source Engine Games (CS, TF2, etc.)
```bash
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp
```

### Counter-Strike 2
```bash
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp
sudo ufw allow 27020/udp
```

### Garry's Mod
```bash
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp
sudo ufw allow 27005/udp
```

### Valheim
```bash
sudo ufw allow 2456:2458/udp
```

### Rust
```bash
sudo ufw allow 28015/udp
sudo ufw allow 28016/tcp
sudo ufw allow 28082/tcp
```

### 7 Days to Die
```bash
sudo ufw allow 26900:26902/udp
sudo ufw allow 26900:26902/tcp
```

### Project Zomboid
```bash
sudo ufw allow 16261/udp
sudo ufw allow 16262/udp
sudo ufw allow 27015/tcp
```

### Palworld
```bash
sudo ufw allow 8211/udp
sudo ufw allow 27015/udp
```

### Enshrouded
```bash
sudo ufw allow 15636:15637/udp
```

### V Rising
```bash
sudo ufw allow 9876:9877/udp
```

### Conan Exiles
```bash
sudo ufw allow 7777:7778/udp
sudo ufw allow 27015/udp
```

### ARK: Survival Ascended
```bash
sudo ufw allow 7777:7778/udp
sudo ufw allow 27015/udp
sudo ufw allow 27020/tcp
```

### Abiotic Factor / HumanitZ
```bash
sudo ufw allow 7777/udp
sudo ufw allow 27015/udp
```

### Don't Starve Together
```bash
sudo ufw allow 10999/udp
sudo ufw allow 10998/udp
```

### Minecraft Java
```bash
sudo ufw allow 25565/tcp
sudo ufw allow 25575/tcp  # RCON
```

### Minecraft Bedrock
```bash
sudo ufw allow 19132/udp
```

### Terraria
```bash
sudo ufw allow 7777/tcp
```

### Starbound
```bash
sudo ufw allow 21025/tcp
```

### Factorio
```bash
sudo ufw allow 34197/udp
```

### Satisfactory
```bash
sudo ufw allow 7777/udp
sudo ufw allow 15000/udp
sudo ufw allow 15777/udp
```

### Killing Floor
```bash
sudo ufw allow 7707/udp
sudo ufw allow 7708/udp
sudo ufw allow 7717/udp
sudo ufw allow 28852/tcp
sudo ufw allow 28852/udp
```

### Killing Floor 2
```bash
sudo ufw allow 7777/udp
sudo ufw allow 27015/udp
sudo ufw allow 8080/tcp
sudo ufw allow 20560/udp
```

### Unreal Tournament 99
```bash
sudo ufw allow 7777:7779/udp
sudo ufw allow 27900/udp
```

### Unreal Tournament 2004
```bash
sudo ufw allow 7777:7778/udp
sudo ufw allow 7787/udp
sudo ufw allow 28902/udp
```

### San Andreas Multiplayer
```bash
sudo ufw allow 7777/udp
```

### Quake III Arena
```bash
sudo ufw allow 27960/udp
```

### World of Warcraft (AzerothCore)
```bash
sudo ufw allow 3724/tcp
sudo ufw allow 8085/tcp
sudo ufw allow 7878/tcp
```

### Star Wars Galaxies EMU
```bash
sudo ufw allow 44453:44463/tcp
sudo ufw allow 44453:44463/udp
```

### City of Heroes
```bash
sudo ufw allow 2104:2106/tcp
sudo ufw allow 7000:7100/tcp
sudo ufw allow 7000:7100/udp
sudo ufw allow 11228/tcp
```

### Pterodactyl Panel
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 2022/tcp
```

### Crafty Controller
```bash
sudo ufw allow 8443/tcp
sudo ufw allow 8123/tcp
sudo ufw allow 25500/tcp
```

### Foundry VTT
```bash
sudo ufw allow 30000/tcp
```

---

## Enable/Disable UFW

```bash
# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable

# Check status
sudo ufw status verbose

# Check numbered rules
sudo ufw status numbered

# Delete a rule by number
sudo ufw delete <number>

# Reset all rules
sudo ufw reset
```

## Default Policies

```bash
# Default deny incoming, allow outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (important!)
sudo ufw allow 22/tcp
```
