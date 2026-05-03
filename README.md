# claude-dotfiles

A tool-agnostic personal configuration framework for [Claude Code](https://claude.ai/code) by [Anthropic](https://anthropic.com).

Sync your Claude Code global configuration across multiple machines — without tying yourself to any specific note-taking app, project management tool, or folder structure. Works with Obsidian, plain folders, VS Code workspaces, Notion exports, or anything else that produces markdown.

> Built for [Claude Code](https://claude.ai/code) — Anthropic's official CLI for Claude. If you're from Anthropic and interested in this project, we'd love to hear from you: [spycedconcepts.co.uk](https://spycedconcepts.co.uk)

**[View the roadmap →](ROADMAP.md)** · **[Changelog →](VERSION.md)** · **[Contributing →](CONTRIBUTORS.md)**

---

## What it does

Claude Code's global configuration lives in `~/.claude/CLAUDE.md`. This file is machine-local and not synced anywhere by default. `claude-dotfiles` solves this by:

1. Keeping your `CLAUDE.md` in a version-controlled git repo
2. Symlinking it to `~/.claude/CLAUDE.md` on each machine
3. Keeping machine-specific paths in `~/.claude/machine.json` (not synced — stays local)
4. Providing a one-command setup for new machines

---

## Concepts

### CLAUDE.md
Your global Claude Code instructions. Loaded in every session regardless of working directory. Contains your identity, workflow preferences, session greeting rules, and custom keywords.

### machine.json
Machine-specific paths. Never committed to git. Contains:
- Your home directory path
- Your projects directory
- Your **knowledge directories** — folders of markdown files Claude reads for context

### Knowledge directories
Any folder of markdown files Claude reads to understand your context. Tool-agnostic by design — these can be:
- Obsidian vaults
- Plain folders of notes
- Exported Notion pages
- VS Code workspace docs
- Anything else in markdown

### Personal configuration

Your personal config (`shared.json`, custom commands, your own `CLAUDE.md` additions) lives in a **separate private repo** — not a fork of this one. Clone the public tool cleanly; keep your personal config entirely separate.

```
Spyced-Concepts/claude-dotfiles   ← clone this; never fork it
yourname/my-claude-config         ← your private repo; your config
~/.claude/machine.json            ← local paths; never committed anywhere
```

**Not sure where to start?** Once the public tool is set up, open Claude Code and say:

> *"Help me set up a personal claude-config repo with my own commands and CLAUDE.md"*

Claude will ask you what you need, create the repo structure, and configure everything interactively.

A hosted config service (no git required) is on the [roadmap](ROADMAP.md).

---

## Quick start

```bash
# 1. Fork or clone this repo
git clone git@github.com:Spyced-Concepts/claude-dotfiles.git ~/Projects/claude-dotfiles

# 2. Run setup
bash ~/Projects/claude-dotfiles/scripts/setup.sh

# 3. Edit your machine config
nano ~/.claude/machine.json

# 4. Customise your CLAUDE.md
nano ~/Projects/claude-dotfiles/CLAUDE.md

# 5. Open Claude Code and type: setup
# Claude will walk you through the config interactively.
```

---

## New machine setup

On any new machine:

```bash
# Install Claude Code first
npm install -g @anthropic-ai/claude-code

# Clone your fork
git clone git@github.com:YOUR-USERNAME/claude-dotfiles.git ~/Projects/claude-dotfiles

# Run setup
bash ~/Projects/claude-dotfiles/scripts/setup.sh
```

Setup will:
- Create `~/.claude/` if it doesn't exist
- Symlink `CLAUDE.md` to `~/.claude/CLAUDE.md`
- Copy `machine.json.template` to `~/.claude/machine.json`
- Copy `settings.json.template` to `~/.claude/settings.json`

Then fill in your machine-specific paths in `~/.claude/machine.json`.

---

## Updating your config

```bash
# Pull latest and redeploy symlinks
bash ~/Projects/claude-dotfiles/scripts/update.sh
```

Or add an alias to your shell:

```bash
alias claude-update='bash ~/Projects/claude-dotfiles/scripts/update.sh'
```

---

## File structure

```
claude-dotfiles/
├── CLAUDE.md                   ← your global Claude instructions (symlinked)
├── machine.json.template       ← copy to ~/.claude/machine.json; fill in paths
├── settings.json.template      ← copy to ~/.claude/settings.json; customise allowlist
├── scripts/
│   ├── setup.sh                ← one-time setup on a new machine
│   └── update.sh               ← pull latest and redeploy
├── examples/
│   └── machine.json.example    ← a worked example
├── .gitignore                  ← excludes machine.json, settings.json
└── LICENSE                     ← MIT
```

---

## machine.json structure

```json
{
  "name": "macbook-pro",
  "os": "macos",
  "home": "/Users/yourname",
  "knowledge_dirs": {
    "notes": "/Users/yourname/notes",
    "work": "/Users/yourname/work-docs"
  },
  "projects": "/Users/yourname/Projects"
}
```

Knowledge directory keys become uppercase variables in your Claude sessions:
- `"notes"` → `$NOTES`
- `"work"` → `$WORK`

Reference them in `CLAUDE.md` to point Claude at your context files.

---

## Customising CLAUDE.md

The included `CLAUDE.md` is a starting template. Key sections to customise:

| Section | What to do |
|---|---|
| `## Identity` | Add your name, role, and location |
| `## Session Greeting` | Define what Claude reads at session start |
| `## Keywords` | Add or modify trigger words for common actions |
| `## Knowledge Directories` | Add instructions for reading your specific dirs |

The `## Machine Configuration` section works without modification — it reads your `machine.json` automatically.

---

## OS compatibility

| OS | Shell | Supported |
|---|---|---|
| macOS | zsh / bash | ✓ |
| Linux (Ubuntu/Zorin/Debian) | bash / zsh | ✓ |
| Windows | Git Bash | ✓ (symlinks require Developer Mode or admin) |

**Windows note:** Enable Developer Mode in Windows Settings to allow symlinks without admin elevation, or run `setup.sh` as administrator once.

---

## Integration with atlink *(coming soon)*

**atlink** — a developer workflow CLI by [Spyced Concepts](https://spycedconcepts.co.uk) — will include a `claude` subcommand for managing `claude-dotfiles` from the command line without touching git directly:

```bash
atlink claude init      # set up claude-dotfiles on this machine
atlink claude update    # pull latest config and redeploy
atlink claude status    # show current config state
```

atlink is currently in private development and will be released publicly soon. Watch this repo for updates.

---

## Contributing

This is an MIT-licensed open project. Fork it, improve it, submit PRs. Issues and feature requests welcome.

---

## Licence

MIT — see [LICENSE](LICENSE).

Made by [Spyced Concepts Ltd.](https://spycedconcepts.co.uk)

Built for [Claude Code](https://claude.ai/code) by [Anthropic](https://anthropic.com). This project is not affiliated with or endorsed by Anthropic — it is an independent community configuration framework.

**GitHub topics to set when creating the repo:**
`claude-code` `anthropic` `claude` `dotfiles` `developer-tools` `ai-tools` `claude-ai`
