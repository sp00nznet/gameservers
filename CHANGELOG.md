# Changelog

All notable changes to this project. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versions follow [SemVer](https://semver.org/).

## [Unreleased]

### Fixed
- The deployer crashed on start (`ImportError: STATS`, then `get_server`) after the catalog rewrite
  in #12 dropped both names. Restored. Reported by [@DarkShoot06](https://github.com/DarkShoot06) (#13).
- Error pages (e.g. an unknown server key) crashed with `'categories' is undefined` instead of showing
  a 404. Every template now gets `categories` from a context processor (#13).
- Seven install scripts were keyed under names the catalog no longer used (`7dtd`, `conan`, `doi`,
  `ut2k4`, `pavlovvr`, `wolfet`, `teamspeak3`), so those games deployed as empty containers. They now
  match the catalog keys.
- `/api/manage/exec` and provisioning built root shell commands on the Proxmox host from unquoted
  input: a `;` in a command or VMID ran on the host instead of in the container. VMIDs are now cast to
  `int` and commands are passed as one quoted `bash -c` argument.
- `python run.py` always enabled the Werkzeug debugger while listening on all interfaces. It is now
  opt-in with `FLASK_DEBUG=1`.
- Docker healthcheck used `curl`, which the slim base image lacks, so the container never became
  healthy. It uses Python's `urllib` now.
- `.env.example` said port 5000; the deployer runs on 5555.

### Added
- `LICENSE` (MIT; the README already claimed it), `CHANGELOG.md`, `ROADMAP.md`, `SECURITY.md`,
  `CONTRIBUTING.md`, `CONTRIBUTORS.md`, root `.gitignore`.
- `docs/architecture.md`, `docs/api.md`, `docs/data-model.md`, `docs/running.md`, and
  `docs/games.md` generated from the real catalog.
- Smoke tests (`proxmox-deployer/tests/`) and a CI workflow that runs them on every push and PR.
- Screenshots of the real UI in `docs/screenshots/`.

### Changed
- README rewritten to say what is true: 217 catalog entries (not "250+"), 72 with install scripts,
  LXC only, no login, credentials stored in plain text (it claimed Fernet encryption), and no automatic
  firewall rules (it claimed those too). The game list and API reference moved to `docs/`.
