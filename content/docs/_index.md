+++
title = "User guide"
description = "Rgit is Git with etiquette."
sort_by = "weight"
template = "docs.html"
page_template = "doc-page.html"

[extra]
generated = true
source = "doc/README.md"
+++

Rgit is Git with etiquette. Run a git forge on a machine you own: SSH remotes, users, merge requests, a small CI runner, and Conventional Commits / SemVer 2.0 by default ([turn that off](/docs/versioning/#disable-etiquette)). `rgit serve` has no HTTP git UI. Browse locally with [`rgit view`](/docs/everyday-git/#browse-locally), or add [Rgit Web](https://docs.rgit.rs/web/) as a companion.

If you know `git clone`, `git commit`, and `git push`, follow the pages in order. Examples use `git.example.com`, user `ada`, repo `ada/website`.

## Contents

1. [What is Rabun Git?](/docs/what-it-is/) — how this compares to GitHub and a plain git remote
2. [Install](/docs/install/) — install the `rabun-git` command
3. [Start the forge](/docs/start-the-forge/) — pack-and-push or manual `init` / `serve`, then first admin and key
4. [Set up a remote repository](/docs/remote-repository/) — create `owner/name`, add `origin`, first push or clone
5. [Users and roles](/docs/users-and-roles/) — add people, register keys, grant and revoke `read` / `write` / `admin`
6. [Everyday git](/docs/everyday-git/) — clone, branches, protected `main` / `master`, local `rgit view`
7. [Merge requests](/docs/merge-requests/) — propose, review, fast-forward merge
8. [CI workflows](/docs/ci-workflows/) — `.rabun/workflows` on push, tag, and request
9. [Versioning](/docs/versioning/) — SemVer, Conventional Commits, changelog, `rgit version`
10. [Command reference](/docs/commands/) — CLI and SSH cheat sheet
11. [Compared to GitHub](/docs/compared-to-github/) — feature and `gh` command gap analysis

Layout, ACL, systemd: [architecture](/docs/architecture/). Ubuntu pack/push: [deploy Ubuntu](/docs/deploy-ubuntu/). Extra disk for `repos/`: [storage volume](/docs/storage-volume/).

## Start here

| Job | Page |
| --- | --- |
| Put a project on the forge | [Remote repository](/docs/remote-repository/) |
| Let teammates in | [Users and roles](/docs/users-and-roles/) |

Clone URL shape used throughout:

```text
ssh://git@git.example.com:2222/ada/website.git
```

Forge commands from this machine (`rgit login` attaches a key after website sign-in; `key copy` is host SSH for the first admin):

```bash
rgit remote add origin git@git.example.com
rgit login --web https://git.example.com
rgit origin repo list
```
