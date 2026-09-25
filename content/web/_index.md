+++
title = "Rgit Web"
description = "Optional GitHub-style companion to the rgit CLI. Browse, blame, and review on the same forge — or skip it and bring your own web view."
sort_by = "weight"
template = "web.html"
page_template = "page.html"

[extra]
home_layout = "wide"
home_eyebrow = "Companion UI"
home_hero_image = "/images/hero/rgit-web.png"
home_hero_image_alt = "Simulated Rgit Web: ada/website with a file tree, README, clone URL, and a fast-forward merge request."
home_primary_action_label = "Source"
home_primary_action_path = "https://github.com/rconnelly/rgit-web"
home_secondary_action_label = "CLI guide"
home_secondary_action_path = "/docs/"
home_features = [
  { kicker = "Code", title = "Tree, blob, README", description = "owner/name at HEAD, then directories and files. Markdown renders in the page. Clone URL copies from repo show. Git traffic stays SSH on 2222." },
  { kicker = "History", title = "Commits, blame, diffs", description = "Log a ref, open one commit, blame a file line by line, compare two tips. The CLI shells out to git; the website does not keep a second object store." },
  { kicker = "Review", title = "Merge requests", description = "Same refs as SSH: refs/rabun/requests. Open, comment, approve or reject, fast-forward merge. The website does not invent a second request store." },
  { kicker = "Read", title = "Public without an account", description = "visibility.yaml marks a repo public. Anonymous browse uses rgit --anonymous. Create, review, and merge still need a signed-in user and the usual roles." },
  { kicker = "Auth", title = "Passwords, not keys", description = "Web sign-in is argon2id password → bearer token → HttpOnly cookie. SSH clone identity stays public keys. A browser session is not a deploy key." },
]

[extra.home_learn]
eyebrow = "Presentation"
title = "The CLI is the forge. The website is a face."
description = "Rgit Web has no database. Bun holds process config and a cookie that wraps a forge token. Users, ACL, trees, and merge requests live under the forge data root and are reached only by spawning rgit --json."
cards = [
  { kicker = "Backend", title = "rgit --json", description = "Each page load is a clap subcommand: repo list, tree, blob, blame, log, request show. Operators debug with the same commands the website runs." },
  { kicker = "ACL", title = "Never Operator", description = "The web unit always passes --token or --anonymous. A missing flag would run as Operator and list every private repo. That is a security bug, not a fallback." },
  { kicker = "Look", title = "DevLab tokens", description = "Cream, pine, and gold match rgit view and this site. The shell is Burton Bun + React 19, not a Zola build per request." },
  { kicker = "Replace", title = "Bring your own", description = "cgit, gitweb, a custom SPA, or nothing. The JSON CLI is the contract. Rgit Web is one client." },
]

[extra.home_workflow]
eyebrow = "Optional"
title = "Three ways to look at a tree. Pick none, one, or all."
description = "rgit serve still does not open HTTP for git. The website is a sibling process. If you never install it, clone, push, and merge requests keep working over SSH and the CLI."
points = [
  { title = "CLI only", description = "Users, keys, requests, and runs from rgit origin … or ssh -p 2222. No browser required." },
  { title = "rgit view", description = "Loopback Zola preview of a working copy (or a bare repo on the host). 127.0.0.1:1111. Not a public git UI." },
  { title = "Rgit Web", description = "Caddy → Bun on loopback 3010 → rgit --json. GitHub-style chrome for people who want it. Same forge root, different uid." },
]

[extra.home_cta]
title = "Install the CLI first. Add the website when you want it."
description = "The forge is rgit. Rgit Web is a companion. Source, deploy scripts, and architecture notes live in the rgit-web repo."
primary_label = "CLI install"
primary_path = "/install/"
secondary_label = "rgit-web on GitHub"
secondary_path = "https://github.com/rconnelly/rgit-web"
+++

Rgit Web is a GitHub-style browser for [Rabun Git](/). It is not the forge. `rgit serve` still listens for git and management commands on SSH port **2222**. The website is a separate Bun process that shells out to the same `rgit` binary with `--json`.

You can skip it. Teams who live in the terminal already have users, keys, merge requests, and CI. [`rgit view`](/docs/everyday-git/#browse-locally) is enough when you only need a local README and file tree. If you want something else in the browser — cgit, gitweb, a page you wrote — point it at the repos, or at the JSON CLI. Rgit Web is one optional client of that contract, not a gate in front of git.

## What you see

Signed-out visitors get the public repository list. Signed-in users see the repos their role allows, and can create `owner/name`. A repository page is `/:owner/:name`: clone URL, visibility, then tabs for **Code**, **Commits**, and **Requests**.

| Path | What it shows |
| --- | --- |
| `/` | Repository list; create when signed in |
| `/:owner/:name` | Tree at HEAD, README when present |
| `/:owner/:name/tree/:ref/…` | Directory |
| `/:owner/:name/blob/:ref/…` | File (markdown rendered; otherwise a pre block) |
| `/:owner/:name/blame/:ref/…` | Per-line blame |
| `/:owner/:name/commits` | Log |
| `/:owner/:name/commit/:sha` | One commit and its diff |
| `/:owner/:name/requests` | Merge request list and open |
| `/:owner/:name/requests/:id` | Show, diff, review, merge |

The hero above is a composed mock of that chrome: cream type on forest cards, gold for public and merge, the same clone URL shape as the [user guide](/docs/). Artistic license — the running app is a bit quieter — but the surfaces are real.

## How it talks to rgit

There is no Postgres, no SQLite, no cache of git objects in the web repo. Durable state stays under `$RABUN_GIT_ROOT`: `users.yaml`, `tokens.yaml`, `visibility.yaml`, bare repos, `refs/rabun/requests/*`.

The request path is short:

1. Caddy terminates TLS and reverse-proxies `127.0.0.1:3010`.
2. `Bun.serve` matches `/api/…` or serves the SPA.
3. A session cookie becomes `--token`. No cookie becomes `--anonymous`.
4. `rgit --json` runs the matching subcommand. Non-zero exit is HTTP 4xx/5xx.

Browse payloads come from rgit’s git-extension layer (`repo tree`, `blob`, `blame`, `log`, `refs`, `diff`). Merge is still **fast-forward only**. The website does not run `git` itself and does not import the Rust crate.

## Sign-in is not SSH

Clone and push stay public-key SSH. The browser cannot usefully present that key, so web auth is a different door:

- Operator sets a web password (`rgit user add … --password` or `rgit user passwd`).
- `rgit auth login` issues a bearer token (`rgit_…`). Only a SHA-256 hash is stored.
- Rgit Web puts that token in an HttpOnly `rgit_session` cookie (14 days). JavaScript never sees it.
- Logout calls `rgit auth logout` and clears the cookie.

People who only clone never need a password. People who review in the browser do.

## On the host

Two systemd units, one data root. `rabun-git.service` is `User=rabun-git` on port 2222. `rgit-web.service` is `User=rgit-web` in group `rabun-git`, loopback 3010, `ReadWritePaths` on the forge root. Forge ACL still applies: Unix group access is not Operator.

Pack and push is the same air-gapped flow as the CLI. The droplet never talks to GitHub. Details: [rgit-web](https://github.com/rconnelly/rgit-web).
