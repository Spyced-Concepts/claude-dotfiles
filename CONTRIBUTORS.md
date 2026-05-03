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

### Branch naming

| Branch type | Convention | Example |
|---|---|---|
| Feature | `feature/short-description` | `feature/windows-symlink-support` |
| Bug fix | `fix/short-description` | `fix/setup-path-spaces` |
| Documentation | `docs/short-description` | `docs/linux-setup-guide` |
| Release | `release/vX.X.X` | `release/v1.3.0` |

If you're working on a tracked GitHub Issue, prefix with the issue number:
`#12-feature/windows-symlink-support`

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

## Submitting a pull request

1. **Clone** the repo (do not fork) — see README for why
2. Create your branch from `main`: `git checkout -b feature/short-description`
3. Make your changes
4. Test on at least one OS — note which in the PR description
5. Open **PR #1** against `functional-test`
6. Describe what changed and why; include OS tested
7. Once PR #1 is approved and merged, open **PR #2** from the same feature branch against the current `release/vX.X.X` branch — this happens immediately on approval, not at end of cycle

Do not update `VERSION.md` on your feature branch — that happens on the release branch.

PRs directly against `main` will not be accepted.

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
