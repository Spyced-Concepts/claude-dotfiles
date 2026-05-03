# Check for Updates and Update claude-dotfiles

Check the current version of claude-dotfiles and whether an update is available. Then offer to update if one exists.

Run these steps:

**Step 1 — Check current version**
```bash
cd ~/Projects/claude-dotfiles 2>/dev/null || cd ~/claude-dotfiles 2>/dev/null || echo "claude-dotfiles not found at ~/Projects/claude-dotfiles or ~/claude-dotfiles"
```
If found, run:
```bash
git describe --tags --abbrev=0 2>/dev/null || echo "no version tag found"
```

**Step 2 — Check for updates**
```bash
git fetch origin --tags --quiet 2>/dev/null
git log HEAD..origin/main --oneline 2>/dev/null | head -10
```
If there are commits ahead, show them and ask: "Updates are available. Run update now? (yes/no)"

**Step 3 — If updating**
Run `bash scripts/update.sh` and report what changed.

**Step 4 — Check for new settings**
After updating, compare `machine.json.template` against `~/.claude/machine.json`. Flag any fields in the template that are missing from the installed config — these may be new settings introduced in the update. Ask whether to run setup interactively to configure them.

Report the current version, latest version, and what changed.

---
*This command requires claude-dotfiles to be cloned at `~/Projects/claude-dotfiles` or `~/claude-dotfiles`.*
