# Check for Updates

Check for updates to claude-dotfiles and your private config repo (if you have one), then update what needs updating.

**Step 1 — Find the public tool repo**

Derive the repo location from the commands symlink:

```bash
COMMANDS_LINK=$(readlink ~/.claude/commands/update.md 2>/dev/null)
TOOL_ROOT=$(dirname "$COMMANDS_LINK" 2>/dev/null | xargs dirname 2>/dev/null)
echo "Public tool: $TOOL_ROOT"
```

If `TOOL_ROOT` is empty or the directory doesn't exist, report that the repo could not be found and suggest running `--health-check`.

**Step 2 — Find the private config repo (if any)**

Check whether `~/.claude/CLAUDE.md` is symlinked to a different location than the public tool:

```bash
CLAUDE_MD_LINK=$(readlink ~/.claude/CLAUDE.md 2>/dev/null)
CLAUDE_MD_DIR=$(dirname "$CLAUDE_MD_LINK" 2>/dev/null)
echo "CLAUDE.md points to: $CLAUDE_MD_DIR"
```

If `CLAUDE_MD_DIR` is inside the public tool directory → no private config repo, skip steps 4–5.
If `CLAUDE_MD_DIR` is elsewhere → this is the private config repo root.

**Step 3 — Check and update the public tool**

```bash
cd "$TOOL_ROOT"
git fetch origin --tags --quiet 2>/dev/null
CURRENT=$(git describe --tags --abbrev=0 2>/dev/null || echo "unknown")
BEHIND=$(git log HEAD..origin/main --oneline 2>/dev/null | wc -l | tr -d ' ')
```

- If `BEHIND` is 0: report "Public tool is up to date (version: $CURRENT)"
- If `BEHIND` > 0: show the commits ahead and ask "Update public tool now? (yes/no)"
  - If yes: run `bash "$TOOL_ROOT/scripts/update.sh"` and report what changed
  - Re-link any updated command files into `~/.claude/commands/`

**Step 4 — Check and update the private config repo (if found)**

```bash
cd "$CLAUDE_MD_DIR"
git fetch origin --quiet 2>/dev/null
BEHIND_PRIVATE=$(git log HEAD..origin/main --oneline 2>/dev/null | wc -l | tr -d ' ')
```

- If `BEHIND_PRIVATE` is 0: report "Private config is up to date"
- If `BEHIND_PRIVATE` > 0: show the commits and ask "Update private config now? (yes/no)"
  - If yes: `git pull` and re-link personal commands into `~/.claude/commands/`

**Step 5 — Check for new settings**

After updating the public tool, compare `machine.json.template` against `~/.claude/machine.json`. Flag any fields in the template that are missing from the installed config — these may be new settings from the update. Ask whether to configure them now.

**Step 6 — Summary**

Report:
- Public tool: current version → new version (or "already up to date")
- Private config: updated / up to date / not found
- Any new machine.json settings that need configuring

---

**Optional argument:** If the user types `--update private`, skip steps 1 and 3 and only update the private config repo.

---
*Customise this command by editing `~/.claude/commands/update.md`*
