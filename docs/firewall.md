# Firewall Configuration

UFW (Uncomplicated Firewall) rules for all supported game servers.

## Quick Reference

| Game | Ports | Protocol |
|------|-------|----------|
| ARK: SA | 7777, 27015, 27020 | UDP/TCP |
| Black Mesa | 27015 | TCP/UDP |
| City of Heroes | 2104-2105, 7000-7100, 8080 | TCP/UDP |
| Counter-Strike | 27015 | TCP/UDP |
| Counter-Strike 2 | 27015, 27020 | TCP/UDP |
| Half-Life DM | 27015 | TCP/UDP |
| Half-Life 2: DM | 27015 | TCP/UDP |
| Killing Floor | 7707-7708, 7717, 28852 | TCP/UDP |
| Killing Floor 2 | 7777, 27015, 8080 | TCP/UDP |
| Project Zomboid | 16261-16262, 27015 | UDP/TCP |
| Team Fortress 2 | 27015 | TCP/UDP |
| TFC | 27015 | TCP/UDP |
| Synergy | 27015 | TCP/UDP |
| Sven Co-op | 27015 | TCP/UDP |
| Abiotic Factor | 7777, 27015 | UDP |
| HumanitZ | 7777, 27015 | UDP |
| SAMP | 7777 | UDP |
| Starbound | 21025 | TCP |
| UT99 | 7777-7778 | UDP |
| UT2004 | 7777-7778, 8075 | UDP/TCP |
| SWGEmu | 44419, 44453, 44455, 44462 | TCP/UDP |
| WoW | 3724, 8085 | TCP |

## UFW Commands

### ARK: Survival Ascended
```bash
sudo ufw allow 7777/udp
sudo ufw allow 27015/udp
sudo ufw allow 27020/tcp
```

### Black Mesa / Counter-Strike / TF2 / Source Games
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

### City of Heroes
```bash
sudo ufw allow 2104/tcp
sudo ufw allow 2105/tcp
sudo ufw allow 7000:7100/udp
sudo ufw allow 8080/tcp
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
```

### Project Zomboid
```bash
sudo ufw allow 16261/udp
sudo ufw allow 16262/udp
sudo ufw allow 27015/tcp
```

### Abiotic Factor / HumanitZ
```bash
sudo ufw allow 7777/udp
sudo ufw allow 27015/udp
```

### San Andreas Multiplayer
```bash
sudo ufw allow 7777/udp
```

### Starbound
```bash
sudo ufw allow 21025/tcp
```

### Unreal Tournament 99/2004
```bash
sudo ufw allow 7777/udp
sudo ufw allow 7778/udp
# UT2004 web admin:
sudo ufw allow 8075/tcp
```

### Star Wars Galaxies EMU
```bash
sudo ufw allow 44419/tcp
sudo ufw allow 44453/tcp
sudo ufw allow 44455/tcp
sudo ufw allow 44462/udp
```

### World of Warcraft
```bash
sudo ufw allow 3724/tcp
sudo ufw allow 8085/tcp
```

## Enable/Disable UFW

```bash
# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable

# Check status
sudo ufw status verbose

# Reset all rules
sudo ufw reset
```
