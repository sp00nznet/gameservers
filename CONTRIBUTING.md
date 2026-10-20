# Contributing

Issues and pull requests are welcome.

## Before a PR

```bash
cd proxmox-deployer
pip install -r requirements.txt
python -m unittest discover tests
```

CI runs the same tests on every push and PR. They need no Proxmox host.

- **Adding a game:** add a `_server(...)` entry to `app/game_servers.py`. If it can auto-install, add
  an entry to `app/install_scripts.py` under **the same key**, test it on a real container, and say
  which template you used in the PR. Update `docs/games.md`, and `docs/firewall.md` for its ports.
- **Docs:** a change that makes a file in `docs/` wrong isn't finished until that file is fixed.
- **Changelog:** add a line under `Unreleased` in `CHANGELOG.md`.
- **Commits:** imperative subject line. Say why in the body when it isn't obvious.

## Where your code comes from

This repo is MIT. Code you contribute must be your own or under a licence compatible with MIT
(MIT, BSD, Apache-2.0, ISC, zlib), with its notice kept. Don't port code from GPL, LGPL, AGPL or
unlicensed projects, even rewritten: that's still derived code. Install scripts that *run* GPL
software (LinuxGSM is MIT; many game servers aren't) are fine, because running a program is not
copying it. If you're unsure, ask in the PR.

## AI-assisted contributions

Welcome, as long as a person understood and checked the change. Say so in the PR.

By contributing you agree your work is released under the MIT license.
