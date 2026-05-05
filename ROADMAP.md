# Roadmap

This is the public roadmap for claude-dotfiles. Items here reflect our current intentions — priorities may shift based on community feedback and real-world usage. 

**Want to influence the roadmap?** Open a [feature request](https://github.com/Spyced-Concepts/claude-dotfiles/issues/new?template=feature_request.md) or start a Discussion. The best features come from real problems.

---

## Release schedule

**v1.4.0** — releasing now (ahead of the June cycle). The command dispatch system and built-in command library are compelling enough to ship early.

Next scheduled after v1.4.0: **v1.5.0 — June 2026**.

---

## Released

### ✅ v1.0.0 — Initial release

- `CLAUDE.md` template with machine config system and keyword framework
- `machine.json` for machine-specific paths
- `setup.sh` / `update.sh` for one-command setup on any machine
- MIT licence, SECURITY.md, CONTRIBUTORS.md, GitHub issue templates

### ✅ v1.1.0 — Discovery + slash commands

- **`knowledge_root`** — auto-discover all subdirectories of a parent folder as knowledge directories; no need to add each one individually
- **`project_root`** — clearly separates code artefacts from knowledge/docs
- **Built-in slash commands** — `/update` and others; symlinked to `~/.claude/commands/` so they work in any Claude Code session; personal workflow commands belong in your private config repo
- **Interactive `setup.sh`** — guided prompts, recursive discovery, command installation

---

## In progress / near term

### 🔄 v1.2.0 — Multi-AI-CLI adapter framework

Right now, claude-dotfiles is Claude Code-specific — `CLAUDE.md`, the `commands/` format, and the `machine.json` reading are all Claude Code concepts. Many developers use multiple AI CLI tools. The adapter framework makes claude-dotfiles useful across all of them.

**Design:** an `adapters/` directory, one subfolder per AI CLI. `setup.sh` asks which CLI(s) you use and installs the right adapter.

| Adapter | Status |
|---|---|
| `adapters/claude-code/` | ✓ Current implementation |
| `adapters/aider/` | Planned |
| `adapters/gemini-cli/` | Planned |

**Community input wanted:** Which AI CLIs do you use? What would a good adapter look like for your tool? [Open a discussion](https://github.com/Spyced-Concepts/claude-dotfiles/discussions) or feature request.

### 🔄 v1.2.0 — Re-run setup for new settings

When you run `/update` and a new version introduces new `machine.json` fields, you should be able to configure them without a full reinstall. `setup.sh --reconfigure` will diff your installed `machine.json` against the template and guide you through any new settings only.

### 🔄 v1.2.0 — Personal config as a separate private repo

The recommended pattern for personal configuration is a completely **separate private repo** — not a fork of claude-dotfiles. You clone the public tool cleanly and keep your personal config (`shared.json`, custom `CLAUDE.md`, custom commands) in your own private repo with no connection to this one.

**Why not a fork:** forks invite accidental PRs of personal config into the public repo, creating unnecessary admin. Keep them completely separate.

**How it works:**
```
Spyced-Concepts/claude-dotfiles   public tool — clone, never fork
yourname/my-claude-config         your private repo — shared.json, custom commands, CLAUDE.md overrides
~/.claude/machine.json            machine-local — paths only, never committed
```

`setup.sh` will gain an option to point at your personal config repo and layer it on top of the public tool automatically.

---

## Planned

### v2.0.0 — Native package with UI (major rewrite)

**v2.0.0 is the big one.** The current bash script approach works but is fundamentally limited — it assumes git, requires a terminal, and has no real Windows story beyond Git Bash. v2.0.0 rewrites claude-dotfiles as a proper cross-platform package.

**Language:** Node.js (primary) — Claude Code itself is Node.js, so a Node package integrates naturally and users who have Claude Code already have Node. Python as an alternative runtime where Node isn't available.

**Distribution:**
```bash
npm install -g claude-dotfiles   # primary
brew install claude-dotfiles     # macOS
winget install claude-dotfiles   # Windows
```

**What changes:**

- **No git required** — package installs to the correct system location automatically; `claude-dotfiles update` handles upgrades
- **True cross-platform** — proper Windows installer (`.exe` or winget); no Git Bash required
- **Local web UI** — `claude-dotfiles ui` launches a simple local web interface for managing `machine.json`, knowledge directories, commands, and settings without editing JSON directly. Accessible to non-technical users.
- **Enable/disable everything** — every rule, command, path, and behaviour becomes an object (or array of objects) with an `enabled` boolean as a first-class field. Nothing is hardcoded on or off. Users can disable any built-in behaviour (greeting, version check, command dispatch, startup checks) without editing CLAUDE.md. Schema redesign to treat all configurable items as objects: `{ "enabled": true, ... }`. This makes the config composable, inspectable, and safe to extend without breaking existing installs.
- **Rule-level permissions** — each rule or behaviour object carries permission flags controlling how it can execute, set per machine, off by default. Example schema: `{ "enabled": true, "allow_background": false, "allow_no_prompt": false }`. Allows users to explicitly opt in to background execution or prompt-free operation for specific rules on specific machines, without granting blanket permissions. Builds on the enable/disable object schema above.
- **Config CLI** — `claude-dotfiles config get/set/list/unset` for reading and writing `machine.json` fields from the command line without editing JSON directly. Scriptable, inspectable, and AI-friendly — the same pattern as `git config`. Includes AI-facing `commands/config.md` so Claude can read and write config fields safely through the CLI rather than inline Python.
- **Claude Code integration** — the package can communicate directly with Claude Code's APIs rather than relying on CLAUDE.md text instructions
- **Personal config management** — `claude-dotfiles config init` guides users through setting up a private config repo or connecting to the hosted service
- **Plugin system** — command packs installable from npm (`npm install claude-dotfiles-writing-pack` gives writers a curated set of commands)

**Why this matters:** v2.0.0 is when claude-dotfiles becomes genuinely accessible to non-developers. The UI removes the last barrier. The package removes the git/bash requirement. The plugin system makes it extensible without requiring users to manage files.

---

### v2.0.0 — atlink claude integration

[atlink](https://spycedconcepts.co.uk) — a developer workflow CLI by Spyced Concepts (coming soon) — will include an `atlink claude` subcommand group for managing claude-dotfiles without touching git directly:

```bash
atlink claude init      # clone claude-dotfiles and run setup on this machine
atlink claude update    # pull latest and redeploy
atlink claude status    # show current config state and available updates
```

This makes claude-dotfiles accessible to developers who aren't comfortable with git.

---

## Planned

### v1.6.0 — Migrate existing local config into personal repo

When a user runs `setup.sh` and connects a personal config repo, but already has a plain `~/.claude/CLAUDE.md` with custom rules, setup currently backs the file up and moves on. The custom rules are orphaned — they don't sync anywhere.

This feature makes that migration active:

1. Setup detects a pre-existing plain CLAUDE.md with content not in the personal repo
2. Shows a summary of the local-only rules
3. Asks: *"Your existing CLAUDE.md has content not in your personal config repo. Import it? (y/n)"*
4. If yes: appends the local-only sections to the personal CLAUDE.md, commits, and pushes

**Related:** Some rules genuinely belong on one machine only (behaviour tied to local paths or tools). A `## Machine-local` section convention in CLAUDE.md — excluded from the import — would handle this cleanly.

**Scope:** Changes to `setup.sh` (diff + import step), convention for machine-local sections, UAT cases.

---

## Backlog

*Ideas under consideration — not yet scheduled:*

- **Shared settings across machines** — a `shared.json` for carrying canonical variable names and settings across machines. The design principle: variable *names* are portable; path *values* are machine-specific.

  **Architecture:**
  ```
  Spyced-Concepts/claude-dotfiles  (public — this repo)
  └── shared.json.template         schema only; defines the concept, not your names

  yourname/my-dotfiles             (your private fork or private repo)
  ├── shared.json                  YOUR canonical variable names ($NOTES, $WORK, etc.)
  ├── CLAUDE.md                    your customised instructions
  └── commands/                    your custom commands

  ~/.claude/machine.json           machine-local; maps $NOTES → /actual/path/on/this/machine
  ```

  If every machine maps `"notes"` → wherever notes live locally, then any command referencing `$NOTES` works everywhere without modification. `shared.json` lives in the user's *private* fork — never in the public tool repo. The public repo ships only the schema and template.

- **Proper system install** — currently claude-dotfiles assumes it lives in `~/Projects/` or `~/`. A mature tool should install to a proper system location (`~/.local/share/claude-dotfiles/` on Linux, Homebrew Cellar on macOS, a proper npm global package, etc.) and derive all paths from its installed location — never from assumptions about the user's home directory structure. The repo stays open source on GitHub; only the install mechanism changes. Homebrew formula and npm package are the target delivery mechanisms. All internal path resolution should use symlinks (`readlink ~/.claude/CLAUDE.md`) rather than hardcoded paths.

- **Command override (private > public)** — `~/.claude/commands/` is a real directory containing individual symlinks from both the public tool and any personal config repo. Personal commands with the same name as a public built-in override it automatically (`ln -sf` overwrites the symlink). This enables full customisation of any built-in command — replace `daily.md` with your own version and it just works. The public tool's `setup.sh` already implements this (individual file symlinks, not directory symlink). Personal config repos should do the same and run after the public setup.

- **Clearer settings.json allowlist descriptions** — the permissions allowlist entries (e.g. `Bash(date *)`, `WebFetch(domain:wttr.in)`) are not immediately obvious to new users. Add inline documentation or a guided prompt that explains what each common entry does and when to add it. The `setup` keyword and `setup.sh` should offer common presets rather than requiring users to know the exact format.

- **Shell completions** — bash, zsh, fish completions for `setup.sh` flags

- **UAT test runner** *(DevOps/QA)* — a script that runs all non-interactive UAT tests, pipes known inputs to interactive tests, and captures all output to a timestamped log file that can be consumed by an AI without copy-paste. Hands-on terminal testing is retained — testers can still run tests manually and see the full experience. The runner is for output capture, not for replacing the human in the loop.

- **Community command gallery** — curated `/commands` contributions from the community

- **Multi-profile support** — switch between different CLAUDE.md profiles per project type (e.g., a "security review" profile vs a "writing" profile)

- **Validation** — `setup.sh --validate` checks that all paths in `machine.json` actually exist and that all variables referenced in commands are defined

- **Windows native** — proper PowerShell setup script alongside the Git Bash version

- **Homebrew formula** — `brew install claude-dotfiles` for macOS

---

## Paid services *(no release date — future commercial)*

The core claude-dotfiles tool is and will always remain free and open source. These paid services are planned for a future commercial tier — they add managed infrastructure and team-level features on top of the free self-hosted foundation.

---

### 💳 Hosted personal config

A managed config service for users who don't want to maintain a private git repo. Your `shared.json`, custom commands, and personal `CLAUDE.md` are stored securely and synced automatically across all your machines — no git required.

**Who it's for:** non-developers and anyone who wants cross-machine sync without managing a GitHub repo themselves.

**What it replaces:** the private git repo step in the current setup flow. Everything else stays the same — `machine.json` remains local, the public tool remains free.

**Integration point:** will be available via `setup.sh` as an alternative to the "connect your own repo" path, and via `atlink claude init --hosted` when atlink reaches its commercial release.

---

### 💳 Organisation-level configs, commands, and rules

A shared config layer that sits above the individual personal config — allowing teams and organisations to define rules, commands, and CLAUDE.md sections that apply to every member automatically.

**Who it's for:** development teams, agencies, and organisations who want consistent AI behaviour across all their developers without each person managing it manually.

**What it enables:**

| Capability | Description |
|---|---|
| **Org-wide rules** | Organisation-wide conventions (commit format, code style, security rules) pushed to every member's Claude sessions automatically |
| **Group rules** | Department or team-level rules that apply to a subset of members — e.g. the security team gets stricter scanning rules; the marketing team gets brand voice guidelines; engineering gets repo-specific workflow rules |
| **Shared commands** | Org or group commands (e.g. `--deploy`, `--review`, `--standup`) available to the right people without individual setup |
| **Config inheritance** | Four-layer stack: public tool → org config → group config → personal config. Each layer can extend the one above; org security rules can be marked non-overridable. |
| **Centralised management** | Admins manage org and group configs from a dashboard or CLI; changes propagate to all relevant members on next session start |
| **Audit trail** | Every config change is versioned and attributable — who changed what rule, when, and why |

**Group config use cases:**

- Engineering team gets code review and branch workflow rules
- Security team gets stricter scanning and incident response commands
- Marketing team gets brand voice, British English enforcement, and content guidelines
- Contractors get a read-only limited command set with no access to internal rules

**Pricing model:** per-organisation workspace (not per-seat) — consistent with Spyced Concepts' SME-first pricing philosophy. Group config is included in the org tier; no additional charge per group.

---

## Strategic direction — beyond developers

Claude Code is positioned as a developer tool, but its capabilities extend far beyond software development. The ability to read local files, run commands, and maintain persistent context via `~/.claude/CLAUDE.md` makes it genuinely useful for any knowledge worker who works with documents on their computer.

**claude-dotfiles exists to make this accessible.** The knowledge directory system means Claude reads your actual files — your research, your notes, your project documents — and understands your specific work rather than starting from scratch every conversation.

**Target non-developer use cases:**

| Who | What they bring to Claude | What Claude gives back |
|---|---|---|
| Writers | Research notes, character docs, plot outlines, drafts | A collaborator who has read everything and remembers it |
| Filmmakers | Scripts, production notes, shot lists, research | A script editor and production assistant |
| Designers | Briefs, brand guidelines, client notes, inspiration | A briefed creative partner |
| Advertisers | Campaign notes, audience research, copy drafts | A copywriter who knows the brief |
| Researchers | Papers, notes, source material, bibliography | A research assistant who has read the literature |
| Small business owners | Processes, client notes, templates | An assistant who knows how the business works |

**What needs to happen to reach this audience:**

- ✅ **`curl` one-line install** — no git or npm knowledge required *(added v1.4.0)*
- ✅ **Conversational first-run** — Claude asks friendly questions and builds the config from answers *(added v1.4.0)*
- 🔄 **Plain language throughout** — documentation written for humans, not engineers
- 🔄 **npm package / Homebrew** — `brew install claude-dotfiles` or `npm install -g claude-dotfiles`
- 🔄 **Windows installer** — no Git Bash required
- 🔄 **Non-developer starter commands** — built-in commands for writing, research, creative work
- 🔄 **Hosted config service** — no git required for cross-machine sync

---

## How to contribute to the roadmap

- **Feature requests** → [open an issue](https://github.com/Spyced-Concepts/claude-dotfiles/issues/new?template=feature_request.md)
- **Discussion** → [GitHub Discussions](https://github.com/Spyced-Concepts/claude-dotfiles/discussions)
- **Direct contact** → [spycedconcepts.co.uk](https://spycedconcepts.co.uk)

We read everything.
