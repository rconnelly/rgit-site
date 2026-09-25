+++
title = "Install"
description = "Linux binaries from GitHub Releases, with checksums. Build from source on GitHub. macOS and Windows packages are not published yet."
template = "install.html"

[extra.downloads]
eyebrow = "Linux"
channels_label = "Ways to get rgit"
unavailable_label = "Not published"
channels = [
  { name = "Linux x86_64", status = "v0.16.0", description = "Release tarball: rabun-git, LICENSE, README, and BUILD. Verify the sidecar SHA-256 before you copy the binary onto PATH.", url = "https://github.com/rconnelly/rgit/releases/download/v0.16.0/rabun-git-v0.16.0-x86_64-unknown-linux-gnu.tar.gz", button_label = "Download tarball" },
  { name = "Ubuntu host", status = "systemd", description = "Pack this checkout or fetch a release, then copy over SSH. The server never talks to GitHub.", url = "/docs/deploy-ubuntu/", button_label = "Deploy guide" },
  { name = "Source", status = "GitHub", description = "Clone the tree and build with Cargo. That is the path when you want to read the code or pack on aarch64.", url = "https://github.com/rconnelly/rgit", button_label = "View on GitHub" },
  { name = "macOS", status = "Planned", description = "Builder agents can already run on a Mac. Prebuilt forge packages are Linux-only for now." },
  { name = "Windows", status = "Planned", description = "Same as macOS: agents exist, packaged binaries do not. Use Linux for the forge host." },
]

[extra.downloads.status]
label = "Current release"
title = "v0.16.0"
description = "Stable SemVer tag. GitHub Actions packed this archive on Ubuntu and attached the SHA-256 sidecar."
items = [
  { label = "Published", value = "2026-09-25" },
  { label = "Platform", value = "Linux x86_64 (gnu)" },
  { label = "License", value = "MIT" },
  { label = "Artifact", value = "rabun-git-v0.16.0-x86_64-unknown-linux-gnu.tar.gz" },
]

[extra.downloads.verification]
label = "Verify"
title = "Checksums, then inspect"
description = "SHA-256 of the v0.16.0 x86_64 tarball is 6c82f1f3913d03f3ce4c4a92b33abeab69f140e11195310663519aff5485f916. Download the sidecar next to the archive, check it, then list the tarball before installing."
links = [
  { label = "SHA-256 sidecar", url = "https://github.com/rconnelly/rgit/releases/download/v0.16.0/rabun-git-v0.16.0-x86_64-unknown-linux-gnu.tar.gz.sha256" },
  { label = "GitHub Release", url = "https://github.com/rconnelly/rgit/releases/tag/v0.16.0" },
]
+++

Prebuilt `rabun-git` is **Linux only** right now. GitHub Actions publishes `x86_64-unknown-linux-gnu`. There is no install script to pipe from the network. Pin a tag, fetch the two files GitHub attached, check the hash, look inside the archive, then copy the binary.

`rgit` is a symlink to `rabun-git`. Env vars, paths, and systemd stay `rabun-git`. Runtime still needs [Git](https://git-scm.com/) on `PATH`.

## Linux binary

Pick a tag on [GitHub Releases](https://github.com/rconnelly/rgit/releases). The commands below pin **v0.16.0**. Swap the version to install another stable tag. The filename includes the version, so a floating `latest` URL is not enough by itself.

```bash
VERSION=v0.16.0
TRIPLE=x86_64-unknown-linux-gnu
BASE="https://github.com/rconnelly/rgit/releases/download/${VERSION}"
ARCHIVE="rabun-git-${VERSION}-${TRIPLE}.tar.gz"

curl -fL --proto '=https' --tlsv1.2 -o "${ARCHIVE}" "${BASE}/${ARCHIVE}"
curl -fL --proto '=https' --tlsv1.2 -o "${ARCHIVE}.sha256" "${BASE}/${ARCHIVE}.sha256"
```

`-f` fails on HTTP errors so you do not save an HTML error page as the binary. `-L` follows GitHub’s redirect. `--proto '=https'` refuses a downgrade.

Print the sidecar GitHub published, then check the file you have. `sha256sum -c` compares the hash **and** the filename on that line:

```bash
cat "${ARCHIVE}.sha256"
sha256sum -c "${ARCHIVE}.sha256"
```

Expected sidecar line for this tarball (hash, two spaces, filename):

```text
6c82f1f3913d03f3ce4c4a92b33abeab69f140e11195310663519aff5485f916  rabun-git-v0.16.0-x86_64-unknown-linux-gnu.tar.gz
```

List the archive before you extract it. A release tarball is:

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

`BUILD` records the tag and git revision the packer baked in. `--version` should report `0.16.0` for this tag.

User-local install (no sudo). Add `~/.local/bin` to `PATH` if it is missing:

```bash
mkdir -p ~/.local/bin
install -m 0755 rabun-git ~/.local/bin/rabun-git
ln -sfn rabun-git ~/.local/bin/rgit
```

Skip the symlink if another `rgit` is already on `PATH` (some recursive-git wrappers use that name). Confirm:

```bash
rgit --version
rabun-git --version
```

On a server, the production prefix is `/usr/local/bin` (same as the Ubuntu unit). `aarch64` tarballs are not attached to GitHub Releases yet; pack on that host or [build from source](https://github.com/rconnelly/rgit).

## Ubuntu host

For a systemd forge, copy an archive over SSH. The host never talks to GitHub. From a clone on this machine:

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

Build on [GitHub](https://github.com/rconnelly/rgit): clone the tree, pin a tag, run the repo install script. You need Git, a C compiler, and a Rust toolchain (edition 2021, Rust 1.85 or newer). Details live in the repository, not here.

```bash
git clone https://github.com/rconnelly/rgit.git
cd rgit
git checkout v0.16.0
./scripts/install.sh
```

That runs `cargo install --path . --locked` and links `rgit` beside `rabun-git` in `~/.cargo/bin`. Debian/Ubuntu build deps: `./scripts/install-linux-build-deps.sh`.

Next: [start the forge](/docs/start-the-forge/).
