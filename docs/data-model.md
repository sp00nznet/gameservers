# Data model

The deployer owns one SQLite database (`DATABASE_URL`, default `proxmox-deployer/deployer.db`, or
`/data/deployer.db` in the Docker volume). Tables are created on startup by `db.create_all()`; there
are no migrations, so a new column means deleting the database or adding it by hand. Models live in
`proxmox-deployer/app/models.py`.

The game catalog is **not** in the database. It's the `GAME_SERVERS` dict in `app/game_servers.py`.

## `proxmox_connections`

| Column | Purpose |
|---|---|
| `id` | Primary key |
| `name` | Unique label shown in the UI |
| `host`, `port` | Proxmox API address, port default 8006 |
| `username` | e.g. `root@pam`. The part before `@` is also the SSH user for provisioning |
| `password` | **Plain text.** Used for the API ticket and for SSH. Needed for provisioning |
| `token_name`, `token_value` | API token alternative. **Plain text.** API calls only, no provisioning |
| `verify_ssl` | Off by default because Proxmox ships a self-signed certificate |
| `is_default` | Only one row has it set; setting it on one clears the others |
| `created_at`, `updated_at` | UTC timestamps |

## `deployments`

| Column | Purpose |
|---|---|
| `id` | Primary key |
| `connection_id` | → `proxmox_connections.id` |
| `server_key`, `server_name` | Catalog key and its display name at deploy time |
| `deployment_type` | `lxc` or `vm` |
| `node`, `vmid` | Where it lives in Proxmox. `vmid` is null if creation failed before Proxmox assigned one |
| `ip_address` | Only set for static IPs; DHCP addresses aren't looked up |
| `status` | `pending` → `provisioning` → `running` / `stopped`, or `failed` / `provision_failed` |
| `error_message` | Proxmox error or the install script's stderr |
| `config_snapshot` | JSON of the full config sent to Proxmox, so you can see what was asked for |
| `created_at`, `updated_at` | UTC timestamps |

## `credentials`

A place to keep Steam GSLT tokens, admin passwords and keys. Nothing reads these automatically yet;
they are for you to copy into a deploy's settings.

| Column | Purpose |
|---|---|
| `id` | Primary key |
| `name` | Unique label |
| `credential_type` | Free text; the UI offers `steam_token`, `password`, `ssh_key`, `api_key` |
| `value` | **Plain text.** Never returned by the API |
| `description` | Free text |
| `created_at`, `updated_at` | UTC timestamps |
