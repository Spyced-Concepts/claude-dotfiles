# Claude Code — Global Configuration

<!--
  claude-dotfiles: A tool-agnostic Claude Code personal configuration framework.
  https://github.com/Spyced-Concepts/claude-dotfiles

  This file is your global Claude Code configuration. It is loaded in every
  Claude Code session regardless of working directory.

  Symlink this to ~/.claude/CLAUDE.md:
    ln -s ~/Projects/claude-dotfiles/CLAUDE.md ~/.claude/CLAUDE.md

  Machine-specific paths live in ~/.claude/machine.json (not synced — see
  machine.json.template for structure).
-->

---

## First Run — Guided Setup

At the very start of each session, check whether `~/.claude/machine.json` exists:

```bash
cat ~/.claude/machine.json 2>/dev/null
```

**If the file does not exist:** this is a first run. Greet the user warmly, explain what Claude Code can do for them in plain language, and guide them through setup using simple conversational questions — no technical jargon. Ask:

1. *"What's your name?"*
2. *"What kind of work do you do? (e.g. writing, design, film, marketing, software — anything)"*
3. *"Where do you keep your main working documents and notes on this computer?"* — this becomes their knowledge directory; explain it as "the folder Claude will read to understand your work"
4. *"Where do you keep your code or project files?"* — only ask if they seem technical; skip gracefully if not relevant
5. *"What would you like to call this computer?"* (e.g. "my laptop", "home mac")

From their answers, build `~/.claude/machine.json` and write it. Confirm what was set up in plain language. Then offer to help them with whatever they came to do.

**Anyone can use Claude Code** — not just developers. Writers, designers, filmmakers, researchers, advertisers, and anyone who works with documents and notes on their computer can benefit. The knowledge directory system means Claude reads your actual files and understands your specific work, rather than starting from scratch every conversation.

---

## Machine Configuration

At session start, load the machine config:

1. Run `cat ~/.claude/machine.json`
2. If the file exists, extract and hold the following variables for the session:

| Variable | Source field | Description |
|---|---|---|
| `$HOME_DIR` | `home` | Home directory |
| `$PROJECTS` | `projects` | Local projects directory |

Then load any additional knowledge directories defined under `knowledge_dirs`:

```
Each key in knowledge_dirs becomes a variable: $KEY_NAME (uppercase)
Example: "notes": "/home/user/notes" → $NOTES
```

3. If `~/.claude/machine.json` does not exist, run the `setup` keyword before continuing.

---

## Startup Checks

After loading machine.json, run the following checks **silently**. Report only when something needs attention — these are non-blocking warnings, never errors that stop the session.

### claude-dotfiles version check

If `dotfiles_dir` is present in machine.json:

```bash
git -C <dotfiles_dir> fetch --quiet origin 2>/dev/null
local_sha=$(git -C <dotfiles_dir> rev-parse HEAD 2>/dev/null)
remote_sha=$(git -C <dotfiles_dir> rev-parse @{u} 2>/dev/null)
```

If `local_sha` and `remote_sha` differ (and `remote_sha` is non-empty), output one warning line:

> ⚠️ claude-dotfiles has updates available. Run: `bash <dotfiles_dir>/scripts/update.sh`

### Personal config repo sync check

If `personal_config_dir` is present in machine.json:

```bash
git -C <personal_config_dir> fetch --quiet origin 2>/dev/null
status=$(git -C <personal_config_dir> status -b --porcelain 2>/dev/null)
```

- If `status` contains `[behind`: warn "⚠️ Your personal config has unpulled changes. Run: `git -C <personal_config_dir> pull`"
- If `status` contains `[ahead`: warn "⚠️ Your personal config has unpushed commits. Run: `git -C <personal_config_dir> push`"

### Setup completion check

If the Identity section below still contains placeholder text (e.g. `[Your Name]`, `[Your Role]`), check this by running:

```bash
grep -q '\[Your Name\]' ~/.claude/CLAUDE.md 2>/dev/null
```

If the placeholder is found, tell the user their setup is not complete and offer to help:

> *"Your claude-dotfiles setup isn't fully configured — the Identity section still has placeholder values. Would you like help setting up a private config repo to add your identity and personal commands?"*

If the user says yes, guide them through creating a private GitHub repo, cloning it, copying and editing the CLAUDE.md template, and re-running setup.

---

## Session Greeting

Greet the user at the start of each session with:

1. **Date and day** — run `date` to get current date and time
2. **Current priorities** — read from any knowledge directory files the user has configured for todos/priorities
3. **Open items** — anything flagged as urgent or overdue

Keep it concise — a morning glance, not a report.

**Once-per-day gate:** Check `~/.claude/greeting-date`. If it matches today's date, skip the greeting and output "Greeting already run today." Otherwise run the greeting and write today's date to `~/.claude/greeting-date` when done.

---

## Custom Commands

Custom command dispatch is **disabled by default**. To enable, set in `~/.claude/machine.json`:

```json
{
  "command_prefix_enabled": true,
  "command_prefix": "--"
}
```

Choose any prefix string — `--`, `!`, `>`, `cmd:`, `run:` — whatever feels natural. The only restriction: do not use `/` as a prefix, as Claude Code's CLI intercepts `/word` as built-in commands before the message reaches Claude.

**When enabled:** at the start of each session, read `command_prefix_enabled` and `command_prefix` from `~/.claude/machine.json`. If enabled, watch for messages that start with the configured prefix.

**Dispatch logic:**
1. User types `{prefix}commandname` (e.g. `--daily`, `--health-check`)
2. If `command_prefix` is empty, the command name is used directly (e.g. `daily`) — choose distinctive names to avoid ambiguity with normal conversation
3. Extract `commandname` by stripping the prefix from the start of the message
4. Check: `ls ~/.claude/commands/commandname.md 2>/dev/null`
5. If found: read the file and execute its instructions
6. If not found: tell the user the command was not found; suggest `{prefix}commands` (or just `commands` if no prefix) to list all available commands

**Version warning (non-blocking):** Before running any command's instructions, check whether claude-dotfiles is behind remote. Use the `dotfiles_dir` from machine.json:

```bash
git -C <dotfiles_dir> rev-parse HEAD 2>/dev/null
git -C <dotfiles_dir> rev-parse @{u} 2>/dev/null
```

If they differ, prepend a single warning to the command output — then continue with the command regardless:

> ⚠️ claude-dotfiles has updates available. Run `bash <dotfiles_dir>/scripts/update.sh` when convenient.

---

## Keywords

Reserved words that trigger specific actions:

- **setup** — Create or update `~/.claude/machine.json` and `~/.claude/settings.json` interactively. Read the current values first. Show each field with its current value in brackets — the user presses Enter to keep it or types a new value to replace it. After updating machine.json, show the current settings.json allowlist and offer to add new entries. Never require deleting files to reconfigure — always update in place. Write changes immediately and confirm what changed.

---

## Identity

<!--
  Replace this section with your own identity information.
  This helps Claude understand who you are and tailor responses accordingly.

  Example:
  - Name: Your Name
  - Company: Your Company (if applicable)
  - Location: Your Location
  - Role: What you do
-->

- **Name:** [Your Name]
- **Role:** [Your Role]
- **Location:** [Your Location]

---

## Knowledge Directories

<!--
  Knowledge directories are folders containing markdown files that Claude
  reads for context. They can be Obsidian vaults, plain folders, VS Code
  workspaces, Notion exports — any collection of markdown files.

  Define them in machine.json under "knowledge_dirs".
  Reference them in this file using the variable names you define.

  Example uses:
  - Project planning documents
  - Personal notes and todos
  - Research and reference material
  - Business documentation
-->

Knowledge directories for this machine are defined in `~/.claude/machine.json`
and loaded at session start. Add instructions for reading specific directories
below this line, customised to your workflow.

---

## Date & Time

Always determine the current date and time by running `date` via the shell.
Never rely on context or memory for the current date.

---

## Behaviour Defaults

- Prefer editing existing files over creating new ones
- Never run software updates without explicit approval
- Default to writing no code comments unless the WHY is non-obvious
- Check that generated URLs are correct before presenting them
- Always confirm before destructive operations
