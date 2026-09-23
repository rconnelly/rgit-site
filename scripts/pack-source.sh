#!/usr/bin/env bash
# Fetch rabun-git master from GitHub and pack a source tarball for the release page.
# Source only: no cargo build, and this script never contacts a Rabun Git forge.
#
# Prefer `python3 scripts/sync-releases.py` from build.sh. That script calls this
# one only when zola.toml [extra.releases] mode is "pack".
#
#   ./scripts/pack-source.sh
#   RABUN_GIT_URL=git@github.com:Burton-Workspaces/rabun-git.git ./scripts/pack-source.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
URL="${RABUN_GIT_URL:-git@github.com:Burton-Workspaces/rabun-git.git}"
BRANCH="${RABUN_GIT_BRANCH:-master}"
CACHE="${ROOT}/.cache/rabun-git.git"
REL="${ROOT}/static/releases"

case "$URL" in
  *github.com*) ;;
  *)
    echo "refusing ${URL}" >&2
    echo "pack-source.sh fetches GitHub only. Set RABUN_GIT_URL to the GitHub remote." >&2
    exit 1
    ;;
esac

LOCAL="${RABUN_GIT_DIR:-${ROOT}/../rabun-git}"
SOURCE=""
REV=""

mkdir -p "$(dirname "$CACHE")"
if [[ ! -d "$CACHE" ]]; then
  git init --bare "$CACHE"
  git -C "$CACHE" remote add origin "$URL"
fi
git -C "$CACHE" remote set-url origin "$URL"

echo "fetching ${BRANCH} from ${URL}"
if git -C "$CACHE" fetch --depth 1 origin "$BRANCH" 2>"${CACHE}.fetch.err"; then
  REV="$(git -C "$CACHE" rev-parse FETCH_HEAD)"
  SOURCE="github"
else
  echo "GitHub fetch failed ($(tail -n 1 "${CACHE}.fetch.err"))" >&2
  echo "packing the local ${BRANCH} commit from ${LOCAL} (checkout is not fetched or updated)" >&2
  if [[ ! -d "$LOCAL/.git" ]]; then
    echo "no local checkout at ${LOCAL}" >&2
    exit 1
  fi
  REV="$(git -C "$LOCAL" rev-parse "refs/heads/${BRANCH}")"
  SOURCE="local"
fi

SHORT="$(git -C "$CACHE" rev-parse --short=12 "$REV" 2>/dev/null || git -C "$LOCAL" rev-parse --short=12 "$REV")"
if git -C "$CACHE" cat-file -e "${REV}:Cargo.toml" 2>/dev/null; then
  META_REPO="$CACHE"
else
  META_REPO="$LOCAL"
fi
VERSION="$(git -C "$META_REPO" show "${REV}:Cargo.toml" | sed -n 's/^version = "\(.*\)"/\1/p' | head -n1)"
DATE="$(git -C "$META_REPO" log -1 --format=%cs "$REV")"
if [[ -z "$VERSION" ]]; then
  echo "Cargo.toml on ${BRANCH} has no version" >&2
  exit 1
fi

NAME="rabun-git-${VERSION}-${SHORT}"
mkdir -p "$REL"
find "$REL" -maxdepth 1 -type f \( -name '*.tar.gz' -o -name '*.sha256' -o -name 'SHA256SUMS' \) -delete

git -C "$META_REPO" archive --format=tar.gz --prefix="rabun-git/" "$REV" >"${REL}/${NAME}.tar.gz"
cp "${REL}/${NAME}.tar.gz" "${REL}/rabun-git-latest.tar.gz"
(
  cd "$REL"
  sha256sum "${NAME}.tar.gz" | tee "${NAME}.tar.gz.sha256" >SHA256SUMS
  sha256sum rabun-git-latest.tar.gz | tee rabun-git-latest.tar.gz.sha256 >>SHA256SUMS
)
SUM="$(awk '{print $1}' "${REL}/${NAME}.tar.gz.sha256")"

python3 - "$ROOT/content/releases.md" "$NAME" "$SHORT" "$VERSION" "$DATE" "$REV" "$SUM" "$SOURCE" <<'PY'
import sys
from pathlib import Path

path, name, short, version, date, rev, digest, source = sys.argv[1:]
if source == "github":
    origin = "the `master` branch on GitHub"
else:
    origin = "the `master` commit used to build this site"
Path(path).write_text(
    f"""+++
title = "Releases"
description = "Source tarball of the rabun-git master branch."

[extra]
generated = true
source = "scripts/pack-source.sh"
+++

Source snapshot of {origin}. Crate version **{version}**, commit `{short}` (`{date}`). The archive is the git tree of that commit, with no build output.

Unpack it and install from the checkout:

```bash
tar -xzf {name}.tar.gz
cd rabun-git
./scripts/install.sh
```

| Archive | SHA-256 |
| --- | --- |
| [{name}.tar.gz](/releases/{name}.tar.gz) | `{digest}` |
| [rabun-git-latest.tar.gz](/releases/rabun-git-latest.tar.gz) | `{digest}` |

Both files are this same snapshot. Full commit `{rev}`. Checksums: [SHA256SUMS](/releases/SHA256SUMS).
""",
    encoding="utf-8",
)
PY

echo "wrote ${REL}/${NAME}.tar.gz"
echo "wrote ${ROOT}/content/releases.md"
