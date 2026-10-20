# API

Every endpoint in `proxmox-deployer/app/routes.py`. All bodies are JSON. There is no authentication
(see `SECURITY.md`). Errors come back as `{"error": "<message>"}` with a 4xx or 5xx status.

## Examples

```bash
curl localhost:5555/api/stats
curl "localhost:5555/api/servers?search=valheim"
curl -X POST localhost:5555/api/deploy -H 'Content-Type: application/json'   -d '{"connection_id": 1, "server_key": "valheim", "node": "pve",
       "template": "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"}'
```

## Pages

| Path | Page |
|---|---|
| `GET /` | Dashboard |
| `GET /servers?category=<key>&search=<text>` | Game catalog |
| `GET /server/<server_key>` | One game, with the deploy form. 404 page if the key is unknown |
| `GET /deployments` | Deployment history |
| `GET /settings` | Proxmox connections and stored credentials |

## Catalog

| Endpoint | Returns |
|---|---|
| `GET /api/servers?category=<key>&search=<text>` | `{server_key: server}` for matching games |
| `GET /api/servers/<server_key>` | One server definition, or 404 |
| `GET /api/categories` | `{category_key: {name, icon, color}}` |
| `GET /api/stats` | `{"servers": {total_servers, lxc_servers, vm_servers, categories}, "deployments": {total, running, stopped, failed}}` |
| `GET /api/install-scripts` | `{server_key: {name, type}}` for every game that auto-installs |
| `GET /api/install-scripts/<server_key>` | `{server_key, script}`: the full bash script that would run, or 404 |

A server definition (`_server()` in `app/game_servers.py`):

```json
{"name": "Valheim", "hostname": "valheim-server", "description": "...", "category": "survival",
 "deployment_type": "lxc", "steam_app_id": 896660, "cores": 4, "memory": 8192, "disk_size": 30,
 "ports": [2456, 2457, 2458], "protocol": "UDP/TCP", "tags": ["survival"], "icon": "server",
 "linuxgsm_name": "vhserver", "docker_image": "cm2network/steamcmd", "privileged": false,
 "nesting": true, "env_vars": []}
```

`memory` is MB, `disk_size` is GB.

## Proxmox connections

| Endpoint | Body / returns |
|---|---|
| `GET /api/connections` | List. Passwords and tokens are never returned, only `has_password` / `has_token` |
| `POST /api/connections` | `{name, host, username, port?=8006, password?, token_name?, token_value?, verify_ssl?=false, is_default?}` → 201 |
| `PUT /api/connections/<id>` | Any of the fields above |
| `DELETE /api/connections/<id>` | `{"success": true}` |
| `POST /api/connections/<id>/test` | `{success, version, release}` or `{success: false, error}` |
| `GET /api/connections/<id>/nodes` | Proxmox nodes |
| `GET /api/connections/<id>/nodes/<node>/templates` | LXC templates and VM templates on that node |
| `GET /api/connections/<id>/nodes/<node>/storage` | Storage pools |
| `GET /api/connections/<id>/nodes/<node>/networks` | Bridges |

## Deploying

`POST /api/deploy`

```json
{"connection_id": 1, "server_key": "valheim", "node": "pve",
 "template": "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst",
 "hostname": "valheim-server", "cores": 4, "memory": 8192, "disk_size": 30,
 "storage": "local-lvm", "bridge": "vmbr0",
 "dhcp": true, "ip_address": null, "cidr": 24, "gateway": null,
 "start": true, "onboot": true, "ssh_public_keys": null, "env_vars": {}}
```

Only `connection_id`, `server_key`, `node` and `template` are required; the rest default to the
catalog entry or the values shown. A VM entry takes `template_vmid` instead of `template`.

The call blocks until the container exists, has started, and its install script (if any) has finished.
It returns the deployment record (see `docs/data-model.md`). If Proxmox can't be reached it returns 500
with `{"error", "deployment"}` and the record is saved with status `failed`.

## Deployments

| Endpoint | Does |
|---|---|
| `GET /api/deployments` | List, newest first |
| `GET /api/deployments/<id>` | One record |
| `POST /api/deployments/<id>/start` | Start the container/VM |
| `POST /api/deployments/<id>/stop` | Stop it |
| `GET /api/deployments/<id>/status` | Ask Proxmox and update the stored status |
| `POST /api/deployments/<id>/provision` | Re-run the install script. Needs a password connection |
| `DELETE /api/deployments/<id>` | Delete the container/VM in Proxmox and the record |

## Existing containers

Both need a connection with a password, because they work over SSH to the Proxmox host.

| Endpoint | Body |
|---|---|
| `POST /api/manage/provision` | `{connection_id, node, vmid, server_key, env_vars?, timeout?=600}`: install a game into a container that already exists, starting it first if needed |
| `POST /api/manage/exec` | `{connection_id, node, vmid, command, timeout?=60}`: run `bash -c <command>` inside the container. Returns its output and exit code |

## Stored credentials

| Endpoint | Body |
|---|---|
| `GET /api/credentials` | List, values never returned |
| `POST /api/credentials` | `{name, credential_type, value, description?}` → 201 |
| `PUT /api/credentials/<id>` | Any of the fields above |
| `DELETE /api/credentials/<id>` | `{"success": true}` |
