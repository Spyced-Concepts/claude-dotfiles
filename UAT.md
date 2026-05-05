# UAT — User Acceptance Testing

Manual acceptance and regression test suite for claude-dotfiles.

---

## How to use this document

- Run these tests against `functional-test` before any release merge to `main`
- Run the **Regression** section after any bug fix or change to an existing script
- Record results in the **Platform results** table for each test case
- If a test fails, open a GitHub issue and link it in the Notes column
- Status values: ✅ Pass · ❌ Fail · ⚠️ Partial · ⬜ Untested · N/A Not applicable

---

## Test environment requirements

| Requirement | Notes |
|---|---|
| Claude Code installed | `claude --version` must return output |
| git installed | Required by all scripts |
| Python 3 | Required for JSON handling in setup scripts |
| GitHub account | Required for personal config repo tests |
| `gh` CLI (optional) | Enables automated repo creation path |
| macOS / Linux / Windows (Git Bash) | Test on each platform before release |

---

## Test cases

---

### UAT-001 — Setup: new machine, no existing config

**Feature:** `setup.sh`  
**Priority:** P1 Critical  
**Related issues:** #22, #23

**Given**
- Claude Code is installed
- No `~/.claude/machine.json` exists
- No `~/.claude/CLAUDE.md` exists
- A personal config repo already exists on GitHub

**When** the user runs:
```bash
bash scripts/setup.sh
```

**Steps**
1. Answer `y` to "Set up built-in commands?"
2. Answer `n` to "Enable command prefix now?"
3. Enter machine name, OS, home directory, projects folder, knowledge root (or press Enter to accept defaults)
4. Press Enter to skip allowlist entry
5. Answer `y` to "Have you already set up a personal config repo?"
6. Paste the clone URL

**Then**
- [ ] `~/.claude/machine.json` created with correct values
- [ ] `dotfiles_dir` recorded in `machine.json`
- [ ] `personal_config_dir` recorded in `machine.json`
- [ ] `~/.claude/CLAUDE.md` is a symlink pointing to the personal CLAUDE.md
- [ ] `~/.claude/commands/` contains all public built-in commands
- [ ] Personal commands from the config repo are linked into `~/.claude/commands/`
- [ ] Setup prints "Setup complete."
- [ ] **Post-setup:** run `bash scripts/status.sh` — exits 0 (or 1 only for identity placeholder warning)

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-002 — Setup: re-run on existing config (update mode)

**Feature:** `setup.sh`  
**Priority:** P1 Critical

**Given**
- `~/.claude/machine.json` already exists from a previous setup run
- `~/.claude/CLAUDE.md` is already a symlink
- Personal config repo is already connected

**When** the user runs:
```bash
bash scripts/setup.sh
```

**Steps**
1. Press Enter at each machine.json prompt to keep existing values
2. Press Enter to skip allowlist entry
3. Setup detects personal config already linked — should pull latest

**Then**
- [ ] `machine.json` values preserved (not reset)
- [ ] `dotfiles_dir` and `personal_config_dir` retained or updated
- [ ] Personal config repo pulled (latest changes fetched)
- [ ] CLAUDE.md symlink updated to personal CLAUDE.md
- [ ] Commands refreshed (new commands from either repo appear)
- [ ] Setup prints "Setup complete."
- [ ] **Post-setup:** run `bash scripts/status.sh` — exits 0

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ✅ | maintainer | 2026-05-05 | |
| macOS | ⬜ | | | |
| Linux | ✅ | maintainer | 2026-05-05 | Covered by UAT-022 variant — legacy `projects` field migrated, personal config cloned to standard XDG path. See UAT-022 for migration detail. |

---

### UAT-003 — Setup: skip personal config repo

**Feature:** `setup.sh`  
**Priority:** P2 High

**Given**
- No personal config repo exists or the user is not ready to connect one

**When** the user answers `s` (skip) to "Have you already set up a personal config repo?"

**Then**
- [ ] Setup continues without cloning any repo
- [ ] `~/.claude/CLAUDE.md` symlinks to the public framework CLAUDE.md
- [ ] Setup prints "Setup partially complete."
- [ ] Next steps suggest connecting a personal config repo
- [ ] `bash scripts/status.sh` reports personal config not connected

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-004 — Setup: create new repo via `gh` CLI

**Feature:** `setup.sh`  
**Priority:** P2 High  
**Requires:** `gh` CLI installed and authenticated

**Given**
- `gh` is installed and `gh auth status` confirms authentication
- No personal config repo exists yet

**When** the user answers `n` to "Have you already set up a personal config repo?" and `y` to create one via `gh`

**Then**
- [ ] A new private repo is created on GitHub
- [ ] Repo is cloned locally to `$XDG_DATA_HOME/<name>` or `~/.local/share/<name>` (Linux/macOS) or appropriate Windows equivalent
- [ ] A personal CLAUDE.md scaffold is created (with framework reference at top)
- [ ] An empty `commands/` directory is created
- [ ] Initial commit is pushed to GitHub
- [ ] `personal_config_dir` saved to `machine.json`
- [ ] `~/.claude/CLAUDE.md` symlinks to the personal CLAUDE.md

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-005 — Setup: no `gh` CLI, manual instructions

**Feature:** `setup.sh`  
**Priority:** P2 High

**Given**
- `gh` is NOT installed
- User answers `n` to "Have you already set up a personal config repo?"

**Then**
- [ ] Three options are displayed clearly (install `gh`, create manually, skip)
- [ ] Manual GitHub.com URL and steps are shown
- [ ] User can optionally paste a clone URL immediately if they have one ready
- [ ] If no URL provided, setup continues and reports partially complete

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-006 — Setup: CLAUDE.md backup and symlink

**Feature:** `setup.sh`  
**Priority:** P1 Critical

**Given**
- `~/.claude/CLAUDE.md` exists as a plain file with content

**When** `setup.sh` runs

**Then**
- [ ] The existing plain file is backed up to `~/.claude/CLAUDE.md.backup` automatically (no prompt)
- [ ] `~/.claude/CLAUDE.md` becomes a symlink (to personal CLAUDE.md if connected, otherwise to framework)
- [ ] No content from the original file is lost (backup is readable and complete)

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-007 — Setup: settings.json allowlist display

**Feature:** `setup.sh`  
**Priority:** P2 High  
**Related issues:** #26 (Windows path fix)

**Given**
- `~/.claude/settings.json` exists

**When** `setup.sh` reaches the settings.json section

**Then**
- [ ] Current allowlist entries are displayed (not "could not read")
- [ ] Format and example entries are shown clearly
- [ ] User can add a new entry and it appears in `settings.json`
- [ ] Pressing Enter skips without error

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ✅ | maintainer | 2026-05-05 | |
| macOS | ⬜ | | | |
| Linux | ✅ | maintainer | 2026-05-05 | Entries displayed correctly. Machine had no allowlist entries — `(none)` shown as expected. Format explanation and examples shown. Enter to skip worked. |

---

### UAT-008 — Setup: completion message reflects actual prefix state

**Feature:** `setup.sh`  
**Priority:** P3 Low  
**Related issues:** #27

**Given**
- `machine.json` already has `command_prefix_enabled: true` and `command_prefix: "--"`
- User answers `y` to built-in commands but `n` to enabling prefix (already set)

**Then**
- [ ] Completion message shows "Try a command: type --commands" (not "Enable commands: set command_prefix_enabled...")

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ✅ | maintainer | 2026-05-05 | |
| macOS | ⬜ | | | |
| Linux | ✅ | maintainer | 2026-05-05 | Issue #27 fix confirmed. User entered `--` at (y/n) prompt (treated as no), but script detected existing prefix from machine.json and showed correct message. Note: invalid y/n input accepted silently — see issue #34. |

---

### UAT-009 — Update: pulls both repos and refreshes commands

**Feature:** `update.sh`  
**Priority:** P1 Critical

**Given**
- `setup.sh` has been run and both `dotfiles_dir` and `personal_config_dir` are in `machine.json`
- At least one new command has been added to the personal config repo and pushed

**When** the user runs:
```bash
bash scripts/update.sh
```

**Then**
- [ ] `git pull` runs on the claude-dotfiles repo
- [ ] `git pull` runs on the personal config repo
- [ ] `~/.claude/CLAUDE.md` symlink is refreshed
- [ ] New command from personal config repo appears in `~/.claude/commands/`
- [ ] Stale symlinks (removed commands) are cleaned up
- [ ] No interactive prompts

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⚠️ | maintainer | 2026-05-05 | Both git pulls ran, CLAUDE.md refreshed, 10 public + 3 personal commands re-linked, no interactive prompts, exit 0. Both repos already up to date — "new command appears" and "stale symlink cleanup" paths not exercised. Partial pass. |

---

### UAT-010 — Status: all checks pass

**Feature:** `status.sh`  
**Priority:** P1 Critical

**Given**
- Setup is complete: `machine.json` valid, CLAUDE.md symlinked to personal config, personal config in sync, claude-dotfiles up to date
- Identity section in personal CLAUDE.md has been filled in (no `[Your Name]` placeholder)

**When** the user runs:
```bash
bash scripts/status.sh
```

**Then**
- [ ] All four checks pass with ✓
- [ ] Exit code is 0
- [ ] Output is clear and readable

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ✅ | maintainer | 2026-05-05 | Passes. CLAUDE.md shown as `(regular file)` not symlink — known Windows display quirk, functionally correct. See README OS compatibility. |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-011 — Status: detects issues correctly

**Feature:** `status.sh`  
**Priority:** P1 Critical

**Given** one or more of:
- `machine.json` is missing
- `~/.claude/CLAUDE.md` symlink is broken
- Identity placeholder `[Your Name]` present in CLAUDE.md
- Personal config repo has unpulled changes
- claude-dotfiles is behind remote

**When** the user runs `bash scripts/status.sh`

**Then**
- [ ] Each issue is flagged with ⚠ or ✗
- [ ] Each flag includes a clear remediation command
- [ ] Exit code is 1

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ✅ | maintainer | 2026-05-05 | |
| macOS | ⬜ | | | |
| Linux | ✅ | maintainer | 2026-05-05 | All 4 reversible conditions tested: missing machine.json ✓, broken CLAUDE.md symlink ✓, identity placeholder ✓, personal_config_dir removed ✓. Each flagged with ✗/⚠ and remediation command. Exit 1 in all cases. "Repo behind remote" not simulated — code review confirms path is correct. |

---

### UAT-012 — Status: quiet mode

**Feature:** `status.sh`  
**Priority:** P2 High

**When** the user runs `bash scripts/status.sh --quiet`

**Then**
- [ ] No output is produced (stdout and stderr are silent)
- [ ] Exit code is 0 when all checks pass
- [ ] Exit code is 1 when any check fails

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-013 — Uninstall: removes symlinks, restores plain CLAUDE.md

**Feature:** `uninstall.sh`  
**Priority:** P1 Critical

**Given**
- Setup is complete: CLAUDE.md is a symlink, commands are linked

**When** the user runs `bash scripts/uninstall.sh` and:
1. Answers `y` to "Continue?"
2. Answers `y` to "Restore a plain local CLAUDE.md?"
3. Answers `n` to removing `machine.json` and `settings.json`
4. Answers `n` to deleting repos

**Then**
- [ ] `~/.claude/CLAUDE.md` is a plain file (not a symlink) with content from the personal config
- [ ] All command symlinks are removed from `~/.claude/commands/`
- [ ] `machine.json` and `settings.json` are still present
- [ ] Repos are still present on disk
- [ ] Uninstall prints "Uninstall complete."
- [ ] Claude Code still works (plain CLAUDE.md is loaded)

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ✅ | maintainer | 2026-05-05 | CLAUDE.md symlink removed, plain file restored from personal config (20KB, correct content). 13 command symlinks removed. machine.json and settings.json retained. Both repos intact. "Uninstall complete." printed. Exit 0. Reinstall via setup.sh confirmed working immediately after. |

---

### UAT-014 — Uninstall: detach mode (clean slate, repos retained)

**Feature:** `uninstall.sh`  
**Priority:** P2 High

**When** the user runs uninstall and answers:
- `y` to restore plain CLAUDE.md
- `n` to removing machine.json and settings.json
- `n` to deleting both repos

**Then**
- [ ] `~/.claude/CLAUDE.md` is a standalone plain file with no repo dependency
- [ ] All symlinks removed
- [ ] Repos on disk are untouched
- [ ] Reinstall works immediately: `curl -fsSL ... | bash`

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ✅ | maintainer | 2026-05-05 | Same run as UAT-013. CLAUDE.md is plain file, all symlinks removed, repos untouched. Reinstall via `bash scripts/setup.sh` worked immediately — personal_config_dir auto-detected, pulled, commands re-linked, status exit 0. |

---

### UAT-015 — Uninstall: full removal

**Feature:** `uninstall.sh`  
**Priority:** P2 High

**When** the user runs uninstall and answers `YES` to deleting both repos

**Then**
- [ ] Personal config repo directory is deleted (requires typing `YES`)
- [ ] claude-dotfiles repo directory is deleted (requires typing `YES`)
- [ ] `~/.claude/` is in a clean state (or fully cleaned if machine.json/settings.json also removed)

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-016 — Docs check: all checks pass

**Feature:** `check-docs.sh`  
**Priority:** P1 Critical

**When** the user runs:
```bash
bash scripts/check-docs.sh
```

**Then**
- [ ] All checks pass
- [ ] Exit code is 0
- [ ] Output is clear

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-017 — Help flags on all scripts

**Feature:** All scripts  
**Priority:** P1 Critical

**When** the user runs each of the following:
```bash
bash scripts/setup.sh --help
bash scripts/update.sh --help
bash scripts/status.sh --help
bash scripts/uninstall.sh --help
bash scripts/check-docs.sh --help
```

**Then** for each script:
- [ ] Usage information is printed to stdout
- [ ] Exit code is 0
- [ ] Both `-h` and `--help` work

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-018 — Man pages render correctly

**Feature:** `man/man1/`  
**Priority:** P2 High  
**Platforms:** macOS and Linux only (man not available in Windows Git Bash)

**When** the user runs:
```bash
man ./man/man1/claude-dotfiles.1
man ./man/man1/claude-dotfiles-setup.1
man ./man/man1/claude-dotfiles-status.1
man ./man/man1/claude-dotfiles-update.1
man ./man/man1/claude-dotfiles-uninstall.1
man ./man/man1/claude-dotfiles-check-docs.1
```

**Then** for each man page:
- [ ] Renders without errors
- [ ] NAME, SYNOPSIS, DESCRIPTION, OPTIONS, EXIT STATUS, EXAMPLES, SEE ALSO all present
- [ ] Content is accurate and matches the script's actual behaviour

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | N/A | | | man not available |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-019 — One-line install

**Feature:** `install.sh`  
**Priority:** P1 Critical  
**Note:** Test against a release tag, not the development branch

**Given**
- A clean machine with no claude-dotfiles installed
- Claude Code installed

**When** the user runs:
```bash
curl -fsSL https://raw.githubusercontent.com/Spyced-Concepts/claude-dotfiles/main/install.sh | bash
```

**Then**
- [ ] claude-dotfiles is downloaded to the correct system location
- [ ] `setup.sh` runs automatically
- [ ] `claude-update` alias is added to the shell config
- [ ] No errors

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-020 — CI: docs-check workflow triggers on push

**Feature:** `.github/workflows/docs-check.yml`  
**Priority:** P2 High

**When** any commit is pushed to any branch

**Then**
- [ ] `Documentation Check` workflow appears in GitHub Actions
- [ ] Workflow completes successfully (green)
- [ ] Failure on a bad push (remove a required README section, re-push, confirm red)

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| GitHub Actions | ⬜ | | | |

---

### UAT-021 — Setup: re-run where personal config already in machine.json

**Feature:** `setup.sh`  
**Priority:** P1 Critical

**Given**
- `~/.claude/machine.json` exists and contains `personal_config_dir` pointing to a valid local git repo
- The repo has a remote with changes not yet pulled

**When** the user runs:
```bash
bash scripts/setup.sh
```

**Steps**
1. Press Enter at each machine.json prompt to keep existing values
2. Press Enter to skip allowlist entry

**Then**
- [ ] Setup detects `personal_config_dir` automatically — no prompt about personal config repo
- [ ] `git pull` runs on the personal config repo
- [ ] CLAUDE.md symlink refreshed
- [ ] Commands refreshed
- [ ] Setup prints "Setup complete."

**Windows note:** `readlink` and `ls -la` will not show symlink arrows — verify by comparing file content of `~/.claude/CLAUDE.md` against the personal CLAUDE.md.

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ⬜ | | | |

---

### UAT-022 — Setup: `projects` → `project_root` field migration

**Feature:** `setup.sh`  
**Priority:** P1 Critical

**Given**
- `~/.claude/machine.json` exists with a legacy `"projects"` field (pre-v1.4 install) and **no** `"project_root"` field

**When** the user runs `setup.sh` and enters the projects folder path at the "Projects folder" prompt (default shows `~/Projects` because `project_root` is missing — the correct path must be typed)

**Then**
- [ ] `"projects"` field is removed from `machine.json`
- [ ] `"project_root"` field is written with the entered path
- [ ] All other existing fields (`knowledge_dirs`, `command_prefix_*`, etc.) are preserved
- [ ] `dotfiles_dir` is written (new field)
- [ ] `bash scripts/status.sh` shows no warnings about machine.json

**Notes:**
- The prompt default will show `~/Projects` even if the old `projects` value was different — the tester must type the correct path rather than pressing Enter
- This is a one-time migration; re-running setup afterwards will show the correct default

**macOS / Linux prompt values for this test:**

| Prompt | Value |
|---|---|
| Set up built-in commands? | `y` |
| Enable command prefix now? | `n` (if already set in machine.json) |
| Machine name | Enter (keep) |
| OS | Enter (keep) |
| Home directory | Enter (keep) |
| Projects folder | Type the actual projects path (e.g. `/home/yourname/Projects`) |
| Knowledge root | Enter (keep or skip) |
| Add allowlist entry? | Enter (skip) |
| Personal config repo | `y` + clone URL, or `s` to skip |

**Windows (Git Bash) prompt values:** same as above; use Windows-style paths (e.g. `/c/Users/yourname/Projects`).

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ✅ | maintainer | 2026-05-05 | `projects` field removed, `project_root` written correctly. `dotfiles_dir` and `personal_config_dir` also populated in same run. |

---

### UAT-023 — Setup: personal config exists at non-standard path, not in machine.json

**Feature:** `setup.sh`  
**Priority:** P2 High

**Given**
- A personal config repo is already cloned locally at a path other than `~/.local/share/claude-config` (e.g. `~/Projects/claude-config`)
- `machine.json` does **not** contain `personal_config_dir`

**When** the user runs `setup.sh` and answers `y` to "Have you already set up a personal config repo?" + provides the clone URL

**Then**
- [ ] Setup clones a **new copy** to `~/.local/share/claude-config` (or `$XDG_DATA_HOME/claude-config`)
- [ ] `personal_config_dir` is set to the **new** cloned path, not the original non-standard path
- [ ] CLAUDE.md symlinks to the new copy
- [ ] Commands linked from the new copy
- [ ] Original repo at the non-standard path is **not** modified or deleted
- [ ] Setup prints "Setup complete."

**Expected behaviour note:** setup.sh always clones to the standard XDG location. Users with existing repos at non-standard paths end up with two copies. This is by design — the standard path is the managed location. The original can be removed manually once the new copy is verified.

**Windows note:** Standard path on Windows (Git Bash) is `$APPDATA/claude-config` or `$HOME/.local/share/claude-config` depending on environment. Confirm which `_config_parent` resolves to on the test machine.

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ✅ | maintainer | 2026-05-05 | New clone created at `~/.local/share/claude-config`. Original at `~/Projects/claude-config` untouched. `personal_config_dir` set to new path. |

---

### UAT-024 — Commands: both public built-ins and private commands available

**Feature:** Command dispatch, `setup.sh`  
**Priority:** P1 Critical

**Given**
- Setup is complete with personal config connected
- Personal config repo contains at least one custom command in its `commands/` directory
- `command_prefix_enabled: true` and a prefix (e.g. `--`) set in `machine.json`

**When** the user opens Claude Code and types `--commands`

**Then**
- [ ] All public built-in commands are listed (daily, health-check, journal, status, todo, update, week-review, commands, docscheck, uninstall)
- [ ] All personal commands are also listed (e.g. seclog, monthly-check, quarterly-review)
- [ ] Each entry shows the correct invoke syntax with the configured prefix
- [ ] No duplicate entries for commands with the same name (personal overrides built-in silently)

**Verification:** Run `ls -la ~/.claude/commands/` and confirm:
- Each public command symlinks to the `dotfiles_dir/commands/` path
- Each personal command symlinks to the `personal_config_dir/commands/` path
- No broken symlinks

**Windows note:** `ls -la` will not show symlink arrows. Verify by checking file content: `cat ~/.claude/commands/seclog.md` should match the personal config version.

| Platform | Status | Tester | Date | Notes |
|---|---|---|---|---|
| Windows (Git Bash) | ⬜ | | | |
| macOS | ⬜ | | | |
| Linux | ✅ | maintainer | 2026-05-05 | 10 public + 3 private commands linked. All resolve correctly. No duplicates. |

---

## Regression checklist

Run this after any change to `scripts/` or `CLAUDE.md`. Tick each item before raising a PR.

```
[ ] bash -n scripts/setup.sh       — syntax OK
[ ] bash -n scripts/update.sh      — syntax OK
[ ] bash -n scripts/status.sh      — syntax OK
[ ] bash -n scripts/uninstall.sh   — syntax OK
[ ] bash -n scripts/check-docs.sh  — syntax OK
[ ] bash scripts/check-docs.sh     — all checks pass
[ ] bash scripts/status.sh         — runs without crash
[ ] bash scripts/setup.sh --help   — prints usage
[ ] bash scripts/status.sh --quiet — exit code 0 or 1 (no output)
```

---

## Platform compatibility matrix

Summary of test pass rates by platform and release.

| Test ID | Description | Windows | macOS | Linux |
|---|---|---|---|---|
| UAT-001 | Setup: new machine | ⚠️ partial¹ | ⬜ | ⬜ |
| UAT-002 | Setup: re-run / update mode | ✅ | ⬜ | ✅ |
| UAT-003 | Setup: skip personal config | ⬜ | ⬜ | ⬜ |
| UAT-004 | Setup: create repo via gh | ⬜ | ⬜ | ⬜ |
| UAT-005 | Setup: no gh, manual instructions | ⬜ | ⬜ | ⬜ |
| UAT-006 | Setup: CLAUDE.md backup and symlink | ✅ | ⬜ | ⬜ |
| UAT-007 | Setup: settings.json display | ✅ | ⬜ | ⬜ |
| UAT-008 | Setup: completion message | ✅ | ⬜ | ⬜ |
| UAT-009 | Update: pulls both repos | ⬜ | ⬜ | ⚠️ partial³ |
| UAT-010 | Status: all checks pass | ✅² | ⬜ | ✅ |
| UAT-011 | Status: detects issues | ✅ | ⬜ | ✅ |
| UAT-012 | Status: quiet mode | ✅ | ⬜ | ✅ |
| UAT-013 | Uninstall: symlinks + restore | ⬜ | ⬜ | ✅ |
| UAT-014 | Uninstall: detach mode | ⬜ | ⬜ | ✅ |
| UAT-015 | Uninstall: full removal | ⬜ | ⬜ | ⬜ |
| UAT-016 | Docs check: all pass | ✅ | ⬜ | ✅ |
| UAT-017 | Help flags | ✅ | ⬜ | ✅ |
| UAT-018 | Man pages | N/A | ⬜ | ✅ |
| UAT-019 | One-line install | ⬜ | ⬜ | ⬜ |
| UAT-020 | CI docs-check workflow | ✅ (GitHub Actions) | | |
| UAT-021 | Setup: personal config auto-detected (pull) | ⬜ | ⬜ | ✅ |
| UAT-022 | Setup: `projects` → `project_root` migration | ⬜ | ⬜ | ✅ |
| UAT-023 | Setup: personal config at non-standard path | ⬜ | ⬜ | ✅ |
| UAT-024 | Commands: public + private both available | ⬜ | ⬜ | ✅ |

**Notes:**
¹ UAT-001 tested the existing-repo-URL path only — not a truly clean machine. Full new-machine path requires a machine with no prior claude-dotfiles install.
² Symlinks show as `(regular file)` in status output on Windows — known platform display quirk, functionally correct. Documented in README OS compatibility section.
³ UAT-009 Linux: pull, symlink refresh, and command re-link all pass. "New command appears" and "stale symlink cleanup" paths not exercised — both repos were already up to date. Retest when a real update is available.

---

## Recording a result

When you complete a test, update the relevant row:

```
| Windows (Git Bash) | ✅ | tester | 2026-05-05 | Passed on first run |
| Windows (Git Bash) | ❌ | tester | 2026-05-05 | Fails — see issue #26 |
| Windows (Git Bash) | ⚠️ | tester | 2026-05-05 | Passes but symlinks show as plain files (cosmetic) |
```

Open a GitHub issue for any ❌ or ⚠️ result and link it in the Notes column.
