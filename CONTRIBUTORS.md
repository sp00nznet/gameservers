# Contributors

## Maintainer

**sp00nz** ([@sp00nznet](https://github.com/sp00nznet)).

## Issue reports and testing

**DarkShoot** ([@DarkShoot06](https://github.com/DarkShoot06)) reported that the deployer failed to
start under both Docker and plain Python after the 250-game catalog rewrite (#13). The traceback in
the report showed `error.html` rendering `base.html` without `categories`, which led to the full set
of fixes: the dropped `STATS` and `get_server` names, the context processor that gives every page its
categories, and the seven install scripts that had been orphaned under old keys.
