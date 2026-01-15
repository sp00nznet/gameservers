"""
Game Server Definitions for Proxmox Deployer
Comprehensive catalog of deployable game servers with configuration templates.
"""

# Server categories for organization
CATEGORIES = {
    'source': {'name': 'Source Engine', 'icon': 'cpu', 'color': '#ff9800'},
    'survival': {'name': 'Survival Games', 'icon': 'shield', 'color': '#4caf50'},
    'classic': {'name': 'Classic Games', 'icon': 'star', 'color': '#9c27b0'},
    'sandbox': {'name': 'Sandbox & Building', 'icon': 'box', 'color': '#2196f3'},
    'mmo': {'name': 'MMO Emulators', 'icon': 'users', 'color': '#e91e63'},
    'management': {'name': 'Server Management', 'icon': 'server', 'color': '#607d8b'},
    'rpg': {'name': 'RPG & Tabletop', 'icon': 'map', 'color': '#795548'},
    'windows': {'name': 'Windows Games', 'icon': 'monitor', 'color': '#00bcd4'},
}

# Game server definitions
GAME_SERVERS = {
    # ============================================
    # SOURCE ENGINE GAMES
    # ============================================
    'counterstrike16': {
        'name': 'Counter-Strike 1.6',
        'hostname': 'cs16-server',
        'description': 'Classic Counter-Strike 1.6 dedicated server via SteamCMD',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 90,
        'cores': 2,
        'memory': 2048,
        'disk_size': 20,
        'ports': [27015],
        'protocol': 'UDP/TCP',
        'tags': ['source', 'fps', 'steam', 'docker'],
        'icon': 'crosshair',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_TOKEN', 'description': 'Steam Game Server Login Token', 'required': False, 'secret': True},
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '32'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': 'de_dust2'},
        ],
        'setup_script': 'counterstrike16/cs16-server-setup.sh'
    },

    'counterstrike2': {
        'name': 'Counter-Strike 2',
        'hostname': 'cs2-server',
        'description': 'Counter-Strike 2 dedicated server (Source 2 engine)',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 730,
        'cores': 4,
        'memory': 8192,
        'disk_size': 50,
        'ports': [27015, 27020],
        'protocol': 'UDP/TCP',
        'tags': ['source2', 'fps', 'steam', 'docker'],
        'icon': 'crosshair',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_TOKEN', 'description': 'Steam Game Server Login Token (required)', 'required': True, 'secret': True},
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '16'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': 'de_dust2'},
            {'name': 'SRCDS_GAMETYPE', 'description': 'Game type (0=casual, 1=competitive)', 'default': '0'},
            {'name': 'SRCDS_GAMEMODE', 'description': 'Game mode', 'default': '0'},
        ],
        'setup_script': 'counterstrike2/cs2-server-setup.sh'
    },

    'teamfortress2': {
        'name': 'Team Fortress 2',
        'hostname': 'tf2-server',
        'description': 'Team Fortress 2 dedicated server',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 440,
        'cores': 4,
        'memory': 4096,
        'disk_size': 30,
        'ports': [27015],
        'protocol': 'UDP/TCP',
        'tags': ['source', 'fps', 'steam', 'docker'],
        'icon': 'users',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_TOKEN', 'description': 'Steam Game Server Login Token', 'required': False, 'secret': True},
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '24'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': 'ctf_2fort'},
        ],
        'setup_script': 'teamfortress2/tf2-server-setup.sh'
    },

    'teamfortressclassic': {
        'name': 'Team Fortress Classic',
        'hostname': 'tfc-server',
        'description': 'Team Fortress Classic dedicated server',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 20,
        'cores': 2,
        'memory': 2048,
        'disk_size': 15,
        'ports': [27015],
        'protocol': 'UDP/TCP',
        'tags': ['goldsrc', 'fps', 'steam', 'docker'],
        'icon': 'users',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_TOKEN', 'description': 'Steam Game Server Login Token', 'required': False, 'secret': True},
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '24'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': '2fort'},
        ],
        'setup_script': 'teamfortressclassic/tfc-server-setup.sh'
    },

    'halflifedm': {
        'name': 'Half-Life Deathmatch',
        'hostname': 'hldm-server',
        'description': 'Half-Life Deathmatch dedicated server',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 40,
        'cores': 2,
        'memory': 2048,
        'disk_size': 15,
        'ports': [27015],
        'protocol': 'UDP/TCP',
        'tags': ['goldsrc', 'fps', 'steam', 'docker'],
        'icon': 'target',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_TOKEN', 'description': 'Steam Game Server Login Token', 'required': False, 'secret': True},
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '16'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': 'crossfire'},
        ],
        'setup_script': 'halflifedm/hldm-server-setup.sh'
    },

    'halflife2dm': {
        'name': 'Half-Life 2: Deathmatch',
        'hostname': 'hl2dm-server',
        'description': 'Half-Life 2: Deathmatch dedicated server',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 320,
        'cores': 2,
        'memory': 4096,
        'disk_size': 25,
        'ports': [27015],
        'protocol': 'UDP/TCP',
        'tags': ['source', 'fps', 'steam', 'docker'],
        'icon': 'target',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_TOKEN', 'description': 'Steam Game Server Login Token', 'required': False, 'secret': True},
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '16'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': 'dm_lockdown'},
        ],
        'setup_script': 'halflife2dm/hl2dm-server-setup.sh'
    },

    'blackmesa': {
        'name': 'Black Mesa',
        'hostname': 'blackmesa-server',
        'description': 'Black Mesa Deathmatch dedicated server',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 346680,
        'cores': 4,
        'memory': 8192,
        'disk_size': 50,
        'ports': [27015],
        'protocol': 'UDP/TCP',
        'tags': ['source', 'fps', 'steam', 'docker'],
        'icon': 'target',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_TOKEN', 'description': 'Steam Game Server Login Token', 'required': False, 'secret': True},
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '16'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': 'dm_bounce'},
        ],
        'setup_script': 'blackmesa/blackmesa-server-setup.sh'
    },

    'svencoop': {
        'name': 'Sven Co-op',
        'hostname': 'svencoop-server',
        'description': 'Sven Co-op cooperative gameplay server',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 276060,
        'cores': 2,
        'memory': 4096,
        'disk_size': 25,
        'ports': [27015],
        'protocol': 'UDP/TCP',
        'tags': ['goldsrc', 'coop', 'steam', 'docker'],
        'icon': 'users',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '12'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': 'svencoop1'},
        ],
        'setup_script': 'svencoop/svencoop-server-setup.sh'
    },

    'synergy': {
        'name': 'Synergy',
        'hostname': 'synergy-server',
        'description': 'Synergy cooperative Half-Life 2 server',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 17520,
        'cores': 2,
        'memory': 4096,
        'disk_size': 30,
        'ports': [27015],
        'protocol': 'UDP/TCP',
        'tags': ['source', 'coop', 'steam', 'docker'],
        'icon': 'users',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '8'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': 'd1_trainstation_01'},
        ],
        'setup_script': 'synergy/synergy-server-setup.sh'
    },

    'garrysmod': {
        'name': "Garry's Mod",
        'hostname': 'gmod-server',
        'description': "Garry's Mod sandbox dedicated server",
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 4020,
        'cores': 4,
        'memory': 8192,
        'disk_size': 50,
        'ports': [27015, 27005],
        'protocol': 'UDP/TCP',
        'tags': ['source', 'sandbox', 'steam', 'docker'],
        'icon': 'box',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_TOKEN', 'description': 'Steam Game Server Login Token', 'required': True, 'secret': True},
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '24'},
            {'name': 'SRCDS_MAP', 'description': 'Starting map', 'default': 'gm_construct'},
            {'name': 'SRCDS_GAMEMODE', 'description': 'Game mode', 'default': 'sandbox'},
        ],
        'setup_script': 'garrysmod/gmod-server-setup.sh'
    },

    # ============================================
    # SURVIVAL GAMES
    # ============================================
    'projectzomboid': {
        'name': 'Project Zomboid',
        'hostname': 'pz-server',
        'description': 'Project Zomboid multiplayer survival server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 380870,
        'cores': 4,
        'memory': 8192,
        'disk_size': 50,
        'ports': [16261, 16262],
        'protocol': 'UDP',
        'tags': ['survival', 'zombie', 'steam', 'docker'],
        'icon': 'shield',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'PZ_SERVER_NAME', 'description': 'Server name', 'default': 'Zomboid Server'},
            {'name': 'PZ_SERVER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'PZ_ADMIN_PASSWORD', 'description': 'Admin password', 'required': True, 'secret': True},
            {'name': 'PZ_MAX_PLAYERS', 'description': 'Maximum players', 'default': '16'},
        ],
        'setup_script': 'projectzomboid/pz-server-setup.sh'
    },

    'abioticfactor': {
        'name': 'Abiotic Factor',
        'hostname': 'abiotic-server',
        'description': 'Abiotic Factor cooperative survival server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 427410,
        'cores': 4,
        'memory': 8192,
        'disk_size': 40,
        'ports': [7777, 27015],
        'protocol': 'UDP',
        'tags': ['survival', 'coop', 'steam', 'docker'],
        'icon': 'shield',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'Abiotic Factor Server'},
            {'name': 'SERVER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '6'},
        ],
        'setup_script': 'abioticfactor/abiotic-server-setup.sh'
    },

    'humanitz': {
        'name': 'HumanitZ',
        'hostname': 'humanitz-server',
        'description': 'HumanitZ open world survival server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 2477680,
        'cores': 4,
        'memory': 8192,
        'disk_size': 40,
        'ports': [7777, 7778, 27015],
        'protocol': 'UDP',
        'tags': ['survival', 'zombie', 'steam', 'docker'],
        'icon': 'shield',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'HumanitZ Server'},
            {'name': 'SERVER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '32'},
        ],
        'setup_script': 'humanitz/humanitz-server-setup.sh'
    },

    'valheim': {
        'name': 'Valheim',
        'hostname': 'valheim-server',
        'description': 'Valheim Viking survival dedicated server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 896660,
        'cores': 4,
        'memory': 8192,
        'disk_size': 30,
        'ports': [2456, 2457, 2458],
        'protocol': 'UDP',
        'tags': ['survival', 'viking', 'steam', 'docker'],
        'icon': 'anchor',
        'docker_image': 'lloesche/valheim-server',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'Valheim Server'},
            {'name': 'SERVER_PASSWORD', 'description': 'Server password (min 5 chars)', 'required': True, 'secret': True},
            {'name': 'WORLD_NAME', 'description': 'World name', 'default': 'Dedicated'},
            {'name': 'SERVER_PUBLIC', 'description': 'Public server (1=yes, 0=no)', 'default': '0'},
        ],
        'setup_script': None  # Uses Docker directly
    },

    '7daystodie': {
        'name': '7 Days to Die',
        'hostname': '7dtd-server',
        'description': '7 Days to Die zombie survival server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 294420,
        'cores': 4,
        'memory': 8192,
        'disk_size': 50,
        'ports': [26900, 26901, 26902],
        'protocol': 'UDP/TCP',
        'tags': ['survival', 'zombie', 'steam', 'docker'],
        'icon': 'calendar',
        'docker_image': 'vinanrra/7dtd-server',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': '7DTD Server'},
            {'name': 'SERVER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '8'},
            {'name': 'GAME_DIFFICULTY', 'description': 'Difficulty (0-5)', 'default': '2'},
        ],
        'setup_script': None
    },

    'rust': {
        'name': 'Rust',
        'hostname': 'rust-server',
        'description': 'Rust survival dedicated server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 258550,
        'cores': 4,
        'memory': 16384,
        'disk_size': 50,
        'ports': [28015, 28016, 28082],
        'protocol': 'UDP/TCP',
        'tags': ['survival', 'pvp', 'steam', 'docker'],
        'icon': 'tool',
        'docker_image': 'didstopia/rust-server',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'RUST_SERVER_NAME', 'description': 'Server name', 'default': 'Rust Server'},
            {'name': 'RUST_SERVER_SEED', 'description': 'World seed', 'default': '12345'},
            {'name': 'RUST_SERVER_WORLDSIZE', 'description': 'World size', 'default': '3500'},
            {'name': 'RUST_SERVER_MAXPLAYERS', 'description': 'Maximum players', 'default': '50'},
        ],
        'setup_script': None
    },

    # ============================================
    # SANDBOX & BUILDING GAMES
    # ============================================
    'minecraft': {
        'name': 'Minecraft Java',
        'hostname': 'minecraft-server',
        'description': 'Minecraft Java Edition dedicated server',
        'category': 'sandbox',
        'deployment_type': 'lxc',
        'steam_app_id': None,
        'cores': 4,
        'memory': 8192,
        'disk_size': 30,
        'ports': [25565, 25575],
        'protocol': 'TCP',
        'tags': ['sandbox', 'building', 'java', 'docker'],
        'icon': 'box',
        'docker_image': 'itzg/minecraft-server',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'EULA', 'description': 'Accept EULA', 'default': 'TRUE'},
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'Minecraft Server'},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '20'},
            {'name': 'MEMORY', 'description': 'Java memory', 'default': '4G'},
            {'name': 'TYPE', 'description': 'Server type (VANILLA, PAPER, FORGE, FABRIC)', 'default': 'PAPER'},
            {'name': 'VERSION', 'description': 'Minecraft version', 'default': 'LATEST'},
        ],
        'setup_script': None
    },

    'minecraftbedrock': {
        'name': 'Minecraft Bedrock',
        'hostname': 'bedrock-server',
        'description': 'Minecraft Bedrock Edition dedicated server',
        'category': 'sandbox',
        'deployment_type': 'lxc',
        'steam_app_id': None,
        'cores': 2,
        'memory': 4096,
        'disk_size': 20,
        'ports': [19132],
        'protocol': 'UDP',
        'tags': ['sandbox', 'building', 'bedrock', 'docker'],
        'icon': 'box',
        'docker_image': 'itzg/minecraft-bedrock-server',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'EULA', 'description': 'Accept EULA', 'default': 'TRUE'},
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'Bedrock Server'},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '10'},
            {'name': 'GAMEMODE', 'description': 'Game mode (survival, creative, adventure)', 'default': 'survival'},
            {'name': 'DIFFICULTY', 'description': 'Difficulty (peaceful, easy, normal, hard)', 'default': 'normal'},
        ],
        'setup_script': None
    },

    'terraria': {
        'name': 'Terraria',
        'hostname': 'terraria-server',
        'description': 'Terraria dedicated server',
        'category': 'sandbox',
        'deployment_type': 'lxc',
        'steam_app_id': 105600,
        'cores': 2,
        'memory': 2048,
        'disk_size': 15,
        'ports': [7777],
        'protocol': 'TCP',
        'tags': ['sandbox', '2d', 'steam', 'docker'],
        'icon': 'box',
        'docker_image': 'ryshe/terraria',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'WORLD_NAME', 'description': 'World name', 'default': 'world'},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '8'},
            {'name': 'PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'DIFFICULTY', 'description': 'Difficulty (0=classic, 1=expert, 2=master, 3=journey)', 'default': '0'},
        ],
        'setup_script': None
    },

    'starbound': {
        'name': 'Starbound',
        'hostname': 'starbound-server',
        'description': 'Starbound dedicated server',
        'category': 'sandbox',
        'deployment_type': 'lxc',
        'steam_app_id': 211820,
        'cores': 2,
        'memory': 4096,
        'disk_size': 25,
        'ports': [21025],
        'protocol': 'TCP',
        'tags': ['sandbox', '2d', 'steam', 'docker'],
        'icon': 'star',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'Starbound Server'},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '8'},
        ],
        'setup_script': 'starbound/starbound-server-setup.sh'
    },

    'satisfactory': {
        'name': 'Satisfactory',
        'hostname': 'satisfactory-server',
        'description': 'Satisfactory dedicated server',
        'category': 'sandbox',
        'deployment_type': 'lxc',
        'steam_app_id': 1690800,
        'cores': 4,
        'memory': 16384,
        'disk_size': 50,
        'ports': [7777, 15000, 15777],
        'protocol': 'UDP',
        'tags': ['sandbox', 'building', 'steam', 'docker'],
        'icon': 'settings',
        'docker_image': 'wolveix/satisfactory-server',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'MAXPLAYERS', 'description': 'Maximum players', 'default': '4'},
            {'name': 'AUTOPAUSE', 'description': 'Auto-pause when empty', 'default': 'true'},
            {'name': 'AUTOSAVEINTERVAL', 'description': 'Autosave interval (seconds)', 'default': '300'},
        ],
        'setup_script': None
    },

    # ============================================
    # CLASSIC GAMES
    # ============================================
    'killingfloor': {
        'name': 'Killing Floor',
        'hostname': 'kf-server',
        'description': 'Killing Floor cooperative server',
        'category': 'classic',
        'deployment_type': 'lxc',
        'steam_app_id': 1250,
        'cores': 2,
        'memory': 2048,
        'disk_size': 20,
        'ports': [7707, 7708, 7717, 28852],
        'protocol': 'UDP',
        'tags': ['coop', 'zombie', 'steam', 'docker'],
        'icon': 'zap',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'KF_SERVER_NAME', 'description': 'Server name', 'default': 'Killing Floor Server'},
            {'name': 'KF_GAME_PASSWORD', 'description': 'Game password', 'required': False, 'secret': True},
            {'name': 'KF_ADMIN_PASSWORD', 'description': 'Admin password', 'required': True, 'secret': True},
        ],
        'setup_script': 'killingfloor/kf-server-setup.sh'
    },

    'killingfloor2': {
        'name': 'Killing Floor 2',
        'hostname': 'kf2-server',
        'description': 'Killing Floor 2 cooperative server',
        'category': 'classic',
        'deployment_type': 'lxc',
        'steam_app_id': 232090,
        'cores': 4,
        'memory': 4096,
        'disk_size': 40,
        'ports': [7777, 27015, 8080, 20560],
        'protocol': 'UDP/TCP',
        'tags': ['coop', 'zombie', 'steam', 'docker'],
        'icon': 'zap',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'KF2_SERVER_NAME', 'description': 'Server name', 'default': 'Killing Floor 2 Server'},
            {'name': 'KF2_GAME_PASSWORD', 'description': 'Game password', 'required': False, 'secret': True},
            {'name': 'KF2_ADMIN_PASSWORD', 'description': 'Admin password', 'required': True, 'secret': True},
            {'name': 'KF2_DIFFICULTY', 'description': 'Difficulty (0=Normal, 1=Hard, 2=Suicidal, 3=HOE)', 'default': '1'},
        ],
        'setup_script': 'killingfloor2/kf2-server-setup.sh'
    },

    'ut99': {
        'name': 'Unreal Tournament 99',
        'hostname': 'ut99-server',
        'description': 'Unreal Tournament GOTY dedicated server',
        'category': 'classic',
        'deployment_type': 'lxc',
        'steam_app_id': 41150,
        'cores': 2,
        'memory': 1024,
        'disk_size': 15,
        'ports': [7777, 7778, 7779, 27900],
        'protocol': 'UDP',
        'tags': ['arena', 'fps', 'steam', 'docker'],
        'icon': 'crosshair',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'UT_SERVER_NAME', 'description': 'Server name', 'default': 'UT99 Server'},
            {'name': 'UT_ADMIN_PASSWORD', 'description': 'Admin password', 'required': True, 'secret': True},
            {'name': 'UT_GAME_PASSWORD', 'description': 'Game password', 'required': False, 'secret': True},
        ],
        'setup_script': 'ut99/ut99-server-setup.sh'
    },

    'ut2004': {
        'name': 'Unreal Tournament 2004',
        'hostname': 'ut2004-server',
        'description': 'Unreal Tournament 2004 dedicated server',
        'category': 'classic',
        'deployment_type': 'lxc',
        'steam_app_id': 13230,
        'cores': 2,
        'memory': 2048,
        'disk_size': 20,
        'ports': [7777, 7778, 7787, 28902],
        'protocol': 'UDP',
        'tags': ['arena', 'fps', 'steam', 'docker'],
        'icon': 'crosshair',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'UT_SERVER_NAME', 'description': 'Server name', 'default': 'UT2004 Server'},
            {'name': 'UT_ADMIN_PASSWORD', 'description': 'Admin password', 'required': True, 'secret': True},
            {'name': 'UT_GAME_PASSWORD', 'description': 'Game password', 'required': False, 'secret': True},
        ],
        'setup_script': 'ut2004/ut2004-server-setup.sh'
    },

    'samp': {
        'name': 'San Andreas Multiplayer',
        'hostname': 'samp-server',
        'description': 'SA-MP (GTA San Andreas Multiplayer) server',
        'category': 'classic',
        'deployment_type': 'lxc',
        'steam_app_id': None,
        'cores': 2,
        'memory': 2048,
        'disk_size': 10,
        'ports': [7777],
        'protocol': 'UDP',
        'tags': ['gta', 'multiplayer', 'docker'],
        'icon': 'truck',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SAMP_SERVER_NAME', 'description': 'Server name', 'default': 'SA-MP Server'},
            {'name': 'SAMP_MAX_PLAYERS', 'description': 'Maximum players', 'default': '50'},
            {'name': 'SAMP_RCON_PASSWORD', 'description': 'RCON password', 'required': True, 'secret': True},
        ],
        'setup_script': 'samp/samp-server-setup.sh'
    },

    'quake3': {
        'name': 'Quake III Arena',
        'hostname': 'q3-server',
        'description': 'Quake III Arena dedicated server',
        'category': 'classic',
        'deployment_type': 'lxc',
        'steam_app_id': None,
        'cores': 1,
        'memory': 512,
        'disk_size': 5,
        'ports': [27960],
        'protocol': 'UDP',
        'tags': ['arena', 'fps', 'docker'],
        'icon': 'crosshair',
        'docker_image': 'jberrenberg/quake3',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'Q3_SERVER_NAME', 'description': 'Server name', 'default': 'Quake 3 Server'},
            {'name': 'Q3_MAX_CLIENTS', 'description': 'Maximum players', 'default': '16'},
        ],
        'setup_script': None
    },

    # ============================================
    # ARK & DINOSAUR GAMES
    # ============================================
    'arkasa': {
        'name': 'ARK: Survival Ascended',
        'hostname': 'ark-asa-server',
        'description': 'ARK: Survival Ascended dedicated server (via Proton)',
        'category': 'survival',
        'deployment_type': 'vm',
        'steam_app_id': 2430930,
        'cores': 6,
        'memory': 32768,
        'disk_size': 150,
        'ports': [7777, 7778, 27015, 27020],
        'protocol': 'UDP',
        'tags': ['survival', 'dinosaur', 'steam', 'proton'],
        'icon': 'sun',
        'privileged': False,
        'template_type': 'ubuntu-docker',
        'env_vars': [
            {'name': 'ARK_SESSION_NAME', 'description': 'Server name', 'default': 'ARK Server'},
            {'name': 'ARK_SERVER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'ARK_ADMIN_PASSWORD', 'description': 'Admin password', 'required': True, 'secret': True},
            {'name': 'ARK_MAX_PLAYERS', 'description': 'Maximum players', 'default': '70'},
            {'name': 'ARK_MAP', 'description': 'Map name', 'default': 'TheIsland_WP'},
        ],
        'setup_script': 'ark-asa/ark-asa-server-setup.sh'
    },

    # ============================================
    # MMO EMULATORS
    # ============================================
    'azerothcore': {
        'name': 'AzerothCore (WoW 3.3.5a)',
        'hostname': 'wow-server',
        'description': 'World of Warcraft WotLK 3.3.5a private server emulator',
        'category': 'mmo',
        'deployment_type': 'vm',
        'steam_app_id': None,
        'cores': 8,
        'memory': 16384,
        'disk_size': 100,
        'ports': [8085, 3724, 7878],
        'protocol': 'TCP',
        'tags': ['mmo', 'wow', 'emulator', 'compiled'],
        'icon': 'globe',
        'privileged': False,
        'template_type': 'ubuntu-docker',
        'env_vars': [
            {'name': 'REALM_NAME', 'description': 'Realm name', 'default': 'AzerothCore'},
            {'name': 'EXTERNAL_ADDRESS', 'description': 'External IP/hostname', 'required': True},
            {'name': 'DB_ROOT_PASSWORD', 'description': 'MariaDB root password', 'required': True, 'secret': True},
        ],
        'setup_script': 'azerothcore/wow-server-setup.sh'
    },

    'swgemu': {
        'name': 'SWGEmu (Pre-CU)',
        'hostname': 'swgemu-server',
        'description': 'Star Wars Galaxies Pre-Combat Upgrade emulator',
        'category': 'mmo',
        'deployment_type': 'vm',
        'steam_app_id': None,
        'cores': 8,
        'memory': 16384,
        'disk_size': 100,
        'ports': [44453, 44454, 44455, 44460, 44461, 44462, 44463],
        'protocol': 'TCP/UDP',
        'tags': ['mmo', 'starwars', 'emulator', 'compiled'],
        'icon': 'star',
        'privileged': False,
        'template_type': 'ubuntu-docker',
        'env_vars': [
            {'name': 'GALAXY_NAME', 'description': 'Galaxy name', 'default': 'SWGEmu'},
            {'name': 'DB_ROOT_PASSWORD', 'description': 'MySQL root password', 'required': True, 'secret': True},
        ],
        'setup_script': 'swgemu/swgemu-server-setup.sh'
    },

    # ============================================
    # WINDOWS GAMES (VM REQUIRED)
    # ============================================
    'cityofheroes': {
        'name': 'City of Heroes',
        'hostname': 'coh-server',
        'description': 'City of Heroes Homecoming/Ouroboros server',
        'category': 'windows',
        'deployment_type': 'vm',
        'steam_app_id': None,
        'cores': 4,
        'memory': 8192,
        'disk_size': 100,
        'ports': [2104, 2105, 2106, 7000, 7001, 7002, 11228],
        'protocol': 'TCP/UDP',
        'tags': ['mmo', 'superhero', 'windows'],
        'icon': 'zap',
        'privileged': False,
        'template_type': 'windows-server',
        'env_vars': [
            {'name': 'COH_SHARD_NAME', 'description': 'Shard name', 'default': 'Homecoming'},
            {'name': 'COH_DB_PASSWORD', 'description': 'Database password', 'required': True, 'secret': True},
        ],
        'setup_script': 'cityofheroes/coh-server-setup.sh'
    },

    # ============================================
    # SERVER MANAGEMENT PANELS
    # ============================================
    'pterodactyl': {
        'name': 'Pterodactyl Panel',
        'hostname': 'pterodactyl',
        'description': 'Game server management panel with web UI',
        'category': 'management',
        'deployment_type': 'lxc',
        'steam_app_id': None,
        'cores': 2,
        'memory': 4096,
        'disk_size': 30,
        'ports': [80, 443, 8080, 2022],
        'protocol': 'TCP',
        'tags': ['panel', 'management', 'docker'],
        'icon': 'layers',
        'docker_image': 'ghcr.io/pterodactyl/panel:latest',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'APP_URL', 'description': 'Panel URL', 'default': 'http://localhost'},
            {'name': 'DB_PASSWORD', 'description': 'Database password', 'required': True, 'secret': True},
            {'name': 'APP_TIMEZONE', 'description': 'Timezone', 'default': 'UTC'},
        ],
        'setup_script': None
    },

    'crafty': {
        'name': 'Crafty Controller',
        'hostname': 'crafty',
        'description': 'Minecraft server management panel',
        'category': 'management',
        'deployment_type': 'lxc',
        'steam_app_id': None,
        'cores': 2,
        'memory': 2048,
        'disk_size': 20,
        'ports': [8443, 8123, 25500, 25565],
        'protocol': 'TCP',
        'tags': ['panel', 'minecraft', 'management', 'docker'],
        'icon': 'layers',
        'docker_image': 'registry.gitlab.com/crafty-controller/crafty-4:latest',
        'privileged': False,
        'nesting': True,
        'env_vars': [],
        'setup_script': None
    },

    'amp': {
        'name': 'AMP (CubeCoders)',
        'hostname': 'amp',
        'description': 'Application Management Panel for game servers',
        'category': 'management',
        'deployment_type': 'lxc',
        'steam_app_id': None,
        'cores': 2,
        'memory': 4096,
        'disk_size': 50,
        'ports': [8080, 8081],
        'protocol': 'TCP',
        'tags': ['panel', 'management', 'commercial'],
        'icon': 'layers',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'AMP_LICENCE', 'description': 'AMP licence key', 'required': True, 'secret': True},
            {'name': 'AMP_USERNAME', 'description': 'Admin username', 'default': 'admin'},
            {'name': 'AMP_PASSWORD', 'description': 'Admin password', 'required': True, 'secret': True},
        ],
        'setup_script': None
    },

    # ============================================
    # RPG & TABLETOP
    # ============================================
    'foundryvtt': {
        'name': 'Foundry VTT',
        'hostname': 'foundry',
        'description': 'Virtual tabletop for RPGs (D&D, Pathfinder, etc.)',
        'category': 'rpg',
        'deployment_type': 'lxc',
        'steam_app_id': None,
        'cores': 2,
        'memory': 2048,
        'disk_size': 20,
        'ports': [30000],
        'protocol': 'TCP',
        'tags': ['vtt', 'tabletop', 'rpg', 'docker'],
        'icon': 'map',
        'docker_image': 'felddy/foundryvtt',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'FOUNDRY_USERNAME', 'description': 'Foundry account username', 'required': True},
            {'name': 'FOUNDRY_PASSWORD', 'description': 'Foundry account password', 'required': True, 'secret': True},
            {'name': 'FOUNDRY_ADMIN_KEY', 'description': 'Admin access key', 'required': True, 'secret': True},
        ],
        'setup_script': None
    },

    # ============================================
    # ADDITIONAL POPULAR GAMES
    # ============================================
    'palworld': {
        'name': 'Palworld',
        'hostname': 'palworld-server',
        'description': 'Palworld dedicated server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 2394010,
        'cores': 4,
        'memory': 16384,
        'disk_size': 50,
        'ports': [8211, 27015],
        'protocol': 'UDP',
        'tags': ['survival', 'creature', 'steam', 'docker'],
        'icon': 'heart',
        'docker_image': 'thijsvanloef/palworld-server-docker',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'Palworld Server'},
            {'name': 'SERVER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'ADMIN_PASSWORD', 'description': 'Admin password', 'required': True, 'secret': True},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '32'},
        ],
        'setup_script': None
    },

    'enshrouded': {
        'name': 'Enshrouded',
        'hostname': 'enshrouded-server',
        'description': 'Enshrouded survival dedicated server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 2278520,
        'cores': 4,
        'memory': 16384,
        'disk_size': 50,
        'ports': [15636, 15637],
        'protocol': 'UDP',
        'tags': ['survival', 'building', 'steam', 'docker'],
        'icon': 'cloud',
        'docker_image': 'sknnr/enshrouded-dedicated-server',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'Enshrouded Server'},
            {'name': 'SERVER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '16'},
        ],
        'setup_script': None
    },

    'vrising': {
        'name': 'V Rising',
        'hostname': 'vrising-server',
        'description': 'V Rising vampire survival server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 1829350,
        'cores': 4,
        'memory': 8192,
        'disk_size': 30,
        'ports': [9876, 9877],
        'protocol': 'UDP',
        'tags': ['survival', 'vampire', 'steam', 'docker'],
        'icon': 'moon',
        'docker_image': 'trueosiris/vrising',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'V Rising Server'},
            {'name': 'SERVER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'MAX_USERS', 'description': 'Maximum players', 'default': '40'},
            {'name': 'GAME_PRESET', 'description': 'Game preset', 'default': 'StandardPvP'},
        ],
        'setup_script': None
    },

    'conanexiles': {
        'name': 'Conan Exiles',
        'hostname': 'conan-server',
        'description': 'Conan Exiles survival server',
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 443030,
        'cores': 4,
        'memory': 12288,
        'disk_size': 50,
        'ports': [7777, 7778, 27015],
        'protocol': 'UDP',
        'tags': ['survival', 'building', 'steam', 'docker'],
        'icon': 'sword',
        'docker_image': 'alinmear/docker-conanexiles',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'Conan Exiles Server'},
            {'name': 'SERVER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
            {'name': 'ADMIN_PASSWORD', 'description': 'Admin password', 'required': True, 'secret': True},
            {'name': 'MAX_PLAYERS', 'description': 'Maximum players', 'default': '40'},
        ],
        'setup_script': None
    },

    'factorio': {
        'name': 'Factorio',
        'hostname': 'factorio-server',
        'description': 'Factorio dedicated server',
        'category': 'sandbox',
        'deployment_type': 'lxc',
        'steam_app_id': None,
        'cores': 2,
        'memory': 4096,
        'disk_size': 20,
        'ports': [34197],
        'protocol': 'UDP',
        'tags': ['building', 'automation', 'docker'],
        'icon': 'settings',
        'docker_image': 'factoriotools/factorio',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SERVER_NAME', 'description': 'Server name', 'default': 'Factorio Server'},
            {'name': 'GAME_PASSWORD', 'description': 'Game password', 'required': False, 'secret': True},
        ],
        'setup_script': None
    },

    'dontstarvetogether': {
        'name': "Don't Starve Together",
        'hostname': 'dst-server',
        'description': "Don't Starve Together dedicated server",
        'category': 'survival',
        'deployment_type': 'lxc',
        'steam_app_id': 343050,
        'cores': 2,
        'memory': 4096,
        'disk_size': 20,
        'ports': [10999, 10998],
        'protocol': 'UDP',
        'tags': ['survival', 'coop', 'steam', 'docker'],
        'icon': 'sun',
        'docker_image': 'jamesits/dst-server',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'DST_CLUSTER_TOKEN', 'description': 'Klei server token', 'required': True, 'secret': True},
            {'name': 'DST_CLUSTER_NAME', 'description': 'Server name', 'default': 'DST Server'},
            {'name': 'DST_CLUSTER_PASSWORD', 'description': 'Server password', 'required': False, 'secret': True},
        ],
        'setup_script': None
    },

    'l4d2': {
        'name': 'Left 4 Dead 2',
        'hostname': 'l4d2-server',
        'description': 'Left 4 Dead 2 dedicated server',
        'category': 'source',
        'deployment_type': 'lxc',
        'steam_app_id': 222860,
        'cores': 2,
        'memory': 4096,
        'disk_size': 30,
        'ports': [27015],
        'protocol': 'UDP/TCP',
        'tags': ['source', 'coop', 'zombie', 'steam', 'docker'],
        'icon': 'users',
        'docker_image': 'cm2network/steamcmd',
        'privileged': False,
        'nesting': True,
        'env_vars': [
            {'name': 'SRCDS_TOKEN', 'description': 'Steam Game Server Login Token', 'required': False, 'secret': True},
            {'name': 'SRCDS_MAXPLAYERS', 'description': 'Maximum players', 'default': '8'},
        ],
        'setup_script': None
    },
}


def get_servers_by_category(category: str = None):
    """Get game servers optionally filtered by category."""
    if category:
        return {k: v for k, v in GAME_SERVERS.items() if v.get('category') == category}
    return GAME_SERVERS


def get_server(key: str):
    """Get a specific game server definition."""
    return GAME_SERVERS.get(key)


def get_categories():
    """Get all available categories."""
    return CATEGORIES


def search_servers(query: str):
    """Search servers by name, description, or tags."""
    query = query.lower()
    results = {}
    for key, server in GAME_SERVERS.items():
        if (query in server['name'].lower() or
            query in server.get('description', '').lower() or
            any(query in tag for tag in server.get('tags', []))):
            results[key] = server
    return results


# Summary statistics
STATS = {
    'total_servers': len(GAME_SERVERS),
    'lxc_servers': len([s for s in GAME_SERVERS.values() if s['deployment_type'] == 'lxc']),
    'vm_servers': len([s for s in GAME_SERVERS.values() if s['deployment_type'] == 'vm']),
    'categories': len(CATEGORIES),
}
