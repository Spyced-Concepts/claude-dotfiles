# Health Check

Verify that the claude-dotfiles setup is intact on this machine and show
the current configuration. Run each check and report pass/fail clearly.

```bash
date +%Y-%m-%d
```

---

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
Read `~/.claude/machine.json` and check that every path value (`home`,
`project_root`, `knowledge_root`, all `knowledge_dirs` values, all `project_dirs`
values, `dotfiles_dir`, `personal_config_dir`) points to a directory that
actually exists on this machine. Report each path and whether it is present or
missing. Missing paths are a warning, not a failure — some may legitimately be
absent on this machine.

**Check 4 — commands directory**
```bash
ls ~/.claude/commands/*.md 2>/dev/null | wc -l
```
Pass: directory exists and contains at least one `.md` file. Fail: missing or empty.

**Check 5 — command symlinks intact**
For each `.md` file in `~/.claude/commands/`, check that if it is a symlink, the
target file exists. Report any broken symlinks.

**Check 6 — settings.json: permissions**
```bash
cat ~/.claude/settings.json
```
Display a clear summary of the permissions configured for this machine:

*Allowed (Claude can run without prompting):*
- List every entry in `permissions.allow` — one per line
- If the list is empty, say "None configured"

*Blocked (Claude will never run):*
- List every entry in `permissions.deny` — one per line
- If the list is empty, say "None configured"

Explain to the user what each section means: allow entries let Claude run
specific commands or access specific URLs without a permission prompt;
deny entries are hard blocks Claude will not bypass.

**Check 7 — status check**
Read `dotfiles_dir` from machine.json and run:
```bash
bash <dotfiles_dir>/scripts/status.sh
```
This checks claude-dotfiles version, personal config sync, and CLAUDE.md
symlink integrity. Show the full output.

---

**Summary**
Report a clear pass/fail for each check. If any check fails, explain what is
wrong and suggest the fix. End with an overall status:
✓ All checks passed, or ⚠️ N checks need attention.

---
*Customise this command by editing `~/.claude/commands/health-check.md` in your personal config repo.*
