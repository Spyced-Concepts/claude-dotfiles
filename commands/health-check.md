# Health Check

Verify that the claude-dotfiles setup is intact on this machine. Run each check and report pass/fail clearly.

```bash
date +%Y-%m-%d
```

**Check 1 — CLAUDE.md symlink**
```bash
ls -la ~/.claude/CLAUDE.md
```
Pass: is a symlink pointing to a file that exists. Fail: missing, broken, or a regular file.

**Check 2 — machine.json exists and is valid JSON**
```bash
cat ~/.claude/machine.json | python3 -m json.tool > /dev/null 2>&1 && echo "valid" || echo "invalid"
```
Pass: file exists and is valid JSON. Fail: missing or malformed.

**Check 3 — machine.json paths exist**
Read `~/.claude/machine.json` and check that every path value (`home`, `project_root`, `knowledge_root`, all `knowledge_dirs` values) points to a directory that actually exists on this machine.

**Check 4 — commands symlink or directory**
```bash
ls -la ~/.claude/commands
```
Pass: exists and points to a directory containing `.md` files. Fail: missing or empty.

**Check 5 — built-in commands present**
Check that the commands directory contains at least one `.md` file:
```bash
ls ~/.claude/commands/*.md 2>/dev/null | wc -l
```

**Check 6 — repo location (via symlink)**
Derive the repo location from the existing symlinks — do not assume a fixed path:
```bash
readlink ~/.claude/CLAUDE.md 2>/dev/null
readlink ~/.claude/commands 2>/dev/null
```
Report what the symlinks point to. If either is missing or broken, flag it.

**Summary**
Report a clear pass/fail for each check. If any check fails, explain what is wrong and suggest the fix. End with an overall status: ✓ All checks passed, or ⚠️ N checks need attention.

---
*Customise this command for your setup by editing `~/.claude/commands/health-check.md`*
