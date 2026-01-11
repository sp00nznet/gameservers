# Troubleshooting Guide

Common issues and solutions for game server problems.

## Server Won't Start

### Check Service Status
```bash
sudo systemctl status <service-name>
```

### View Logs
```bash
sudo journalctl -u <service-name> -n 50
```

### Run Manually
```bash
cd /opt/<server-dir>
./start-server.sh
```

## SteamCMD Issues

### Download Fails
1. Check network: `ping steamcdn-a.akamaihd.net`
2. Check disk space: `df -h`
3. Test SteamCMD:
   ```bash
   /opt/steamcmd/steamcmd.sh +login anonymous +quit
   ```

### Validation Errors
```bash
# Force revalidation
/opt/steamcmd/steamcmd.sh \
  +force_install_dir /opt/<server-dir> \
  +login anonymous \
  +app_update <app-id> validate \
  +quit
```

## Permission Errors

### Fix Ownership
```bash
sudo chown -R root:root /opt/<server-dir>

# Project Zomboid specific:
sudo chown -R pzuser:pzuser /opt/pzserver
```

## Server Not in Browser

1. **Source games:** Verify GSLT token is configured
2. **All games:** Check firewall allows required ports
3. **Verify running:** `screen -ls`

## Console Access

### Attach to Screen
```bash
sudo screen -r <session-name>
```

### Detach (Keep Running)
Press: `Ctrl+A`, then `D`

### List Sessions
```bash
screen -ls
```

## Updating Servers

```bash
# Stop server
sudo systemctl stop <service-name>

# Update via SteamCMD
/opt/steamcmd/steamcmd.sh \
  +force_install_dir /opt/<server-dir> \
  +login anonymous \
  +app_update <app-id> validate \
  +quit

# Start server
sudo systemctl start <service-name>
```

## Uninstalling

```bash
# Stop and disable
sudo systemctl stop <service-name>
sudo systemctl disable <service-name>

# Remove service
sudo rm /etc/systemd/system/<service-name>.service
sudo systemctl daemon-reload

# Remove files
sudo rm -rf /opt/<server-dir>
```

## Log Files

### Setup Logs
```bash
tail -f /var/log/gameservers/setup.log
grep "ERROR" /var/log/gameservers/setup.log
```

### Log Format
```
[2024-01-15 14:30:22] [INFO] Starting server installation
[2024-01-15 14:30:23] [SUCCESS] SteamCMD installed
[2024-01-15 14:35:45] [ERROR] Download failed
```
