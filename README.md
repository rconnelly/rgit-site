# Rabun Git

Showcase and documentation site for [Rabun Git](https://github.com/Burton-Workspaces/rabun-git) (`rgit`), a self-hosted git forge. Production URL: [https://rgit.burtonapp.com](https://rgit.burtonapp.com).

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
| `deploy/digitalocean/` | Droplet install and Caddy virtual host |

The forge binary itself is deployed from the rabun-git repo (`deploy/ubuntu/`). These scripts publish this static site, including the source tarball on the release page.

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

That is Zola's live server (not Caddy). After content or nav changes run `rsites check`. `./scripts/build.sh` regenerates the guide, packs a source tarball of rabun-git `master` from GitHub, then writes `public/` and `dist/rgit-site.tar.gz`.

## Source release

`scripts/pack-source.sh` fetches `master` from GitHub (`git@github.com:Burton-Workspaces/rabun-git.git`, override with `RABUN_GIT_URL`) and writes a source-only archive under `static/releases/`. If that GitHub remote is missing, it packs the local checkout's `master` commit (`../rabun-git`, override with `RABUN_GIT_DIR`) and does not fetch or update that checkout. The release page is generated at `content/releases.md`. The tarball is not committed. `./scripts/build.sh` includes it in `public/`, and the DigitalOcean upload publishes it at `/releases/` next to the rest of the site.

The script refuses any remote that is not on `github.com`, so it will not talk to a Rabun Git forge.

## Caddy

Caddy serves the built `public/` tree in production. Hostname and document root come from `rsites.toml` (`rgit.burtonapp.com`, `/var/www/rgit-site`).

```bash
rsites caddy render
rsites caddy render --snippet
rsites caddy render --out /etc/caddy/sites-enabled/rgit-site.caddy
```

The checked-in snippet [`deploy/digitalocean/rgit-site.caddy`](deploy/digitalocean/rgit-site.caddy) matches that block. Pass `--domain www.example.com` at bootstrap and the apex host redirects to www. Import it from the host Caddyfile (`import /etc/caddy/sites-enabled/*`) so this virtual host can share a droplet with Burton, docs, and Rabun.

## DigitalOcean droplet

Same pattern as burton-site: the droplet never clones this private repo. A laptop builds `public/`, copies a tarball over SSH, and Caddy `file_server`s `/var/www/rgit-site`.

```
Internet → rgit.burtonapp.com → Caddy :443 → /var/www/rgit-site
        → (sibling hostnames) → Caddy :443 → other site files
```

Bootstrap writes `/etc/caddy/sites-enabled/rgit-site.caddy` and adds `import /etc/caddy/sites-enabled/*` if that line is missing. It does **not** replace an existing Caddyfile that already has other sites.

### 1. Create the droplet

Ubuntu 24.04 LTS. Point an A record for **rgit.burtonapp.com** at the droplet IPv4. Firewall: 22, 80, and 443.

### 2. Bootstrap (once)

```bash
./scripts/build.sh
./deploy/digitalocean/push.sh --archive dist/rgit-site.tar.gz --bootstrap root@DROPLET_IP
```

`--domain` defaults to `rgit.burtonapp.com`. Set `CADDY_EMAIL` if this host's Caddyfile is new and should register an ACME account.

### 3. Later updates

```bash
./scripts/build.sh
./deploy/digitalocean/push.sh --archive dist/rgit-site.tar.gz root@DROPLET_IP
```

### Layout on the droplet

| Path | Role |
| --- | --- |
| `/var/www/rgit-site` | published `public/` tree, including `/releases/*.tar.gz` |
| `/etc/caddy/sites-enabled/rgit-site.caddy` | virtual host |
| `/etc/caddy/Caddyfile` | `import /etc/caddy/sites-enabled/*` plus any sites you already had |
| `/etc/rgit-site/site.env` | health-check URL and `Host` header |

Logs: `journalctl -u caddy -f`. Do not wipe `/var/lib/caddy` (ACME store).

## License

MIT, same as Rabun Git.
