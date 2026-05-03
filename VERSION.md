# Changelog

All notable changes to claude-dotfiles are documented here.

Format: [Semantic Versioning](https://semver.org) — MAJOR.MINOR.PATCH

---

## [1.1.0] — 2026-05-03

### Added

- **Recursive knowledge discovery** — `knowledge_root` in `machine.json` auto-discovers all subdirectories of a parent folder as knowledge directories; no need to add each one individually
- **Project root** — `project_root` in `machine.json` clearly separates code artefacts from knowledge directories
- **Built-in slash commands** — `commands/` directory ships three ready-to-use commands: `/seclog`, `/monthly-check`, `/quarterly-review`
- **Interactive setup** — `setup.sh` now guides you through knowledge root discovery, directory selection, and command installation with clear prompts and terminology
- **Commands symlink** — `setup.sh` symlinks `~/.claude/commands/` to the repo so commands stay in sync with `update.sh`

### Changed

- `machine.json.template` — clearer terminology distinguishing projects (code) from knowledge directories (docs, notes, todos)
- `setup.sh` — full interactive rewrite with guided prompts and better explanatory text

---

## [1.0.0] — 2026-05-03

### Initial release

- Global `CLAUDE.md` template with machine config system, session greeting, and keyword framework
- `machine.json.template` — tool-agnostic knowledge directory config
- `settings.json.template` — Claude Code permissions allowlist template
- `scripts/setup.sh` — one-command setup for macOS, Linux, and Windows (Git Bash)
- `scripts/update.sh` — pull latest and redeploy symlinks
- `examples/machine.json.example` — worked example
- MIT licence
- Full README with OS compatibility table and atlink integration notes
