#!/usr/bin/env python3
"""Write content/releases.md from zola.toml [extra.releases].

Modes:
  github  Link the GitHub Releases page for the associated repo (default).
  pack    Host a source tarball via scripts/pack-source.sh.

Override with RELEASES_MODE=github|pack and RELEASES_URL=https://github.com/org/repo/releases.
"""

from __future__ import annotations

import os
import subprocess
import sys
import tomllib
from pathlib import Path

SITE = Path(__file__).resolve().parents[1]
ZOLA = SITE / "zola.toml"
PACK = SITE / "scripts" / "pack-source.sh"
PAGE = SITE / "content" / "releases.md"
STATIC = SITE / "static" / "releases"
DEFAULT_GITHUB = "https://github.com/rconnelly/rgit"


def load_extra() -> dict:
    with ZOLA.open("rb") as fh:
        cfg = tomllib.load(fh)
    extra = cfg.get("extra", {})
    releases = extra.get("releases", {})
    footer_github = ""
    for link in extra.get("devlab", {}).get("footer", {}).get("links", []):
        path = str(link.get("path", "")).rstrip("/")
        if "github.com/" in path and not path.endswith("/releases"):
            footer_github = path
            break
    github = os.environ.get(
        "RELEASES_REPO",
        releases.get("repo") or footer_github or DEFAULT_GITHUB,
    )
    github = github_https(str(github))
    return {
        "mode": os.environ.get("RELEASES_MODE", releases.get("mode", "github")),
        "url": os.environ.get(
            "RELEASES_URL",
            releases.get("url") or f"{github}/releases",
        ),
        "github": github,
    }


def github_https(url: str) -> str:
    text = url.strip().rstrip("/")
    if text.endswith(".git"):
        text = text[:-4]
    if text.startswith("git@github.com:"):
        text = "https://github.com/" + text.split(":", 1)[1]
    elif text.startswith("ssh://git@github.com/"):
        text = "https://github.com/" + text.split("github.com/", 1)[1]
    return text


def write_github_page(releases_url: str, repo_url: str) -> None:
    repo = github_https(repo_url)
    clone = repo + ".git"
    PAGE.write_text(
        f"""+++
title = "Releases"
description = "Tagged SemVer builds of Rabun Git on GitHub."

[extra]
generated = true
source = "scripts/sync-releases.py"
+++

Binaries are on [GitHub Releases]({releases_url}). Tags are SemVer 2.0.0 with a `v` prefix and must match `Cargo.toml`. Pushing a tag publishes the Linux x86_64 tarball.

Latest stable onto an Ubuntu host:

```bash
./deploy/ubuntu/push.sh --bootstrap user@HOST
```

Pin a version:

```bash
./deploy/ubuntu/push.sh --bootstrap user@HOST v0.12.1
```

Build from a clone:

```bash
git clone {clone}
cd rgit
./scripts/install.sh
```

The repository is [{repo.removeprefix("https://github.com/")}]({repo}).
""",
        encoding="utf-8",
    )
    if STATIC.is_dir():
        for path in STATIC.iterdir():
            if path.is_file():
                path.unlink()


def main() -> int:
    cfg = load_extra()
    mode = str(cfg["mode"]).strip().lower()
    if mode in ("github", "link"):
        write_github_page(str(cfg["url"]), str(cfg["github"]))
        print(f"wrote {PAGE} (GitHub Releases {cfg['url']})")
        return 0
    if mode == "pack":
        if not PACK.is_file():
            print(f"missing {PACK}", file=sys.stderr)
            return 1
        return subprocess.call([str(PACK)], cwd=SITE)
    print(f"unknown extra.releases.mode {mode!r} (use github or pack)", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
