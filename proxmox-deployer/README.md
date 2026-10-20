# Silverware Game Server Deployer

The Flask web app that deploys game servers to Proxmox VE. Setup, usage and screenshots are in the
[main README](../README.md); this file only covers the folder itself.

| Path | What |
|---|---|
| `run.py` | Entry point. `python run.py` for a dev server; Gunicorn uses `run:app` |
| `app/` | The app; see [docs/architecture.md](../docs/architecture.md) |
| `tests/` | `python -m unittest discover tests` (no Proxmox needed) |
| `start.sh` | `./start.sh dev`, `prod` or `docker` |
| `start.bat`, `start.ps1`, `stop.bat`, `stop.ps1` | Windows launchers (Docker) |
| `Dockerfile`, `docker-compose.yml` | Container build; data in the `deployer_data` volume |
| `.env.example` | Copy to `.env` and set `SECRET_KEY` |

More docs: [running](../docs/running.md), [API](../docs/api.md), [data model](../docs/data-model.md),
[games](../docs/games.md), [security](../SECURITY.md).
