+++
title = "Rgit Web"
description = "Browse, blame, and review in the browser. Same forge as the CLI. Optional."
sort_by = "weight"
template = "web.html"
page_template = "page.html"

[extra]
home_layout = "wide"
home_eyebrow = "Companion UI"
home_hero_image = "/images/hero/rgit-web.png"
home_hero_image_alt = "Rgit Web: ada/website with a file tree, README, clone URL, and a fast-forward merge request."
home_primary_action_label = "GitHub"
home_primary_action_path = "https://github.com/rconnelly/rgit-web"
home_secondary_action_label = "Docs"
home_secondary_action_path = "/docs/"
home_features = [
  { kicker = "Code", title = "Tree, blob, README", description = "owner/name at HEAD. Directories, files, rendered markdown. Git stays SSH on 2222." },
  { kicker = "History", title = "Commits, blame, diffs", description = "Log a ref, open a commit, blame a file, compare two tips." },
  { kicker = "Review", title = "Merge requests", description = "Open, comment, approve, fast-forward merge. Same refs as SSH." },
  { kicker = "Read", title = "Public without an account", description = "Anonymous browse for public repos. Create, review, and merge still need a signed-in user." },
  { kicker = "Auth", title = "Passwords, not keys", description = "Browser sign-in is a password and a cookie. Clone identity stays SSH keys." },
]

[extra.home_learn]
eyebrow = "Presentation"
title = "The CLI is the forge."
description = "Rgit Web has no database. It shells out to rgit --json. Users, trees, and merge requests stay on the forge."
cards = [
  { kicker = "Backend", title = "rgit --json", description = "Each page is a clap subcommand. Debug with the same commands the website runs." },
  { kicker = "ACL", title = "Never Operator", description = "Always --token or --anonymous. A missing flag would list every private repo." },
  { kicker = "Look", title = "DevLab tokens", description = "Cream, pine, and gold. Burton Bun and React 19." },
  { kicker = "Replace", title = "Bring your own", description = "cgit, gitweb, a custom SPA, or nothing. The JSON CLI is the contract." },
]

[extra.home_workflow]
eyebrow = "Optional"
title = "Three ways to look at a tree."
description = "rgit serve does not speak HTTP for git. Clone, push, and merge requests work without a website."
points = [
  { title = "CLI only", description = "Users, keys, requests, and runs from the terminal." },
  { title = "rgit view", description = "Loopback preview of a working copy. Not a public git UI." },
  { title = "Rgit Web", description = "Caddy to Bun to rgit --json. GitHub-style chrome when you want it." },
]

[extra.home_cta]
title = "Install the CLI first."
description = "Add the website when you want it. Source and deploy notes live in the rgit-web repo."
primary_label = "CLI install"
primary_path = "/install/"
secondary_label = "rgit-web on GitHub"
secondary_path = "https://github.com/rconnelly/rgit-web"
+++

Rgit Web is a GitHub-style browser for [Rabun Git](/). It is not the forge. `rgit serve` still listens for git on SSH port **2222**. The website is a separate Bun process that calls the same `rgit` binary with `--json`.

Skip it if the terminal is enough. [`rgit view`](/docs/everyday-git/#browse-locally) covers a local README and file tree. Point cgit, gitweb, or your own app at the JSON CLI if you want something else.

## What you see

Signed-out visitors get the public repository list. Signed-in users see the repos their role allows, and can create `owner/name`. A repository page is `/:owner/:name`: clone URL, visibility, then **Code**, **Commits**, and **Requests**.

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

## How it talks to rgit

No Postgres, no SQLite, no cache of git objects in the web repo. Durable state stays under `$RABUN_GIT_ROOT`: `users.yaml`, `tokens.yaml`, `visibility.yaml`, bare repos, `refs/rabun/requests/*`.

1. Caddy terminates TLS and reverse-proxies `127.0.0.1:3010`.
2. `Bun.serve` matches `/api/…` or serves the SPA.
3. A session cookie becomes `--token`. No cookie becomes `--anonymous`.
4. `rgit --json` runs the matching subcommand. Non-zero exit is HTTP 4xx/5xx.

Browse payloads come from rgit’s git-extension layer (`repo tree`, `blob`, `blame`, `log`, `refs`, `diff`). Merge is still **fast-forward only**. The website does not run `git` itself.

## Sign-in is not SSH

Clone and push stay public-key SSH. The browser cannot present that key, so web auth is a different door:

- Operator sets a web password (`rgit user add … --password` or `rgit user passwd`).
- `rgit auth login` issues a bearer token (`rgit_…`). Only a SHA-256 hash is stored.
- Rgit Web puts that token in an HttpOnly `rgit_session` cookie (14 days). JavaScript never sees it.
- Logout calls `rgit auth logout` and clears the cookie.

People who only clone never need a password. People who review in the browser do.

## On the host

Two systemd units, one data root. `rabun-git.service` is `User=rabun-git` on port 2222. `rgit-web.service` is `User=rgit-web` in group `rabun-git`, loopback 3010, `ReadWritePaths` on the forge root. Forge ACL still applies: Unix group access is not Operator.

Pack and push is the same air-gapped flow as the CLI. The droplet never talks to GitHub. Details: [rgit-web](https://github.com/rconnelly/rgit-web).
