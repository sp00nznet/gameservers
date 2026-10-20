# Running the deployer

## Deploy

Docker is the supported way to run it long term:

```bash
cd proxmox-deployer
cp .env.example .env        # then set SECRET_KEY to a long random string
docker compose up --build -d
```

It listens on port 5555 and keeps its database in the `deployer_data` volume at `/data/deployer.db`.
`start.sh docker`, `start.bat` and `start.ps1` do the same with friendlier output.

Without Docker: `./start.sh prod` creates a venv and runs Gunicorn with 2 workers on `0.0.0.0:5555`.

## Configure

| Variable | Default | Notes |
|---|---|---|
| `SECRET_KEY` | `dev-key-change-in-production` | Signs Flask sessions. Set it |
| `DATABASE_URL` | `sqlite:///<repo>/proxmox-deployer/deployer.db` | Docker sets `sqlite:////data/deployer.db` |
| `FLASK_DEBUG` | unset | `1` turns on auto-reload and the Werkzeug debugger when started with `python run.py`. Never on a shared network: the debugger runs code |

Proxmox connections are added in the UI, not in config.

## Health

The container's healthcheck fetches `/` with Python's `urllib` every 30 s. `docker ps` shows
`(healthy)` once the app answers. It used to call `curl`, which the `python:3.11-slim` base image
doesn't include, so the container showed `unhealthy` forever while working fine.

## Back up and restore

All state is the one SQLite file.

```bash
docker compose stop
docker run --rm -v proxmox-deployer_deployer_data:/data -v "$PWD":/backup alpine \
  cp /data/deployer.db /backup/deployer.db.bak
docker compose start
```

Restore by copying the file back the same way. The file holds Proxmox passwords in plain text: store
the backup like you'd store the password.

## Upgrade

```bash
git pull
docker compose up --build -d
```

There are no migrations. If a release adds a database column, the changelog says so and what to do.

## Logs

```bash
docker compose logs -f
```

Deploy and provisioning errors are also stored on the deployment (`error_message`) and shown in the UI.
