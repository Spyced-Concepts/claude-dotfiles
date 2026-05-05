# AI Contributor Rules — claude-dotfiles

Rules for AI tools (Claude Code, Cursor, Copilot, and others) working in this repository.

## Pre-commit checks

Always run `bash scripts/check-docs.sh` before committing. The CI pipeline runs this check — failing commits will be rejected.

## Commit conventions

Use conventional commit format: `type(scope): description`. Reference GitHub issues with `(#123)` in the title or `Fixes #123` in the commit body.
