+++
title = "Install"
description = "Linux x86_64 from GitHub Releases, with checksums. Build from source when you need to."
template = "install.html"

[extra.downloads]
eyebrow = "GitHub Releases"
channels_label = "Get rgit"
unavailable_label = "Not published"
channels = [
  { name = "Linux x86_64", status = "v0.16.0", description = "Tarball with rabun-git, LICENSE, README, and BUILD. Check the SHA-256, then copy the binary onto PATH.", url = "https://github.com/rconnelly/rgit/releases/download/v0.16.0/rabun-git-v0.16.0-x86_64-unknown-linux-gnu.tar.gz", button_label = "Download tarball" },
  { name = "Ubuntu host", status = "systemd", description = "Pack this checkout or fetch a release, then copy over SSH. The server never talks to GitHub.", url = "/docs/deploy-ubuntu/", button_label = "Deploy guide" },
  { name = "Source", status = "GitHub", description = "Clone and build with Cargo. Use this to read the code or pack on aarch64.", url = "https://github.com/rconnelly/rgit", button_label = "View on GitHub" },
  { name = "macOS", status = "Planned", description = "Agents already run on a Mac. Forge packages are Linux-only for now." },
  { name = "Windows", status = "Planned", description = "Agents exist. Packaged binaries do not. Run the forge on Linux." },
]

[extra.downloads.status]
label = "Current release"
title = "v0.16.0"
description = "Stable tag. Packed on Ubuntu with a SHA-256 sidecar."
items = [
  { label = "Published", value = "2026-09-25" },
  { label = "Platform", value = "Linux x86_64 (gnu)" },
  { label = "License", value = "MIT" },
  { label = "Artifact", value = "rabun-git-v0.16.0-x86_64-unknown-linux-gnu.tar.gz" },
]

[extra.downloads.verification]
label = "Verify"
title = "Check the hash, then look inside"
description = "SHA-256 of the v0.16.0 x86_64 tarball is 6c82f1f3913d03f3ce4c4a92b33abeab69f140e11195310663519aff5485f916. Fetch the sidecar next to the archive, check it, then list the tarball."
links = [
  { label = "SHA-256 sidecar", url = "https://github.com/rconnelly/rgit/releases/download/v0.16.0/rabun-git-v0.16.0-x86_64-unknown-linux-gnu.tar.gz.sha256" },
  { label = "GitHub Release", url = "https://github.com/rconnelly/rgit/releases/tag/v0.16.0" },
]
+++

Prebuilt `rabun-git` is **Linux x86_64**. There is no install script to pipe from the network. Pin a tag, fetch the archive and sidecar, check the hash, then copy the binary.

`rgit` is a symlink to `rabun-git`. Env vars, paths, and systemd stay `rabun-git`. Runtime still needs [Git](https://git-scm.com/) on `PATH`.

## Linux binary

Pin **v0.16.0** below, or swap the version for another [stable tag](https://github.com/rconnelly/rgit/releases).

```bash
VERSION=v0.16.0
TRIPLE=x86_64-unknown-linux-gnu
BASE="https://github.com/rconnelly/rgit/releases/download/${VERSION}"
ARCHIVE="rabun-git-${VERSION}-${TRIPLE}.tar.gz"

curl -fL --proto '=https' --tlsv1.2 -o "${ARCHIVE}" "${BASE}/${ARCHIVE}"
curl -fL --proto '=https' --tlsv1.2 -o "${ARCHIVE}.sha256" "${BASE}/${ARCHIVE}.sha256"
```

`-f` fails on HTTP errors. `-L` follows GitHub’s redirect. `--proto '=https'` refuses a downgrade.

Check the sidecar, then the file:

```bash
cat "${ARCHIVE}.sha256"
sha256sum -c "${ARCHIVE}.sha256"
```

Expected sidecar line:

```text
6c82f1f3913d03f3ce4c4a92b33abeab69f140e11195310663519aff5485f916  rabun-git-v0.16.0-x86_64-unknown-linux-gnu.tar.gz
```

A release tarball is:

```text
rabun-git
LICENSE
README.md
BUILD
```

```bash
tar tzf "${ARCHIVE}"
tar xzf "${ARCHIVE}"
cat BUILD
./rabun-git --version
```

`BUILD` records the tag and git revision. `--version` should report `0.16.0` for this tag.

User-local install (no sudo). Add `~/.local/bin` to `PATH` if needed:

```bash
mkdir -p ~/.local/bin
install -m 0755 rabun-git ~/.local/bin/rabun-git
ln -sfn rabun-git ~/.local/bin/rgit
```

Skip the symlink if another `rgit` is already on `PATH`. Confirm:

```bash
rgit --version
rabun-git --version
```

On a server, the production prefix is `/usr/local/bin`. `aarch64` tarballs are not on GitHub Releases yet; pack on that host or [build from source](https://github.com/rconnelly/rgit).

## Ubuntu host

Copy an archive over SSH. The host never talks to GitHub. From a clone on this machine:

```bash
./deploy/ubuntu/push.sh --pack --bootstrap user@HOST
```

Or install the latest stable GitHub Release (this machine needs `gh`; the server does not):

```bash
./deploy/ubuntu/push.sh --bootstrap user@HOST
./deploy/ubuntu/push.sh --bootstrap user@HOST v0.16.0
```

Layout, first admin, and later deploys: [Ubuntu deploy](/docs/deploy-ubuntu/). Then [start the forge](/docs/start-the-forge/).

## From source

Clone, pin a tag, run the install script. You need Git, a C compiler, and Rust 1.85 or newer (edition 2021). Details live in the [repository](https://github.com/rconnelly/rgit).

```bash
git clone https://github.com/rconnelly/rgit.git
cd rgit
git checkout v0.16.0
./scripts/install.sh
```

That runs `cargo install --path . --locked` and links `rgit` beside `rabun-git` in `~/.cargo/bin`. Debian/Ubuntu build deps: `./scripts/install-linux-build-deps.sh`.

Next: [start the forge](/docs/start-the-forge/).
