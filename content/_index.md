+++
title = "Rgit is Git with etiquette."
description = "Self-hosted Git over SSH. Conventional Commits and SemVer 2.0 by default."

[extra]
home_layout = "wide"
home_eyebrow = "Rabun Git"
home_hero_image = "/images/hero/forge.svg"
home_hero_image_alt = "Terminal session: rgit registers an admin key, then git pushes to ssh."
home_primary_action_label = "Install"
home_primary_action_path = "/install/"
home_secondary_action_label = "Docs"
home_secondary_action_path = "/docs/"
home_features = [
  { kicker = "Etiquette", title = "SemVer 2.0", description = "feat, fix, and breaking commits bump the version. The forge can reject a messy push." },
  { kicker = "Remote", title = "SSH repositories", description = "Bare repos on port 2222. Clone and push with ordinary git." },
  { kicker = "Review", title = "Merge requests", description = "Open, review, and fast-forward merge from the CLI." },
  { kicker = "CI", title = "YAML workflows", description = "Shell steps on push, tag, and request. Linux, macOS, and Windows from one file." },
  { kicker = "Browser", title = "Rgit Web", description = "Optional GitHub-style UI. Browse, blame, and review — or bring your own." },
]

[extra.home_learn]
eyebrow = "The forge"
title = "A git remote on a machine you run."
description = "Users, keys, and roles stay with you. Etiquette is on by default."
cards = [
  { kicker = "People", title = "Users and keys", description = "Create logins, attach SSH keys, grant read, write, or admin." },
  { kicker = "History", title = "Everyday git", description = "Branches, clones, and tags work like any SSH remote." },
  { kicker = "Versions", title = "Etiquette", description = "Keep Conventional Commits and SemVer, or switch the gates off." },
  { kicker = "Builders", title = "Agents", description = "A builder polls over SSH, runs the job, writes the log back." },
]

[extra.home_workflow]
eyebrow = "Builders"
title = "Linux, macOS, and Windows from one workflow."
description = "One runs-on list, one run per label. Each agent polls the forge, clones that commit, and runs the steps."
points = [
  { title = "Linux", description = "No linux builder registered? The job runs on the forge host." },
  { title = "macOS", description = "Register a Mac builder and keep the agent polling." },
  { title = "Windows", description = "Same poll loop. Steps default to PowerShell." },
]

[extra.home_cta]
title = "Start the forge."
description = "If you already use git, you already know the workflow."
primary_label = "Install"
primary_path = "/install/"
secondary_path = ""
+++

Host bare repositories on a machine you administer. Clone and push with `git`. Manage users, keys, merge requests, builders, and [releases](/docs/versioning/) with `rgit`. [Rgit Web](/web/) is optional. So is [`rgit view`](/docs/everyday-git/#browse-locally).

[Install](/install/) a Linux archive, or [build from source](https://github.com/rconnelly/rgit).
