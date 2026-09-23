+++
title = "A git forge you run yourself."
description = "Self-hosted git over SSH. Users, merge requests, and workflow agents on your machines. Browse the files with rgit view."

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
  { kicker = "CI", title = "YAML workflows", description = "Shell steps in .rabun/workflows on push, tag, and request. A runs-on list starts one run each on Linux, macOS, and Windows." },
  { kicker = "Files", title = "Web view", description = "rgit view renders a local tree in the browser: README, file tree, and file contents, on 127.0.0.1:1111." },
]

[extra.home_learn]
eyebrow = "The forge"
title = "Rabun Git (rgit)"
description = "SSH based communication with teams and groups baked in."
cards = [
  { kicker = "People", title = "Users and keys", description = "Create logins, attach SSH keys, and grant read, write, or admin on owner/name." },
  { kicker = "History", title = "Everyday git", description = "Branches, clones, and tags work as they do on any SSH remote. rgit view opens that tree in a browser on this machine." },
  { kicker = "Host", title = "Ubuntu pack and push", description = "Ship the binary, env file, and rabun-git.service over SSH. Data lives under /var/lib/rabun-git." },
  { kicker = "Builders", title = "Agents on your machines", description = "Register a builder per label. rgit agent polls over SSH, claims the oldest matching job, clones that SHA, and writes the log back." },
]

[extra.home_workflow]
eyebrow = "Builders"
title = "Linux, macOS, and Windows from one workflow."
description = "runs-on: [linux, macos, windows] fans out to one run per label. Each agent polls the forge on port 2222, clones that commit, and runs the steps. Labels must match exactly."
points = [
  { title = "Linux", description = "Label linux. With no registered linux builder, the job still runs on the forge host as the rabun-git user, using sh -c." },
  { title = "macOS", description = "rgit origin agent register mac --label macos, then rgit agent --labels macos on that Mac. launchd keeps the poll loop running. The shell defaults to sh." },
  { title = "Windows", description = "The same poll loop with --labels windows. Steps default to pwsh -NoProfile -Command unless the job sets shell." },
]

[extra.home_cta]
title = "Read the guide, then start the forge."
description = "Written for people who already use git clone, commit, and push."
primary_label = "Install"
primary_path = "/docs/install/"
secondary_label = "Compared to GitHub"
secondary_path = "/docs/compared-to-github/"
+++

Rabun Git stores bare repositories on a machine you administer. Teammates use `git`. Operators use `rgit` for users, keys, access, merge requests, and builder agents. [`rgit view`](/docs/everyday-git/#browse-locally) shows the files in a browser on the machine that has the checkout.

Download a source snapshot of `master` from the [releases](/releases/) page.
