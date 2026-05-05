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

### One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/Spyced-Concepts/claude-dotfiles/main/install.sh | bash
```

Downloads claude-dotfiles and runs the guided setup. Requires Claude Code and git. No other dependencies.

### Manual install

```bash
# 1. Clone this repo
git clone https://github.com/Spyced-Concepts/claude-dotfiles.git ~/Projects/claude-dotfiles

# 2. Run setup
bash ~/Projects/claude-dotfiles/scripts/setup.sh
```

Setup guides you through everything interactively — including connecting your personal private config repo, which is required to complete the setup.

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

## Checking status

```bash
bash ~/Projects/claude-dotfiles/scripts/status.sh
```

Checks four things: machine.json, CLAUDE.md symlink, claude-dotfiles version, and personal config repo sync. Setup is not complete until all four pass.

```bash
# Quiet mode — exit code only (0 = ok, 1 = issues)
bash ~/Projects/claude-dotfiles/scripts/status.sh --quiet
```

---

## Updating your config

```bash
bash ~/Projects/claude-dotfiles/scripts/update.sh
```

Or use the alias added by the one-line installer:

```bash
claude-update
```

---

## Uninstalling

```bash
bash ~/Projects/claude-dotfiles/scripts/uninstall.sh
```

Removes all symlinks from `~/.claude/` and offers to restore a plain local `CLAUDE.md`. You are asked before anything is deleted. The repos are not deleted unless you explicitly confirm each one.

**Detach mode** — if you want a one-time snapshot of your config (useful for secure or air-gapped environments):

```bash
bash ~/Projects/claude-dotfiles/scripts/uninstall.sh
# → Yes to restore plain CLAUDE.md
# → No to removing machine.json and settings.json
# → No to deleting repos
```

This gives you a standalone `~/.claude/CLAUDE.md` that is no longer linked to any repo. Your repos are still there if you want to reinstall later.

**Reinstall at any time:**

```bash
curl -fsSL https://raw.githubusercontent.com/Spyced-Concepts/claude-dotfiles/main/install.sh | bash
```

---

## CLI reference

| Script | Description |
|---|---|
| `scripts/setup.sh` | First-time setup on a new machine. Interactive. |
| `scripts/update.sh` | Pull both repos and redeploy symlinks. Non-interactive. |
| `scripts/status.sh` | Check health, version, and sync state. |
| `scripts/uninstall.sh` | Remove symlinks; optionally delete repos. |
| `install.sh` | One-line bootstrap: downloads and runs setup. |

All scripts support `--help` / `-h`.

**Man pages** (Linux/macOS):

```bash
# View from the repo directory
man ./man/man1/claude-dotfiles.1
man ./man/man1/claude-dotfiles-setup.1
man ./man/man1/claude-dotfiles-status.1
man ./man/man1/claude-dotfiles-update.1
```

---

## File structure

```
claude-dotfiles/
├── CLAUDE.md                   ← global Claude instructions (symlinked to ~/.claude/CLAUDE.md)
├── machine.json.template       ← template; copy to ~/.claude/machine.json
├── settings.json.template      ← template; copy to ~/.claude/settings.json
├── install.sh                  ← one-line bootstrap installer
├── scripts/
│   ├── setup.sh                ← guided first-time setup (-h for help)
│   ├── update.sh               ← pull latest and redeploy (-h for help)
│   └── status.sh               ← health and sync check (-h for help)
├── commands/                   ← built-in AI commands (symlinked to ~/.claude/commands/)
├── man/man1/                   ← man pages for all scripts
├── schemas/                    ← JSON schemas for machine.json and shared.json
├── examples/
│   └── machine.json.example    ← worked example
└── LICENSE                     ← MIT
```

---

## machine.json structure

```json
{
  "name": "macbook-pro",
  "os": "macos",
  "home": "/Users/yourname",
  "knowledge_root": "/Users/yourname",
  "knowledge_dirs": {
    "notes": "/Users/yourname/notes"
  },
  "project_root": "/Users/yourname/Projects",
  "command_prefix_enabled": false,
  "command_prefix": "--"
}
```

Knowledge directory keys become uppercase variables in your Claude sessions:
- `"notes"` → `$NOTES`

### Enabling custom commands

Custom commands are **disabled by default**. To enable:

1. Set `command_prefix_enabled: true` in `~/.claude/machine.json`
2. Set your preferred prefix — `--` is the default, but use anything that feels natural to you (`!`, `>`, `cmd:`, `run:`, etc.)
3. **Do not use `/`** — Claude Code's CLI intercepts `/word` as built-in commands before they reach Claude
4. **No prefix:** set `command_prefix` to `""` to use command names directly (e.g. just type `daily`). This works well if your command names are distinctive enough that they won't appear in normal conversation.

Once enabled, type `--daily` (or whatever your prefix is) in any Claude Code session to run a command. Type `--commands` to list all available commands.

> **Not sure what commands are available?** Type `--commands` after enabling.

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
