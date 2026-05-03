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

---

## Keywords

Reserved words that trigger specific actions:

- **setup** — Create or update `~/.claude/machine.json`. Prompt for each field one at a time (machine name, OS, home directory, projects directory, knowledge directories). Write the completed config to `~/.claude/machine.json`. Then check `~/.claude/settings.json` and flag any path mismatches.

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
