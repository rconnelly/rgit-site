+++
title = "A git forge you run yourself."
description = "Self-hosted git over SSH. Users, merge requests, and a small workflow runner. Bring your own editor and web viewer."

[extra]
home_layout = "wide"
home_eyebrow = "Rabun Git"
home_hero_image = "/images/hero/forge.svg"
home_hero_image_alt = "Terminal session: rgit registers an admin key, then git pushes to ssh://git@HOST:2222."
home_primary_action_label = "Install"
home_primary_action_path = "/docs/install/"
home_secondary_action_label = "User guide"
home_secondary_action_path = "/docs/"
home_features = [
  { kicker = "Remote", title = "SSH repositories", description = "Bare repos on port 2222. Clone and push with ordinary git. Your existing sshd on port 22 stays put." },
  { kicker = "Review", title = "Merge requests", description = "Open, review, and fast-forward merge from the CLI. Protected main and master stay with admins." },
  { kicker = "CI", title = "YAML workflows", description = "Small shell workflows in .rabun/workflows on push, tag, and request. No GitHub Actions runner." },
]

[extra.home_learn]
eyebrow = "The forge"
title = "Rabun Git (rgit)"
description = "SSH based communication with teams and groups baked in."
cards = [
  { kicker = "People", title = "Users and keys", description = "Create logins, attach SSH keys, and grant read, write, or admin on owner/name." },
  { kicker = "History", title = "Everyday git", description = "Branches, clones, and tags work as they do on any SSH remote." },
  { kicker = "Host", title = "Ubuntu pack and push", description = "Ship the binary, env file, and rabun-git.service over SSH. Data lives under /var/lib/rabun-git." },
]

[extra.home_workflow]
eyebrow = "First hour"
title = "From a checkout to a remote your team can push."
description = "Install the binary, start serve, register one admin key, then create owner/name."
points = [
  { title = "Install", description = "cargo install from a clone, then link the rgit command beside rabun-git." },
  { title = "Serve", description = "Pack-and-push onto Ubuntu, or run init and serve yourself. Health listens on 127.0.0.1:8792." },
  { title = "Push", description = "git remote add origin ssh://git@HOST:2222/owner/name.git" },
]

[extra.home_cta]
title = "Read the guide, then start the forge."
description = "Written for people who already use git clone, commit, and push."
primary_label = "Install"
primary_path = "/docs/install/"
secondary_label = "Compared to GitHub"
secondary_path = "/docs/compared-to-github/"
+++

Rabun Git stores bare repositories on a machine you administer. Teammates use `git`. Operators use `rgit` for users, keys, access, and merge requests.
