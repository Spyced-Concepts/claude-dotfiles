# Changelog

All notable changes to claude-dotfiles are documented here.

Format: [Semantic Versioning](https://semver.org) — MAJOR.MINOR.PATCH

---

## [Unreleased] — targeting v1.5.0

### Added

- **Private config repo setup** — `setup.sh` now guides users through connecting or creating their personal private GitHub repo (required to complete setup). Detects the GitHub CLI (`gh`) and uses it for automated repo creation if available; falls back to step-by-step manual instructions if not.
- **`scripts/status.sh`** — new CLI command that checks health and sync state across four areas: machine.json, CLAUDE.md symlink, claude-dotfiles version, and personal config repo sync. Exit code 0 = all clear; 1 = issues found. Supports `--quiet` for scripting/CI.
- **`scripts/check-docs.sh`** — documentation quality gate. Verifies every script has `--help`, every script has a man page, man pages have all required sections, commands have title lines, and README has required sections. Run before every PR; enforced by CI.
- **`--docscheck` command** — AI command that runs `check-docs.sh` and explains any failures.
- **`--status` command** — AI command that runs `status.sh` and explains any issues.
- **Man pages** — groff man pages for all scripts: `claude-dotfiles(1)`, `claude-dotfiles-setup(1)`, `claude-dotfiles-update(1)`, `claude-dotfiles-status(1)`, `claude-dotfiles-check-docs(1)`.
- **`--help` / `-h`** — added to all scripts (`setup.sh`, `update.sh`, `status.sh`, `check-docs.sh`).
- **`dotfiles_dir` in machine.json** — records the path to the claude-dotfiles repo on this machine. Written by `setup.sh`; used by `status.sh` and CLAUDE.md for version checks.
- **`personal_config_dir` in machine.json** — records the path to the user's private config repo. Written by `setup.sh`. Setup is not considered complete without this.
- **CLAUDE.md startup checks** — at session start, Claude now checks: (1) claude-dotfiles version vs remote, (2) personal config sync state, (3) whether the Identity section still has placeholder values. All checks are non-blocking warnings.
- **CLAUDE.md command version warning** — before running any custom command, Claude warns if claude-dotfiles has updates available (non-blocking).
- **GitHub Actions docs-check workflow** — `docs-check.yml` runs `check-docs.sh` on every push and PR against main, functional-test, and release branches.
- **One-line install** in README — `curl -fsSL ... | bash` prominently documented in Quick Start.
- **Documentation standards policy** — added to `CONTRIBUTORS.md`. All scripts, commands, and man pages must meet the documented standard before any PR.
- **Schema updated** — `machine.schema.json` documents new fields: `dotfiles_dir`, `personal_config_dir`.

### Changed

- `machine.json.template` and `examples/machine.json.example` updated with new `dotfiles_dir` and `personal_config_dir` fields.
- `setup.sh` — setup reports "partially complete" if the personal config repo was skipped; `status.sh` check recommended as next step.
- README Quick Start — `curl` one-liner is now the primary install path; manual `git clone` still documented as alternative.
- README — added CLI Reference table and man page section.

---

## [1.4.0] — 2026-05-03

### Added

- **Configurable command dispatch** — custom commands in `~/.claude/commands/` can be invoked with a user-defined prefix. Default: `--` (e.g. `--daily`, `--health-check`). Set any prefix you like — `!`, `>`, `cmd:`, `run:`, or empty string for no prefix. Disabled by default; opt in via `machine.json`.
- **Five built-in generic commands** — `--daily` (daily briefing), `--todo` (open items), `--week-review` (weekly review), `--journal` (dated working notes), `--health-check` (verify setup integrity)
- **`--commands`** — lists all available custom commands with descriptions and shows how to invoke them with your configured prefix
- **`setup.sh` prefix prompt** — interactive setup now asks whether to enable command dispatch, lets you choose your prefix, and writes it to `machine.json` automatically
- **Personal config guidance** — README documents how to ask Claude Code itself to set up a personal private config repo: *"Help me set up a personal claude-config repo"*
- **No-prefix option** — set `command_prefix` to `""` to use command names directly without any prefix

### Changed

- Personal workflow commands (seclog, monthly-check, quarterly-review) removed from public repo — these belong in a private config repo, not a generic public tool
- `machine.json` schema and template updated with `command_prefix_enabled` and `command_prefix` fields
- `examples/machine.json.example` updated to show command prefix configuration
- ROADMAP updated: v1.4.0 is an early release; next scheduled June 2026 (v1.5.0)

### Note on `/` prefix

Claude Code's CLI intercepts `/word` as built-in slash commands before messages reach Claude. Custom commands therefore cannot use `/` as a prefix — use `--`, `!`, `>`, or any other string. If Anthropic adds native user-level slash command support in a future Claude Code release, this constraint will be revisited.

---

## [1.3.0] — 2026-05-03

### Changed

- **Branch workflow documented correctly** — `CONTRIBUTORS.md` updated to reflect the dual-PR pattern: feature branches go to `functional-test` (testing gate) and then immediately to the upcoming release branch on approval. Features accumulate in the release branch as they pass — the release branch is always ready to publish.
- **Release schedule** — `ROADMAP.md` documents that v1.3.0 is the last planned release until the June 2026 cycle. Next: v1.4.0 June 2026, unless a compelling feature arrives sooner.
- **Versioning convention** — patch (x.y.z) for fixes and small tweaks; minor (x.y.0) for new features on the monthly cycle; major (x.0.0) for large new features or significant changes.
- **Project tracking** — GitHub Issues and Discussions used for project management; Jira/Confluence references removed.

---

## [1.2.0] — 2026-05-03

### Changed

- **Schemas as pure metadata** — `schemas/machine.schema.json` and `schemas/shared.schema.json` now describe shape only (types, required fields, descriptions). All inline `examples` removed. Examples live in `examples/` folder.
- **Branch workflow formalised** — `CONTRIBUTORS.md` updated to document that maintainers follow the same branch workflow as contributors. Admin override explicitly documented as break-glass for genuine emergencies only.
- **Branch protection complete** — `release/*` pattern rule added; all protected branches (`main`, `functional-test`, `release/*`) now require PRs.

---

## [1.1.0] — 2026-05-03

### Added

- **Recursive knowledge discovery** — `knowledge_root` in `machine.json` auto-discovers all subdirectories of a parent folder as knowledge directories; no need to add each one individually
- **Project root** — `project_root` in `machine.json` clearly separates code artefacts from knowledge directories
- **Built-in slash commands** — `commands/` directory ships four ready-to-use commands: `/seclog`, `/monthly-check`, `/quarterly-review`, `/update`
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
