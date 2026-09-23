#!/usr/bin/env bash
# Regenerate the user guide from the rabun-git checkout, then build the site
# and pack public/ for DigitalOcean. The droplet never clones this repo.
#
#   ./scripts/build.sh
#   ./deploy/digitalocean/push.sh --archive dist/rgit-site.tar.gz --bootstrap root@DROPLET_IP
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 "$ROOT/scripts/generate-docs.py"
"$ROOT/scripts/pack-source.sh"
rsites check
rsites build

mkdir -p "$ROOT/dist"
tar -C "$ROOT/public" -czf "$ROOT/dist/rgit-site.tar.gz" .
sha256sum "$ROOT/dist/rgit-site.tar.gz" | awk '{print $1}' >"$ROOT/dist/rgit-site.tar.gz.sha256"
echo "wrote $ROOT/dist/rgit-site.tar.gz"
