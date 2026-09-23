+++
title = "User guide"
description = "Rabun Git is a git forge you run on a machine you own: SSH remotes, users and roles, merge requests, and a small CI runner."
sort_by = "weight"
template = "docs.html"
page_template = "doc-page.html"

[extra]
generated = true
source = "doc/README.md"
+++

Rabun Git is a git forge you run on a machine you own: SSH remotes, users and roles, merge requests, and a small CI runner. There is no website.

If you know `git clone`, `git commit`, and `git push`, start at the top and follow the pages in order. Each page has copy-paste examples (`git.example.com`, user `ada`, repo `ada/website`).

## Contents

1. [What is Rabun Git?](/docs/what-it-is/) — how this compares to GitHub and a plain git remote
2. [Install](/docs/install/) — build the `rabun-git` command
3. [Start the forge](/docs/start-the-forge/) — pack-and-push or manual `init` / `serve`, then first admin and key
4. [Set up a remote repository](/docs/remote-repository/) — create `owner/name`, add `origin`, first push or clone
5. [Users and roles](/docs/users-and-roles/) — add people, register keys, grant and revoke `read` / `write` / `admin`
6. [Everyday git](/docs/everyday-git/) — clone, branches, protected `main` / `master`
7. [Merge requests](/docs/merge-requests/) — propose, review, fast-forward merge
8. [CI workflows](/docs/ci-workflows/) — `.rabun/workflows` on push, tag, and request
9. [Command reference](/docs/commands/) — CLI and SSH cheat sheet
10. [Compared to GitHub](/docs/compared-to-github/) — feature and `gh` command gap analysis

Operators who need on-disk layout, ACL internals, or systemd: [architecture](/docs/architecture/). Ubuntu pack/push: [deploy Ubuntu](/docs/deploy-ubuntu/).

## Two jobs you will do

| Job | Start here |
| --- | --- |
| Put an existing or new project on the forge | [Remote repository](/docs/remote-repository/) (after the server is up) |
| Let teammates in and control who can push | [Users and roles](/docs/users-and-roles/) |

Clone URL shape used throughout:

```text
ssh://git@git.example.com:2222/ada/website.git
```

Forge commands from this machine (`key copy` registers the first admin key over host SSH):

```bash
rgit remote add origin git@git.example.com
rgit origin key copy ada --admin
rgit origin repo list
```
