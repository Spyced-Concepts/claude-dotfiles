# Contributing to claude-dotfiles

Thank you for your interest in contributing. This document covers how to report issues, request features, and submit code.

---

## Reporting issues

**Before opening an issue:**
- Check [existing issues](https://github.com/Spyced-Concepts/claude-dotfiles/issues) to avoid duplicates
- Make sure you're on the latest version (`scripts/update.sh`)

**To report a bug:** use the [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md) template on GitHub.

**To request a feature:** use the [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md) template on GitHub.

**Security issues:** do NOT open a public GitHub issue. See [SECURITY.md](SECURITY.md).

**General questions or feedback:** use the contact form at [spycedconcepts.co.uk](https://spycedconcepts.co.uk).

---

## Branch workflow

Each feature or fix goes through **two separate PRs**:

```
                    ┌─→ functional-test   PR #1 — testing gate
feature/description ┤
                    └─→ release/vX.X.X   PR #2 — bundling (after PR #1 approved)

release/vX.X.X ─→ main                  PR #3 — monthly release cut
```

**Why two PRs?**
`functional-test` is a validation environment, not a pipeline stage. Features are tested there independently. As each feature is approved in `functional-test`, the same feature branch is immediately PR'd into the upcoming release branch — features accumulate in the release branch as they pass, not in a batch at the end. By the time the release date arrives, the release branch is already complete and ready to publish.

**VERSION.md** is updated on the release branch — either incrementally as features land, or as a final commit before the PR to main. Never on a feature branch, never directly on main.

> **Permitted exception:** Updating `VERSION.md` directly on a release branch (e.g. `release/v1.5.0`) without a PR is allowed — this is the one case where a direct commit to a protected branch is acceptable. Only `VERSION.md` may be updated this way. All other changes must go through a feature branch and PR.

### Branch naming

| Branch type | Convention | Example |
|---|---|---|
| Feature | `feature/short-description` | `feature/windows-symlink-support` |
| Bug fix | `fix/short-description` | `fix/setup-path-spaces` |
| Documentation | `docs/short-description` | `docs/linux-setup-guide` |
| Release | `release/vX.X.X` | `release/v1.3.0` |

If you're working on a tracked GitHub Issue, prefix with the issue number:
`#12-feature/windows-symlink-support`

### Keeping a feature branch in sync

Merge conflicts arise when a base branch (`functional-test` or a release branch) accumulates commits that the feature branch doesn't have. The longer a feature branch lives, the greater the drift.

**During a long feature cycle, regularly merge the base into the feature branch:**

```bash
git fetch origin
git checkout feature/your-description
git merge origin/functional-test   # or origin/release/vX.X.X
# resolve any conflicts, then:
git push
```

Do this at least once before opening either PR. Catching a 1-commit conflict is far cheaper than a 10-commit one.

**The most common cause of unexpected divergence is a direct push bypassing branch protection.** Even a single admin-override commit to `functional-test` will cause a conflict the next time the feature branch tries to merge. This is why the admin override must be treated as a genuine last resort — not a shortcut. Every bypass creates merge debt.

**Signals to sync immediately:**
- GitHub shows "This branch has conflicts" on your PR
- A teammate merges something to `functional-test` while your PR is open
- You've been working on a feature branch for more than a few days

### Commit messages

This project uses [Conventional Commits](https://www.conventionalcommits.org):

```
feat: add Windows symlink support without admin elevation
fix: handle spaces in home directory paths
docs: add Linux setup guide for Ubuntu 22.04
chore: update .gitignore for JetBrains files
refactor: simplify machine.json validation in setup.sh
```

---

## Documentation standards

All documentation must meet the following standards. The CI workflow
(`docs-check.yml`) enforces these on every push. Locally, run:

```bash
bash scripts/check-docs.sh
```

Or as a Claude Code command (if configured):

```
--docscheck
```

### Scripts

Every script in `scripts/` must:

- Support `-h` and `--help` flags that print usage to stdout and exit 0
- Have a corresponding man page in `man/man1/claude-dotfiles-<name>.1`

### Man pages

Every man page must include these sections (in order where possible):

| Section | Purpose |
|---|---|
| `NAME` | One-line description |
| `SYNOPSIS` | How to invoke |
| `DESCRIPTION` | What it does |
| `OPTIONS` | All flags documented |
| `EXIT STATUS` | All exit codes listed |
| `EXAMPLES` | At least one working example |
| `SEE ALSO` | Related scripts and docs |

Format: groff (`.1` suffix, section 1). View with: `man ./man/man1/<name>.1`

### Commands (`commands/`)

Every `.md` file in `commands/` must begin with a markdown title (`# Title`).

### README.md

Required top-level sections: `## What it does`, `## Quick start`,
`## CLI reference`, `## File structure`, `## machine.json structure`,
`## OS compatibility`, `## Contributing`, `## Licence`.

### When to run

- **Before every PR** — `bash scripts/check-docs.sh` must exit 0
- **On every push** — CI enforces automatically via `docs-check.yml`

If CI fails, fix the documentation issues before requesting a review. PRs with
failing docs checks will not be reviewed.

---

## Submitting a pull request

1. **Clone** the repo (do not fork) — see README for why
2. Create your branch from `main`: `git checkout -b feature/short-description`
3. Make your changes
4. Run the documentation check: `bash scripts/check-docs.sh`
5. Test on at least one OS — note which in the PR description
6. Open **PR #1** against `functional-test`
7. Describe what changed and why; include OS tested and docs-check result
8. Once PR #1 is approved and merged, open **PR #2** from the same feature branch against the current `release/vX.X.X` branch — this happens immediately on approval, not at end of cycle

Do not update `VERSION.md` on your feature branch — that happens on the release branch.

PRs directly against `main` will not be accepted.

### PR size guidelines

PRs are reviewed manually. Large, wide-ranging PRs slow the whole pipeline — review takes longer, feedback is harder to act on, and merge conflicts are more likely. Keep PRs focused.

| | Guideline |
|---|---|
| **Scope** | One concern per PR — one bug fix, one feature, one refactor. Mixed-concern PRs will be asked to split. |
| **Files changed** | Aim for under 10 files. PRs touching more than 20 files will receive extra scrutiny. |
| **Lines changed** | Aim for under 300 lines (excluding generated files, schemas, and test data). |
| **Commits** | Squash noise commits before opening the PR. Each commit should be a coherent unit. |
| **UAT reference** | Link the relevant UAT test case IDs (e.g. *"covers UAT-006, UAT-007"*) so reviewers know what to test. |

**If your change is naturally large** (e.g. a new script that requires a man page, a command, and schema updates), that is fine — the size guideline is about avoiding unrelated changes being bundled together, not about penalising complete, coherent features.

**For forked repos:** the same rules apply. A PR from a fork that touches multiple unrelated areas will be asked to split before review begins. This keeps review time predictable and feedback actionable.

---

## Maintainer workflow

Maintainers follow the same branch workflow as contributors — no exceptions:

```
feature/description  ─→  functional-test  (PR #1)
feature/description  ─→  release/vX.X.X   (PR #2, after #1 approved)
release/vX.X.X       ─→  main             (PR #3, monthly)
```

**Admin override** is a break-glass option for genuine emergencies only (e.g. a critical security fix that cannot wait for a full PR cycle). It is not a shortcut for convenience. Every direct push to a protected branch should be treated as a debt that requires a follow-up PR to document what changed and why.

---

## Backward compatibility

**We evolve. We don't break.**

Existing users run `update.sh` and their setup continues to work — without re-running setup, without reading changelogs, without any intervention. This is a hard requirement, not a guideline.

### The rule

**A user who set up claude-dotfiles on day one must be able to run `update.sh` on any future version and have everything continue working correctly.**

There are no exceptions. If a change cannot meet this bar, it does not ship.

### How to evolve without breaking

**New `machine.json` fields must be optional with safe defaults.** Scripts must never crash because a field is absent. Use `_read_json_field` which returns an empty string for missing keys — build all logic to handle empty gracefully.

**New behaviour must be additive.** Add capabilities; do not remove or change existing ones. If existing behaviour needs to change, provide the new behaviour alongside the old and deprecate the old over multiple releases before removing it.

**`update.sh` must always be safe.** It pulls and refreshes symlinks. It must work correctly regardless of which version the user is coming from — including versions that pre-date the current schema.

**`setup.sh` re-runs must be safe.** Re-running setup on an existing install must preserve all existing config and only add or update what is new. It must never reset, overwrite, or delete anything the user has configured.

### When adding a new `machine.json` field

1. Give it a safe empty-string default in all scripts — missing field = feature disabled, not crash
2. Add it to `machine.schema.json` with a clear description
3. Add it to `machine.json.template` and `examples/machine.json.example`
4. Document it in `VERSION.md` under the relevant release
5. Ensure a re-run of `setup.sh` populates it gracefully on existing machines

### What a breaking change looks like — and why it is rejected

A breaking change is anything that causes `update.sh` to produce a worse result than before: error on startup, lost config, broken symlinks, commands that stop working, or behaviour that changes without the user opting in. **These are not shipped.** If a proposed change would break existing installs, it must be redesigned until it does not.

---

## Versioning

This project follows [Semantic Versioning](https://semver.org):

| Type | When | Example |
|---|---|---|
| **PATCH** (x.y.**z**) | Bug fixes, docs corrections, small tweaks | v1.2.1 |
| **MINOR** (x.**y**.0) | New features — monthly release cycle | v1.3.0 |
| **MAJOR** (**x**.0.0) | Large new features, significant changes | v2.0.0 |

## Release process

Releases are managed by [Spyced Concepts Ltd.](https://spycedconcepts.co.uk) on a monthly cycle:

1. `release/vX.X.X` branch accumulates approved features from their feature branches throughout the cycle
2. `VERSION.md` updated on the release branch with the final changelog
3. `release/vX.X.X` → `main` (PR, merge, tag)
4. GitHub release created with `VERSION.md` notes
5. `functional-test` synced from `main` to give new features a clean foundation

Releases are tracked via [GitHub Issues](https://github.com/Spyced-Concepts/claude-dotfiles/issues) and [GitHub Discussions](https://github.com/Spyced-Concepts/claude-dotfiles/discussions).

---

## Maintainers

This project is maintained by [Spyced Concepts Ltd.](https://spycedconcepts.co.uk)

Questions, ideas, or feedback: [spycedconcepts.co.uk](https://spycedconcepts.co.uk)
