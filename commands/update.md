# Check for Updates and Update claude-dotfiles

Check the current version of claude-dotfiles and whether an update is available. Then offer to update if one exists.

**Step 1 — Find the repo via symlink**

Derive the repo location from the existing symlinks — do not assume a fixed path:

```bash
CLAUDE_MD_LINK=$(readlink ~/.claude/CLAUDE.md 2>/dev/null)
REPO_ROOT=$(dirname "$CLAUDE_MD_LINK" 2>/dev/null)
echo "Repo: $REPO_ROOT"
```

If `REPO_ROOT` is empty or the directory doesn't exist, report that the repo could not be found and suggest running `--health-check` to diagnose.

**Step 2 — Check current version**
```bash
cd "$REPO_ROOT" && git describe --tags --abbrev=0 2>/dev/null || echo "no version tag found"
```

**Step 3 — Check for updates**
```bash
git fetch origin --tags --quiet 2>/dev/null
git log HEAD..origin/main --oneline 2>/dev/null | head -10
```
If there are commits ahead, show them and ask: "Updates are available. Run update now? (yes/no)"

**Step 4 — If updating**
```bash
bash "$REPO_ROOT/scripts/update.sh"
```
Report what changed.

**Step 5 — Check for new settings**
After updating, compare `machine.json.template` against `~/.claude/machine.json`. Flag any fields in the template that are missing from the installed config — these may be new settings introduced in the update. Ask whether to run setup interactively to configure them.

Report the current version, latest version, and what changed.

---
*Customise this command for your setup by editing `~/.claude/commands/update.md`*
