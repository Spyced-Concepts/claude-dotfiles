# Save a Rule

Help the user place a rule, instruction, or convention in the right location based on its scope. Supports saving to one or multiple tiers in a single command.

---

## Taxonomy

| Tier | Keyword | Scope | Where it lives |
|---|---|---|---|
| Folder rule | `folder` | One vault or knowledge folder only | `CLAUDE.md` inside that folder |
| Local Global rule *(coming soon)* | `local` | This machine only, not synced | Not yet implemented — planned for a future release |
| Synced Global rule | `global` | All sessions on all machines | Your **synced-rules** repo `CLAUDE.md` (private config repo — `claude-config` by default) |
| Project rule | `project` | Current code project only | `AGENTS.md` + `.claude/CLAUDE.md` in this repo |

---

## Usage

The user may invoke this command in several ways:

**Interactive (no arguments):** `--saverule`
Walk the user through identifying the correct tier, then write the rule.

**With tier:** `--saverule global "rule text"`
Skip the tier question — write directly to the specified tier. If no rule text is provided (e.g. `--saverule global` with no quoted string), ask: **"What rule would you like to save?"** before proceeding.

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

3. If `folder`: ask which folder. If the named folder has no `CLAUDE.md`, tell the user and ask whether to create one. If yes, create it with this minimal scaffold:
   ```markdown
   # [Folder Name] — Notes for Claude

   Instructions specific to this folder.
   ```
   Append the rule under a relevant heading, or add a new one.

4. If `local`: tell the user this tier is not yet implemented and suggest they use `global` (synced-rules) as a temporary home, or defer until Local Global support is available in a future release. Do not write anything.

5. If `global`: read `personal_config_dir` from `~/.claude/machine.json`. If the field is absent or the path does not exist, stop and tell the user to run `setup` first to connect their synced-rules repo. Do not guess a path. If the path exists but contains no `CLAUDE.md`, offer to create one with this minimal scaffold:
   ```markdown
   # Personal Claude Code Configuration

   ## Rules

   ```
   Then append the rule under `## Rules`.

6. If `project`: determine the project name from the git remote URL or the current directory name — do not leave `[Project Name]` as a literal placeholder. Ask the user to confirm the name if it cannot be determined unambiguously.

7. **Before writing anything**, show the user:
   - The target file path
   - The exact content that will be written
   Ask: **"Write this? (y/n)"** Wait for confirmation. Only write after receiving `y`.

---

## Section placement

When appending a rule to an existing CLAUDE.md or AGENTS.md, choose the section as follows:

1. **Scan existing headings** — if a heading clearly matches the rule's topic (e.g. "Branch workflow", "Commit conventions", "Behaviour defaults"), append there.
2. **No clear match** — create a new `##` heading using a short descriptive name derived from the rule content.
3. **Never append to the top of the file** — always place rules under a heading.
4. **Show the chosen section** to the user in the confirmation step (step 7) so they can redirect if it's wrong.

---

## Multiple tiers

When the user specifies multiple tiers (e.g. `global,project`), process each in sequence. For each:
- Show the target file path
- Show exactly what will be written
- Ask "Write this? (y/n)" before saving

If the user declines a tier mid-sequence, skip it and continue to the next. Tiers already written are not rolled back — tell the user which tiers were written and which were skipped.

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

**This check is best-effort** — it relies on judgment, not technical enforcement. Use it as a prompt to think carefully, not as a guarantee. When in doubt, redirect to `global` (synced-rules) and explain why.

If the rule clearly contains any of the above, redirect it to `global` (synced-rules) tier instead and explain why. Do not suggest `local` as a destination — it is not yet implemented.

---
*Customise this command for your setup by editing `~/.claude/commands/saverule.md`*
