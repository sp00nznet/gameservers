"""
Game Server Installation Scripts for Proxmox Deployer
Contains bash installation scripts that run inside LXC containers after creation.
"""

# Base script for common setup (runs first)
BASE_SETUP_SCRIPT = """#!/bin/bash
set -e

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

# Install common dependencies
apt-get install -y \\
    curl \\
    wget \\
    ca-certificates \\
    gnupg \\
    lsb-release \\
    software-properties-common \\
    sudo \\
    jq \\
    tar \\
    gzip \\
    unzip \\
    lib32gcc-s1 \\
    lib32stdc++6

# Create gameserver user
if ! id -u gameserver &>/dev/null; then
    useradd -m -s /bin/bash gameserver
    echo 'gameserver ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/gameserver
fi

echo "Base setup complete"
"""

# LinuxGSM installer script template
LINUXGSM_INSTALL_TEMPLATE = """#!/bin/bash
set -e

# Switch to gameserver user
cd /home/gameserver

# Download LinuxGSM
curl -Lo linuxgsm.sh https://linuxgsm.sh
chmod +x linuxgsm.sh

# Install the game server
sudo -u gameserver ./linuxgsm.sh {linuxgsm_name}

# Run installation (this downloads the server files via SteamCMD)
sudo -u gameserver /home/gameserver/{linuxgsm_name} auto-install

# Create systemd service
cat > /etc/systemd/system/{linuxgsm_name}.service << 'EOF'
[Unit]
Description={game_name} Server (LinuxGSM)
After=network.target

[Service]
Type=forking
User=gameserver
WorkingDirectory=/home/gameserver
ExecStart=/home/gameserver/{linuxgsm_name} start
ExecStop=/home/gameserver/{linuxgsm_name} stop
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable {linuxgsm_name}
systemctl start {linuxgsm_name}

echo "{game_name} installed successfully via LinuxGSM"
"""

# Docker installer script template
DOCKER_INSTALL_TEMPLATE = """#!/bin/bash
set -e

# Install Docker
curl -fsSL https://get.docker.com | sh
usermod -aG docker gameserver
systemctl enable docker
systemctl start docker

# Create game server directory
mkdir -p /opt/gameserver/{server_key}
chown -R gameserver:gameserver /opt/gameserver

# Create docker-compose.yml
cat > /opt/gameserver/{server_key}/docker-compose.yml << 'EOF'
{docker_compose}
EOF

# Start the container
cd /opt/gameserver/{server_key}
docker compose up -d

echo "{game_name} installed successfully via Docker"
"""

# Game-specific installation scripts
INSTALL_SCRIPTS = {
    # ============================================
    # SOURCE ENGINE GAMES (LinuxGSM)
    # ============================================
    'cs2': {
        'name': 'Counter-Strike 2',
        'type': 'linuxgsm',
        'linuxgsm_name': 'cs2server',
        'post_install': """
# CS2 specific config
sudo -u gameserver cat >> /home/gameserver/lgsm/config-lgsm/cs2server/cs2server.cfg << 'EOF'
gslt=""
ip="0.0.0.0"
port="27015"
maxplayers="16"
EOF
"""
    },

    'csgo': {
        'name': 'Counter-Strike: Global Offensive',
        'type': 'linuxgsm',
        'linuxgsm_name': 'csgoserver',
    },

    'css': {
        'name': 'Counter-Strike: Source',
        'type': 'linuxgsm',
        'linuxgsm_name': 'cssserver',
    },

    'cs16': {
        'name': 'Counter-Strike 1.6',
        'type': 'linuxgsm',
        'linuxgsm_name': 'csserver',
    },

    'tf2': {
        'name': 'Team Fortress 2',
        'type': 'linuxgsm',
        'linuxgsm_name': 'tf2server',
    },

    'gmod': {
        'name': "Garry's Mod",
        'type': 'linuxgsm',
        'linuxgsm_name': 'gmodserver',
    },

    'l4d2': {
        'name': 'Left 4 Dead 2',
        'type': 'linuxgsm',
        'linuxgsm_name': 'l4d2server',
    },

    'blackmesa': {
        'name': 'Black Mesa',
        'type': 'linuxgsm',
        'linuxgsm_name': 'bmdmserver',
    },

    'svencoop': {
        'name': 'Sven Co-op',
        'type': 'linuxgsm',
        'linuxgsm_name': 'svenserver',
    },

    # ============================================
    # SURVIVAL GAMES
    # ============================================
    'valheim': {
        'name': 'Valheim',
        'type': 'docker',
        'docker_compose': """
services:
  valheim:
    image: lloesche/valheim-server
    container_name: valheim
    restart: unless-stopped
    stop_grace_period: 2m
    ports:
      - "2456-2458:2456-2458/udp"
    environment:
      - SERVER_NAME=Valheim Server
      - WORLD_NAME=Dedicated
      - SERVER_PASS=changeme
      - SERVER_PUBLIC=true
    volumes:
      - ./config:/config
      - ./data:/opt/valheim
"""
    },

    'rust': {
        'name': 'Rust',
        'type': 'linuxgsm',
        'linuxgsm_name': 'rustserver',
    },

    '7dtd': {
        'name': '7 Days to Die',
        'type': 'linuxgsm',
        'linuxgsm_name': 'sdtdserver',
    },

    'pz': {
        'name': 'Project Zomboid',
        'type': 'linuxgsm',
        'linuxgsm_name': 'pzserver',
    },

    'palworld': {
        'name': 'Palworld',
        'type': 'docker',
        'docker_compose': """
services:
  palworld:
    image: thijsvanloef/palworld-server-docker:latest
    container_name: palworld
    restart: unless-stopped
    ports:
      - "8211:8211/udp"
      - "27015:27015/udp"
    environment:
      - PUID=1000
      - PGID=1000
      - PORT=8211
      - PLAYERS=16
      - SERVER_NAME=Palworld Server
      - ADMIN_PASSWORD=changeme
      - SERVER_PASSWORD=
      - MULTITHREADING=true
    volumes:
      - ./palworld:/palworld
"""
    },

    'enshrouded': {
        'name': 'Enshrouded',
        'type': 'docker',
        'docker_compose': """
services:
  enshrouded:
    image: sknnr/enshrouded-dedicated-server:latest
    container_name: enshrouded
    restart: unless-stopped
    ports:
      - "15636-15637:15636-15637/udp"
    environment:
      - SERVER_NAME=Enshrouded Server
      - SERVER_PASSWORD=changeme
      - GAME_PORT=15636
      - QUERY_PORT=15637
      - SERVER_SLOTS=16
    volumes:
      - ./enshrouded:/home/steam/enshrouded
"""
    },

    'vrising': {
        'name': 'V Rising',
        'type': 'docker',
        'docker_compose': """
services:
  vrising:
    image: trueosiris/vrising:latest
    container_name: vrising
    restart: unless-stopped
    ports:
      - "9876-9877:9876-9877/udp"
    environment:
      - SERVERNAME=V Rising Server
      - WORLDNAME=world1
      - GAMEPORT=9876
      - QUERYPORT=9877
    volumes:
      - ./vrising/server:/mnt/vrising/server
      - ./vrising/data:/mnt/vrising/persistentdata
"""
    },

    'conan': {
        'name': 'Conan Exiles',
        'type': 'linuxgsm',
        'linuxgsm_name': 'ceserver',
    },

    'ark': {
        'name': 'ARK: Survival Evolved',
        'type': 'linuxgsm',
        'linuxgsm_name': 'arkserver',
    },

    'dst': {
        'name': "Don't Starve Together",
        'type': 'linuxgsm',
        'linuxgsm_name': 'dstserver',
    },

    'theisle': {
        'name': 'The Isle',
        'type': 'linuxgsm',
        'linuxgsm_name': 'tiserver',
    },

    'eco': {
        'name': 'Eco',
        'type': 'linuxgsm',
        'linuxgsm_name': 'ecoserver',
    },

    'barotrauma': {
        'name': 'Barotrauma',
        'type': 'linuxgsm',
        'linuxgsm_name': 'btserver',
    },

    'corekeeper': {
        'name': 'Core Keeper',
        'type': 'linuxgsm',
        'linuxgsm_name': 'ckserver',
    },

    'hurtworld': {
        'name': 'Hurtworld',
        'type': 'linuxgsm',
        'linuxgsm_name': 'hwserver',
    },

    'craftopia': {
        'name': 'Craftopia',
        'type': 'linuxgsm',
        'linuxgsm_name': 'ctserver',
    },

    'thefront': {
        'name': 'The Front',
        'type': 'linuxgsm',
        'linuxgsm_name': 'tfserver',
    },

    # ============================================
    # MILITARY SIMULATION
    # ============================================
    'dayz': {
        'name': 'DayZ',
        'type': 'linuxgsm',
        'linuxgsm_name': 'dayzserver',
    },

    'arma3': {
        'name': 'ARMA 3',
        'type': 'linuxgsm',
        'linuxgsm_name': 'arma3server',
    },

    'armareforger': {
        'name': 'Arma Reforger',
        'type': 'linuxgsm',
        'linuxgsm_name': 'armarserver',
    },

    'squad': {
        'name': 'Squad',
        'type': 'linuxgsm',
        'linuxgsm_name': 'squadserver',
    },

    'insurgency': {
        'name': 'Insurgency',
        'type': 'linuxgsm',
        'linuxgsm_name': 'insserver',
    },

    'insurgencysandstorm': {
        'name': 'Insurgency: Sandstorm',
        'type': 'linuxgsm',
        'linuxgsm_name': 'inssserver',
    },

    'doi': {
        'name': 'Day of Infamy',
        'type': 'linuxgsm',
        'linuxgsm_name': 'doiserver',
    },

    # ============================================
    # SANDBOX & BUILDING
    # ============================================
    'minecraft': {
        'name': 'Minecraft Java',
        'type': 'docker',
        'docker_compose': """
services:
  minecraft:
    image: itzg/minecraft-server
    container_name: minecraft
    restart: unless-stopped
    ports:
      - "25565:25565"
    environment:
      - EULA=TRUE
      - TYPE=PAPER
      - VERSION=LATEST
      - MEMORY=4G
      - MAX_PLAYERS=20
    volumes:
      - ./minecraft-data:/data
"""
    },

    'minecraftbedrock': {
        'name': 'Minecraft Bedrock',
        'type': 'docker',
        'docker_compose': """
services:
  minecraft-bedrock:
    image: itzg/minecraft-bedrock-server
    container_name: minecraft-bedrock
    restart: unless-stopped
    ports:
      - "19132:19132/udp"
    environment:
      - EULA=TRUE
      - SERVER_NAME=Bedrock Server
      - MAX_PLAYERS=10
      - GAMEMODE=survival
      - DIFFICULTY=normal
    volumes:
      - ./bedrock-data:/data
"""
    },

    'terraria': {
        'name': 'Terraria',
        'type': 'docker',
        'docker_compose': """
services:
  terraria:
    image: ryshe/terraria:latest
    container_name: terraria
    restart: unless-stopped
    ports:
      - "7777:7777"
    environment:
      - WORLD_FILENAME=world.wld
      - WORLD_SIZE=3
      - MAX_PLAYERS=8
      - PASSWORD=
    volumes:
      - ./terraria:/root/.local/share/Terraria/Worlds
    tty: true
    stdin_open: true
"""
    },

    'starbound': {
        'name': 'Starbound',
        'type': 'linuxgsm',
        'linuxgsm_name': 'sbserver',
    },

    'factorio': {
        'name': 'Factorio',
        'type': 'docker',
        'docker_compose': """
services:
  factorio:
    image: factoriotools/factorio:stable
    container_name: factorio
    restart: unless-stopped
    ports:
      - "34197:34197/udp"
      - "27015:27015/tcp"
    volumes:
      - ./factorio:/factorio
"""
    },

    'satisfactory': {
        'name': 'Satisfactory',
        'type': 'linuxgsm',
        'linuxgsm_name': 'sfserver',
    },

    'stationeers': {
        'name': 'Stationeers',
        'type': 'linuxgsm',
        'linuxgsm_name': 'stserver',
    },

    'avorion': {
        'name': 'Avorion',
        'type': 'linuxgsm',
        'linuxgsm_name': 'avserver',
    },

    # ============================================
    # ARENA & COMPETITIVE
    # ============================================
    'quake3': {
        'name': 'Quake III Arena',
        'type': 'linuxgsm',
        'linuxgsm_name': 'q3server',
    },

    'quakelive': {
        'name': 'Quake Live',
        'type': 'linuxgsm',
        'linuxgsm_name': 'qlserver',
    },

    'xonotic': {
        'name': 'Xonotic',
        'type': 'linuxgsm',
        'linuxgsm_name': 'xntserver',
    },

    'ut99': {
        'name': 'Unreal Tournament 99',
        'type': 'linuxgsm',
        'linuxgsm_name': 'ut99server',
    },

    'ut2k4': {
        'name': 'Unreal Tournament 2004',
        'type': 'linuxgsm',
        'linuxgsm_name': 'ut2k4server',
    },

    'chivalry': {
        'name': 'Chivalry: Medieval Warfare',
        'type': 'linuxgsm',
        'linuxgsm_name': 'cmwserver',
    },

    'mordhau': {
        'name': 'MORDHAU',
        'type': 'linuxgsm',
        'linuxgsm_name': 'mhserver',
    },

    'pavlovvr': {
        'name': 'Pavlov VR',
        'type': 'linuxgsm',
        'linuxgsm_name': 'pvrserver',
    },

    'teeworlds': {
        'name': 'Teeworlds',
        'type': 'linuxgsm',
        'linuxgsm_name': 'twserver',
    },

    # ============================================
    # CO-OP & MULTIPLAYER
    # ============================================
    'nmrih': {
        'name': 'No More Room in Hell',
        'type': 'linuxgsm',
        'linuxgsm_name': 'nmrihserver',
    },

    'ns2': {
        'name': 'Natural Selection 2',
        'type': 'linuxgsm',
        'linuxgsm_name': 'ns2server',
    },

    'scpsl': {
        'name': 'SCP: Secret Laboratory',
        'type': 'linuxgsm',
        'linuxgsm_name': 'scpslserver',
    },

    'towerunite': {
        'name': 'Tower Unite',
        'type': 'linuxgsm',
        'linuxgsm_name': 'tuserver',
    },

    # ============================================
    # ROLEPLAY
    # ============================================
    'mta': {
        'name': 'Multi Theft Auto',
        'type': 'linuxgsm',
        'linuxgsm_name': 'mtaserver',
    },

    'samp': {
        'name': 'SA-MP',
        'type': 'linuxgsm',
        'linuxgsm_name': 'sampserver',
    },

    'fivem': {
        'name': 'FiveM',
        'type': 'custom',
        'script': """#!/bin/bash
set -e

# Install FiveM/txAdmin
cd /home/gameserver
mkdir -p fivem
cd fivem

# Download server files
wget -O fx.tar.xz https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/latest/fx.tar.xz
tar xf fx.tar.xz
rm fx.tar.xz

# Create basic config
cat > server.cfg << 'EOFCFG'
# FiveM Server Configuration
sv_hostname "FiveM Server"
sv_maxclients 32
sv_endpointprivacy true
sv_licenseKey ""
EOFCFG

chown -R gameserver:gameserver /home/gameserver/fivem

# Create systemd service
cat > /etc/systemd/system/fivem.service << 'EOF'
[Unit]
Description=FiveM Server
After=network.target

[Service]
Type=simple
User=gameserver
WorkingDirectory=/home/gameserver/fivem
ExecStart=/home/gameserver/fivem/run.sh +exec server.cfg
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable fivem

echo "FiveM installed - add your license key to server.cfg before starting"
"""
    },

    # ============================================
    # CLASSIC GAMES
    # ============================================
    'kf': {
        'name': 'Killing Floor',
        'type': 'linuxgsm',
        'linuxgsm_name': 'kfserver',
    },

    'kf2': {
        'name': 'Killing Floor 2',
        'type': 'linuxgsm',
        'linuxgsm_name': 'kf2server',
    },

    'cod4': {
        'name': 'Call of Duty 4: Modern Warfare',
        'type': 'linuxgsm',
        'linuxgsm_name': 'cod4server',
    },

    'cod2': {
        'name': 'Call of Duty 2',
        'type': 'linuxgsm',
        'linuxgsm_name': 'cod2server',
    },

    'bf1942': {
        'name': 'Battlefield 1942',
        'type': 'linuxgsm',
        'linuxgsm_name': 'bf1942server',
    },

    'rtcw': {
        'name': 'Return to Castle Wolfenstein',
        'type': 'linuxgsm',
        'linuxgsm_name': 'rtcwserver',
    },

    'wolfet': {
        'name': 'Wolfenstein: Enemy Territory',
        'type': 'linuxgsm',
        'linuxgsm_name': 'etlserver',
    },

    'unturned': {
        'name': 'Unturned',
        'type': 'linuxgsm',
        'linuxgsm_name': 'untserver',
    },

    # ============================================
    # RACING
    # ============================================
    'ets2': {
        'name': 'Euro Truck Simulator 2',
        'type': 'linuxgsm',
        'linuxgsm_name': 'ets2server',
    },

    'ats': {
        'name': 'American Truck Simulator',
        'type': 'linuxgsm',
        'linuxgsm_name': 'atsserver',
    },

    'assettocorsa': {
        'name': 'Assetto Corsa',
        'type': 'docker',
        'docker_compose': """
services:
  assetto:
    image: seejy/assetto-server-manager:latest
    container_name: assetto
    restart: unless-stopped
    ports:
      - "8772:8772"
      - "9600:9600/udp"
      - "9600:9600/tcp"
    volumes:
      - ./assetto:/home/assetto/server-manager
"""
    },

    # ============================================
    # VOICE SERVERS
    # ============================================
    'teamspeak3': {
        'name': 'TeamSpeak 3',
        'type': 'docker',
        'docker_compose': """
services:
  teamspeak:
    image: teamspeak:latest
    container_name: teamspeak
    restart: unless-stopped
    ports:
      - "9987:9987/udp"
      - "10011:10011"
      - "30033:30033"
    environment:
      - TS3SERVER_LICENSE=accept
    volumes:
      - ./teamspeak:/var/ts3server
"""
    },

    # ============================================
    # MMO EMULATORS
    # ============================================
    'azerothcore': {
        'name': 'AzerothCore (WoW)',
        'type': 'docker',
        'docker_compose': """
services:
  ac-worldserver:
    image: acore/ac-wotlk-worldserver:latest
    container_name: ac-worldserver
    restart: unless-stopped
    ports:
      - "8085:8085"
      - "7878:7878"
    volumes:
      - ./azerothcore/worldserver:/azerothcore/env/dist
    depends_on:
      - ac-database

  ac-authserver:
    image: acore/ac-wotlk-authserver:latest
    container_name: ac-authserver
    restart: unless-stopped
    ports:
      - "3724:3724"
    volumes:
      - ./azerothcore/authserver:/azerothcore/env/dist
    depends_on:
      - ac-database

  ac-database:
    image: mysql:8.0
    container_name: ac-database
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=acore
    volumes:
      - ./azerothcore/mysql:/var/lib/mysql
"""
    },

    # ============================================
    # SERVER MANAGEMENT
    # ============================================
    'pterodactyl': {
        'name': 'Pterodactyl Panel',
        'type': 'custom',
        'script': """#!/bin/bash
set -e

# Install Pterodactyl Panel dependencies
apt-get install -y php8.1 php8.1-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} \\
    mariadb-server nginx redis-server composer

# Download and setup panel
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# Copy env file
cp .env.example .env

# Install composer dependencies
composer install --no-dev --optimize-autoloader --no-interaction

# Generate key
php artisan key:generate --force

echo "Pterodactyl Panel downloaded. Run 'php artisan p:environment:setup' to configure."
"""
    },

    'linuxgsm': {
        'name': 'LinuxGSM Manager',
        'type': 'custom',
        'script': """#!/bin/bash
set -e

# This installs LinuxGSM as a generic manager
# User can then install any of the 139 supported games
cd /home/gameserver
curl -Lo linuxgsm.sh https://linuxgsm.sh
chmod +x linuxgsm.sh
chown gameserver:gameserver linuxgsm.sh

echo "LinuxGSM downloaded. Run './linuxgsm.sh <servername>' to install a specific game."
echo "See https://linuxgsm.com/servers/ for the full list of 139 supported games."
"""
    },

    'amp': {
        'name': 'AMP (CubeCoders)',
        'type': 'custom',
        'script': """#!/bin/bash
set -e

# Install AMP
bash <(wget -qO- getamp.sh)

echo "AMP installed. Access the web interface to configure game servers."
echo "Default port: 8080"
"""
    },
}


def get_install_script(server_key: str, env_vars: dict = None) -> str:
    """
    Generate the complete installation script for a game server.

    Args:
        server_key: The game server key (e.g., 'valheim', 'minecraft')
        env_vars: Environment variables to inject into the script

    Returns:
        Complete bash script as a string
    """
    if server_key not in INSTALL_SCRIPTS:
        return None

    script_config = INSTALL_SCRIPTS[server_key]
    script_type = script_config.get('type')

    # Start with base setup
    full_script = BASE_SETUP_SCRIPT + "\n"

    if script_type == 'linuxgsm':
        # Generate LinuxGSM installation script
        linuxgsm_name = script_config['linuxgsm_name']
        game_name = script_config['name']

        full_script += LINUXGSM_INSTALL_TEMPLATE.format(
            linuxgsm_name=linuxgsm_name,
            game_name=game_name
        )

        # Add post-install if any
        if script_config.get('post_install'):
            full_script += "\n" + script_config['post_install']

    elif script_type == 'docker':
        # Generate Docker installation script
        docker_compose = script_config['docker_compose']
        game_name = script_config['name']

        # Apply env vars to docker-compose if provided
        if env_vars:
            for key, value in env_vars.items():
                docker_compose = docker_compose.replace(f'${{{key}}}', str(value))
                docker_compose = docker_compose.replace(f'changeme', str(value) if key == 'SERVER_PASSWORD' else 'changeme')

        full_script += DOCKER_INSTALL_TEMPLATE.format(
            server_key=server_key,
            game_name=game_name,
            docker_compose=docker_compose
        )

    elif script_type == 'custom':
        # Use custom script directly
        full_script += script_config['script']

    return full_script


def get_available_scripts() -> dict:
    """Get list of all available install scripts."""
    return {
        key: {
            'name': config['name'],
            'type': config['type']
        }
        for key, config in INSTALL_SCRIPTS.items()
    }
