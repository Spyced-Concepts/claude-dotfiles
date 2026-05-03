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

```
feature/description
       ↓  (PR)
functional-test      ← integration testing; must pass before release
       ↓  (PR)
release/vX.X.X       ← cut before each release; version bump here
       ↓  (PR)
main                 ← protected; production; tagged releases only
```

### Branch naming

| Branch type | Convention | Example |
|---|---|---|
| Feature | `feature/short-description` | `feature/windows-symlink-support` |
| Bug fix | `fix/short-description` | `fix/setup-path-spaces` |
| Documentation | `docs/short-description` | `docs/linux-setup-guide` |
| Release | `release/vX.X.X` | `release/v1.1.0` |

If this project has a Jira project configured, prefix with the ticket ID:
`CDF-12-feature/windows-symlink-support`

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

1. **Fork** the repo and create your branch from `functional-test` (not `main`)
2. Make your changes
3. Test on at least one OS — note which in the PR description
4. Update `VERSION.md` if your change is user-facing
5. Open a PR against `functional-test`
6. Describe what changed and why; include OS tested

PRs directly against `main` will not be accepted.

---

## Release process

Releases are managed by [Spyced Concepts Ltd.](https://spycedconcepts.co.uk):

1. `functional-test` → `release/vX.X.X` (version bump in `VERSION.md`)
2. Testing on macOS, Linux, and Windows
3. `release/vX.X.X` → `main` (merge + tag)
4. GitHub release created with `VERSION.md` notes

---

## Maintainers

This project is maintained by [Spyced Concepts Ltd.](https://spycedconcepts.co.uk)

Questions, ideas, or feedback: [spycedconcepts.co.uk](https://spycedconcepts.co.uk)
