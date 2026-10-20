# Architecture

The repo holds three independent ways to run game servers. They share game knowledge (ports, Steam
App IDs) but no code.

| Part | Where | Language | Runs on |
|---|---|---|---|
| Web deployer | `proxmox-deployer/` | Python (Flask) | Any machine that can reach Proxmox |
| Single-host scripts | `setup.sh`, `lib/common.sh`, `<game>/*.sh` | Bash | The Linux box that will host the game |
| Infrastructure as code | `infrastructure/` | Terraform, Packer, cloud-init | Your workstation, against Proxmox |

## Web deployer

```
browser ──HTTP──> Flask (routes.py) ──> SQLite (models.py)
                        │
                        ├──> game_servers.py      catalog: 217 entries, static dict
                        ├──> install_scripts.py   bash per game, 72 + generic linuxgsm
                        └──> proxmox_client.py
                                 ├── HTTPS :8006  proxmoxer → Proxmox API   create/start/stop/delete
                                 └── SSH :22      paramiko → Proxmox host   pct push / pct exec
```

| File | Owns |
|---|---|
| `app/__init__.py` | App factory, DB setup, and the `categories` context processor every page needs (the sidebar in `base.html` lists them) |
| `app/routes.py` | Every page and API endpoint (`docs/api.md`) |
| `app/models.py` | Three tables (`docs/data-model.md`) |
| `app/game_servers.py` | `GAME_SERVERS`, `CATEGORIES`, `STATS` and lookups. Pure data, no I/O |
| `app/install_scripts.py` | `INSTALL_SCRIPTS`, keyed by the same keys as `GAME_SERVERS`. `get_install_script()` glues a base setup, a LinuxGSM or Docker template, and any post-install step into one bash script |
| `app/proxmox_client.py` | Everything that talks to Proxmox |

### A deploy, end to end

1. `POST /api/deploy` looks the game up in `GAME_SERVERS` and merges the form values over its defaults.
2. A `Deployment` row is written with status `pending`, so a failure later still leaves a record.
3. `ProxmoxClient.create_lxc()` asks the API for the next free VMID, creates the container and waits
   for the Proxmox task to finish.
4. If the game has an install script, the deployer waits 5 s for the container to boot, then over SSH:
   uploads the script to the host's `/tmp`, `pct push`es it into the container and `pct exec`s it.
5. The row ends as `running`, `stopped`, `failed` (Proxmox refused) or `provision_failed` (the script
   exited non-zero; its stderr is in `error_message`).

**Why SSH and not the API for step 4:** the Proxmox API has no "run a command in an LXC container"
call. `pct exec` on the host is the only way in without putting an agent in the template. That is why
provisioning needs a password connection: an API token can't open an SSH session.

**Why the request blocks:** there is no job queue. Gunicorn runs 2 sync workers, so two long installs
at once make the UI unresponsive until one finishes. Moving provisioning to a background thread is on
the roadmap.

**The SSH commands run as root on the Proxmox host**, so `proxmox_client.py` casts every VMID to
`int` and passes user commands to `bash -c` as a single quoted argument. Without that, a `;` in a
command or VMID runs on the host instead of inside the container.

## Single-host scripts

`setup.sh` is a `dialog` menu over the per-game scripts. Each `<game>/<game>-server-setup.sh` sources
`lib/common.sh` (logging, package install, systemd unit helpers) and installs that one game as a
systemd service on the current machine. They don't know about Proxmox or the deployer.

## Infrastructure as code

Packer builds Ubuntu-with-Docker and Windows Server templates; Terraform clones them into VM groups,
one per game type, and cloud-init (`infrastructure/cloud-init/`) installs the runtime. See
`infrastructure/README.md`.
