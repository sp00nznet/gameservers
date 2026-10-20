# Security

## What this handles

The web deployer stores **root credentials for your Proxmox host** and uses them to create containers
and to run commands on the host over SSH. Treat the deployer like the Proxmox root account itself.

## Known limits, today

- **No login.** Anyone who can reach port 5555 can deploy, delete containers, run commands inside
  them, and read the connection list. Run it on a trusted LAN or behind a VPN or an authenticating
  reverse proxy. Never expose it to the internet.
- **Secrets are stored in plain text** in the SQLite database (`docs/data-model.md`). The API never
  returns them, but anyone with the file has them. Protect `deployer.db` and its backups.
- **TLS verification is off by default** for Proxmox connections, because Proxmox ships a self-signed
  certificate. Turn on *Verify SSL* if you've installed a real one.
- **SSH host keys are auto-accepted** on first connect.

These are on the roadmap. Prefer a dedicated Proxmox user over `root@pam` if you only need to create
containers (an API token works for that; provisioning still needs a password).

## Reporting a vulnerability

Please use GitHub's private vulnerability reporting
(*Security → Report a vulnerability* on the repo) rather than a public issue. Include the endpoint or
file and what an attacker could do. I'll reply within a week.
