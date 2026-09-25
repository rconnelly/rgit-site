#!/usr/bin/env bash
# Build a public/ archive from this checkout. Architecture-independent HTML.
# Run from a clone. Regenerates the user guide, then packs the same tarball
# as scripts/build.sh.
#
#   ./deploy/ubuntu/pack.sh
#   ./deploy/ubuntu/push.sh --pack user@host
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

usage() {
  echo "usage: $0" >&2
  exit 2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

if [[ ! -f zola.toml ]]; then
  echo "run pack.sh from an rgit-site checkout (missing zola.toml)" >&2
  exit 1
fi

if [[ -f .gitmodules ]] && command -v git >/dev/null; then
  git submodule update --init --recursive
fi

bash "$ROOT/scripts/build.sh"

OUT_DIR="${SITE_PACK_DIR:-dist}"
mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
ARCHIVE="${OUT_DIR}/rgit-site.tar.gz"
BUILT="$ROOT/dist/rgit-site.tar.gz"

if [[ "$ARCHIVE" != "$BUILT" ]]; then
  cp "$BUILT" "$ARCHIVE"
  if [[ -f "${BUILT}.sha256" ]]; then
    cp "${BUILT}.sha256" "${ARCHIVE}.sha256"
  fi
fi

if [[ ! -f "$ARCHIVE" ]]; then
  echo "build did not produce ${ARCHIVE}" >&2
  exit 1
fi

echo "packed ${ARCHIVE}"
echo "checksum ${ARCHIVE}.sha256"
