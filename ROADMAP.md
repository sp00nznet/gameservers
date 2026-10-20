# Roadmap

## Next
- **Login for the web UI.** It has none, and it holds root passwords for Proxmox. Until then it must
  stay on a trusted network (`SECURITY.md`).
- **Encrypt stored secrets** (connection passwords, tokens, credentials) at rest.
- **Provision in the background.** `POST /api/deploy` blocks for the whole install; two at once tie up
  both Gunicorn workers.
- **Install scripts for the other 145 games.** Most catalog entries already carry a `linuxgsm_name`,
  so a LinuxGSM fallback in `get_install_script()` could cover many of them, but each needs testing on
  a real container before it's switched on.

## Later
- VM deployments from the catalog (the code path exists; no entry uses it).
- Look up a DHCP container's IP after deploy.
- Database migrations, so new columns don't need a manual step.

## Out of scope
- Hosting game files or server binaries. Everything is downloaded from the official source at
  install time.
- Managing game configs after install. Use LinuxGSM, Pterodactyl or AMP for that; the catalog can
  deploy those panels.
