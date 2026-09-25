+++
title = "Releases"
description = "Tagged SemVer builds of Rabun Git on GitHub."

[extra]
generated = true
source = "scripts/sync-releases.py"
+++

Binaries are on [GitHub Releases](https://github.com/rconnelly/rgit/releases). Tags are SemVer 2.0.0 with a `v` prefix and must match `Cargo.toml`. Pushing a tag publishes the Linux x86_64 tarball.

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
git clone https://github.com/rconnelly/rgit.git
cd rgit
./scripts/install.sh
```

The repository is [rconnelly/rgit](https://github.com/rconnelly/rgit).
