# Save a Rule

Help the user place a rule, instruction, or convention in the right location based on its scope. Supports saving to one or multiple tiers in a single command.

---

## Taxonomy

| Tier | Keyword | Scope | Where it lives |
|---|---|---|---|
| Folder rule | `folder` | One vault or knowledge folder only | `CLAUDE.md` inside that folder |
| Local Global rule *(coming soon)* | `local` | This machine only, never synced | Not yet implemented — planned for a future release |
| Synced Global rule | `global` | All sessions on all machines | Your **synced-rules** repo `CLAUDE.md` (private config repo — `claude-config` by default) |
| Project rule | `project` | Current code project only | `AGENTS.md` + `.claude/CLAUDE.md` in this repo |

---

## Usage

The user may invoke this command in several ways:

**Interactive (no arguments):** `--saverule`
Walk the user through identifying the correct tier, then write the rule.

**With tier:** `--saverule global "rule text"`
Skip the tier question — write directly to the specified tier.

**Multiple tiers:** `--saverule global,project "rule text"`
Write to more than one tier in a single command. Confirm each location before writing.

**Help:** `--saverule help` or `--saverule list`
Show the taxonomy table and exit without writing anything.

---

## Interactive flow (no arguments)

1. Ask: **"What rule or instruction would you like to save?"**
   Wait for the user to describe the rule in plain language.

2. Ask: **"Who or what should this apply to?"** and offer the four options:
   ```
   1. folder   — one specific vault or folder
   2. local    — this machine only (not synced) *(coming soon — not yet available)*
   3. global   — all machines, always (synced via personal config)
   4. project  — this code project only
   ```
   If unsure, suggest the most likely tier based on the rule content and explain why.

3. If `folder`: ask which folder. Read the relevant `CLAUDE.md` and append the rule in an appropriate section.

4. If `local`: tell the user this tier is not yet implemented and suggest they use `global` (synced-rules) as a temporary home, or defer until Local Global support is available in a future release. Do not write anything.

5. If `global`: read `personal_config_dir` from `~/.claude/machine.json`. Open the personal config `CLAUDE.md` and append the rule under an appropriate existing section, or create a new one if no section fits.

6. If `project`: write to both `AGENTS.md` and `.claude/CLAUDE.md` in the current working directory. If neither exists, create them following the project AI files standard (see `AGENTS.md` pattern below).

7. Confirm exactly what was written and where before saving.

---

## Multiple tiers

When the user specifies multiple tiers (e.g. `global,project`), process each in sequence. For each:
- Show the target file path
- Show exactly what will be written
- Ask "Write this? (y/n)" before saving

---

## AGENTS.md pattern (for new project files)

When creating `AGENTS.md` from scratch:

```markdown
# AI Contributor Rules — [Project Name]

Rules for AI tools (Claude Code, Cursor, Copilot, and others) working in this repository.

## [Section name — e.g. Branch workflow]

[Rule content]
```

When creating `.claude/CLAUDE.md` from scratch:

```markdown
# Claude Code — [Project Name]

Read `AGENTS.md` in the repo root for all contributor and AI workflow rules before starting work.
```

---

## What must never go in project files

Before writing any rule to `AGENTS.md` or `.claude/CLAUDE.md`, check:
- No personal information (names, contact details, identity)
- No security or risk information (credentials, vulnerability details, security posture)
- No business-sensitive content

If the rule contains any of the above, redirect it to `global` (synced-rules) tier instead and explain why. Do not suggest `local` as a destination — it is not yet implemented.

---
*Customise this command for your setup by editing `~/.claude/commands/saverule.md`*
