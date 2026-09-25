# Rabun Git

Showcase and documentation site for [Rabun Git](https://github.com/Burton-Workspaces/rabun-git) (`rgit`), a self-hosted git forge. Production URL: [https://docs.rgit.rs](https://docs.rgit.rs).

This repository is an [rsites](https://github.com/Burton-Workspaces/rabun-sites) site: [Zola](https://www.getzola.org/) content, [DevLab](https://codeberg.org/RiPetitor/devlab-theme) pinned as a git submodule, and [Caddy](https://caddyserver.com/) for production. The `rsites` CLI lives in **rabun-sites** (`rabun-sites` the crate, `rsites` on PATH).

The palette is Rabun's mountain mark: cream `#faf3d8`, gold `#c4a04a`, sage `#7a9e6e`, pine `#143528`, forest `#0c241c`.

## Layout

| Path | Role |
| --- | --- |
| `content/` | Markdown pages (TOML front matter) |
| `content/docs/` | User guide generated from the rabun-git checkout |
| `zola.toml` | Brand, nav, DevLab extras |
| `rsites.toml` | Theme pin, hostname, Caddy document root |
| `templates/`, `static/` | Site overlays (do not edit `themes/`) |
| `scripts/build.sh` | Regenerate docs, `rsites build`, pack `dist/rgit-site.tar.gz` |
| `deploy/ubuntu/` | Bare-metal Ubuntu install (`push.sh --pack`) |
| `deploy/digitalocean/` | Droplet install and Caddy virtual host |

The forge binary itself is deployed from the rabun-git repo (`deploy/ubuntu/` there). These scripts publish this static site. Tagged rgit builds live on GitHub Releases unless you switch `[extra.releases]` to pack a source tarball here.

## Requirements

- Git
- Python 3
- [Zola](https://www.getzola.org/) **0.23.4** or newer
- [`rsites`](https://github.com/Burton-Workspaces/rabun-sites) on PATH
- A sibling checkout of rabun-git at `../rabun-git` (or set `RABUN_GIT_DIR`)

From a rabun-sites checkout:

```bash
cargo build --release
./target/release/rsites setup-shell
rsites zola install
rsites doctor
```

## Preview

```bash
git submodule update --init --recursive
python3 scripts/generate-docs.py
rsites serve
```

That is Zola's live server (not Caddy). After content or nav changes run `rsites check`. `./scripts/build.sh` regenerates the guide, writes the releases page (GitHub link or packed tarball), then writes `public/` and `dist/rgit-site.tar.gz`.

## Releases

`[extra.releases]` in `zola.toml` chooses how this site points at rgit builds. The associated public GitHub repo is [rconnelly/rgit](https://github.com/rconnelly/rgit).

| `mode` | What visitors get |
| --- | --- |
| `github` (this site) | Header **Releases** and `content/releases.md` link to GitHub Releases. No tarball is packed. |
| `pack` | `scripts/pack-source.sh` fetches `master` and hosts a source-only archive under `static/releases/`. Set the nav path back to `/releases/`. |

`python3 scripts/sync-releases.py` applies the configured mode (`RELEASES_MODE` / `RELEASES_URL` override). `pack-source.sh` fetches GitHub (`git@github.com:Burton-Workspaces/rabun-git.git`, override with `RABUN_GIT_URL`). If that remote is missing, it packs the local checkout's `master` (`../rabun-git`, `RABUN_GIT_DIR`) and does not update that checkout. The tarball is not committed. The script refuses any remote that is not on `github.com`, so it will not talk to a Rabun Git forge.

## Caddy

Caddy serves the built `public/` tree in production. Hostname and document root come from `rsites.toml` (`docs.rgit.rs`, `/var/www/rgit-site`).

```bash
rsites caddy render
rsites caddy render --snippet
rsites caddy render --out /etc/caddy/sites-enabled/rgit-site.caddy
```

The checked-in snippet [`deploy/digitalocean/rgit-site.caddy`](deploy/digitalocean/rgit-site.caddy) matches that block. Pass `--domain www.example.com` at bootstrap and the apex host redirects to www. Import it from the host Caddyfile (`import /etc/caddy/sites-enabled/*`) so this virtual host can share a droplet with Burton, docs, and Rabun.

## DigitalOcean droplet

Same pattern as burton-site: the droplet never clones this private repo. A laptop builds `public/`, copies a tarball over SSH, and Caddy `file_server`s `/var/www/rgit-site`.

```
Internet → docs.rgit.rs → Caddy :443 → /var/www/rgit-site
        → (sibling hostnames) → Caddy :443 → other site files
```

Bootstrap writes `/etc/caddy/sites-enabled/rgit-site.caddy` and adds `import /etc/caddy/sites-enabled/*` if that line is missing. It does **not** replace an existing Caddyfile that already has other sites.

### 1. Create the droplet

Ubuntu 24.04 LTS. Point an A record for **docs.rgit.rs** at the droplet IPv4. Firewall: 22, 80, and 443.

### 2. Bootstrap (once)

```bash
./scripts/build.sh
./deploy/digitalocean/push.sh --archive dist/rgit-site.tar.gz --bootstrap root@DROPLET_IP
```

`--domain` defaults to `docs.rgit.rs`. Set `CADDY_EMAIL` if this host's Caddyfile is new and should register an ACME account.

### 3. Later updates

```bash
./scripts/build.sh
./deploy/digitalocean/push.sh --archive dist/rgit-site.tar.gz root@DROPLET_IP
```

To take over a hostname another Caddy snippet already serves:

```bash
./deploy/digitalocean/push.sh --archive dist/rgit-site.tar.gz --domain docs.rgit.rs --overwrite root@DROPLET_IP
```

### Layout on the droplet

| Path | Role |
| --- | --- |
| `/var/www/rgit-site` | published `public/` tree (and `/releases/*.tar.gz` only in `pack` mode) |
| `/etc/caddy/sites-enabled/rgit-site.caddy` | virtual host |
| `/etc/caddy/Caddyfile` | `import /etc/caddy/sites-enabled/*` plus any sites you already had |
| `/etc/rgit-site/site.env` | health-check URL and `Host` header |

Logs: `journalctl -u caddy -f`. Do not wipe `/var/lib/caddy` (ACME store).

## Ubuntu (bare metal)

Same archive on an x86_64 Ubuntu host that may already run other Caddy sites. The server never talks to GitHub. Bootstrap does not replace an existing Caddyfile, does not enable ufw unless it is already active (or `SITE_ENABLE_UFW=1`), and refuses a `--domain` that another Caddy snippet already serves unless you pass `--overwrite`.

This is the sibling of the DigitalOcean droplet path above. The forge binary still deploys from the rabun-git repo (`deploy/ubuntu/` there). These scripts only publish the static site.

```
Internet → Caddy :443 (optional, site snippet only) → /var/www/rgit-site
                                                    → :8080 when no domain is set
```

### 1. Server

Ubuntu 24.04 LTS (or 26.04), x86_64. SSH as `root` or a sudoer. From a laptop, `push.sh` allocates a TTY so sudo can prompt for a password.

### 2. Bootstrap (once)

```bash
./deploy/ubuntu/push.sh --pack --bootstrap --domain docs.rgit.rs user@HOST
```

Omit `--domain` to listen on **:8080**. On a LAN hostname that cannot use Let's Encrypt:

```bash
./deploy/ubuntu/push.sh --pack --bootstrap --domain damascus --tls lan user@192.168.0.18
```

Trust `/etc/rgit-site/tls/lan-root.crt` on each device, then open `https://damascus`. On a fresh box with no firewall yet:

```bash
SITE_ENABLE_UFW=1 ./deploy/ubuntu/push.sh --pack --bootstrap user@HOST
```

Do **not** `curl | bash` the bootstrap script from `raw.githubusercontent.com`.

### 3. Later updates

```bash
./deploy/ubuntu/push.sh --pack user@HOST
```

To move this site onto a hostname another Caddy snippet already serves (for example `rgit.rs` → `docs.rgit.rs`):

```bash
./deploy/ubuntu/push.sh --pack --domain docs.rgit.rs --overwrite user@HOST
```

That rewrites `rgit-site.caddy`, removes the other snippet's claim on that hostname (backup next to the old file), and reloads Caddy. Do **not** use `--bootstrap` for a domain move; bootstrap is first-time host setup.

Two-step (inspect the archive first):

```bash
./deploy/ubuntu/pack.sh
# dist/rgit-site.tar.gz
./deploy/ubuntu/push.sh --archive dist/rgit-site.tar.gz user@HOST
```

### Layout on the server

| Path | Role |
| --- | --- |
| `/var/www/rgit-site` | published `public/` tree |
| `/etc/caddy/sites-enabled/rgit-site.caddy` | Caddy site snippet |
| `/etc/caddy/Caddyfile` | `import /etc/caddy/sites-enabled/*` plus any sites you already had |
| `/etc/rgit-site/site.env` | health-check URL, hostname, optional `SITE_TLS` |
| `/etc/rgit-site/tls/lan-root.crt` | Caddy local CA when `--tls lan` |

Logs: `journalctl -u caddy -f`. Do not wipe `/var/lib/caddy` (ACME store).

## License

MIT, same as Rabun Git.
