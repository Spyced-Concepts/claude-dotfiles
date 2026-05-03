# Roadmap

This is the public roadmap for claude-dotfiles. Items here reflect our current intentions — priorities may shift based on community feedback and real-world usage. 

**Want to influence the roadmap?** Open a [feature request](https://github.com/Spyced-Concepts/claude-dotfiles/issues/new?template=feature_request.md) or start a Discussion. The best features come from real problems.

---

## Released

### ✅ v1.0.0 — Initial release

- `CLAUDE.md` template with machine config system and keyword framework
- `machine.json` for machine-specific paths
- `setup.sh` / `update.sh` for one-command setup on any machine
- MIT licence, SECURITY.md, CONTRIBUTORS.md, GitHub issue templates

### ✅ v1.1.0 — Discovery + slash commands

- **`knowledge_root`** — auto-discover all subdirectories of a parent folder as knowledge directories; no need to add each one individually
- **`project_root`** — clearly separates code artefacts from knowledge/docs
- **Built-in slash commands** — `/seclog`, `/monthly-check`, `/quarterly-review`, `/update`; symlinked to `~/.claude/commands/` so they work in any Claude Code session
- **Interactive `setup.sh`** — guided prompts, recursive discovery, command installation

---

## In progress / near term

### 🔄 v1.2.0 — Multi-AI-CLI adapter framework

Right now, claude-dotfiles is Claude Code-specific — `CLAUDE.md`, the `commands/` format, and the `machine.json` reading are all Claude Code concepts. Many developers use multiple AI CLI tools. The adapter framework makes claude-dotfiles useful across all of them.

**Design:** an `adapters/` directory, one subfolder per AI CLI. `setup.sh` asks which CLI(s) you use and installs the right adapter.

| Adapter | Status |
|---|---|
| `adapters/claude-code/` | ✓ Current implementation |
| `adapters/aider/` | Planned |
| `adapters/gemini-cli/` | Planned |
| Community adapters | Welcome — see CONTRIBUTORS.md |

**Community input wanted:** Which AI CLIs do you use? What would a good adapter look like for your tool? [Open a discussion](https://github.com/Spyced-Concepts/claude-dotfiles/discussions) or feature request.

### 🔄 v1.2.0 — Re-run setup for new settings

When you run `/update` and a new version introduces new `machine.json` fields, you should be able to configure them without a full reinstall. `setup.sh --reconfigure` will diff your installed `machine.json` against the template and guide you through any new settings only.

---

## Planned

### v2.0.0 — atlink claude integration

[atlink](https://spycedconcepts.co.uk) — a developer workflow CLI by Spyced Concepts (coming soon) — will include an `atlink claude` subcommand group for managing claude-dotfiles without touching git directly:

```bash
atlink claude init      # clone claude-dotfiles and run setup on this machine
atlink claude update    # pull latest and redeploy
atlink claude status    # show current config state and available updates
```

This makes claude-dotfiles accessible to developers who aren't comfortable with git.

---

## Backlog

*Ideas under consideration — not yet scheduled:*

- **Shared settings across machines** — a `shared.json` for carrying canonical variable names and settings across machines. The design principle: variable *names* are portable; path *values* are machine-specific.

  **Architecture:**
  ```
  Spyced-Concepts/claude-dotfiles  (public — this repo)
  └── shared.json.template         schema only; defines the concept, not your names

  yourname/my-dotfiles             (your private fork or private repo)
  ├── shared.json                  YOUR canonical variable names ($NOTES, $WORK, etc.)
  ├── CLAUDE.md                    your customised instructions
  └── commands/                    your custom commands

  ~/.claude/machine.json           machine-local; maps $NOTES → /actual/path/on/this/machine
  ```

  If every machine maps `"notes"` → wherever notes live locally, then any command referencing `$NOTES` works everywhere without modification. `shared.json` lives in the user's *private* fork — never in the public tool repo. The public repo ships only the schema and template.

- **Shell completions** — bash, zsh, fish completions for `setup.sh` flags

- **Community command gallery** — curated `/commands` contributions from the community

- **Multi-profile support** — switch between different CLAUDE.md profiles per project type (e.g., a "security review" profile vs a "writing" profile)

- **Validation** — `setup.sh --validate` checks that all paths in `machine.json` actually exist and that all variables referenced in commands are defined

- **Windows native** — proper PowerShell setup script alongside the Git Bash version

- **Homebrew formula** — `brew install claude-dotfiles` for macOS

---

## How to contribute to the roadmap

- **Feature requests** → [open an issue](https://github.com/Spyced-Concepts/claude-dotfiles/issues/new?template=feature_request.md)
- **Discussion** → [GitHub Discussions](https://github.com/Spyced-Concepts/claude-dotfiles/discussions)
- **Direct contact** → [spycedconcepts.co.uk](https://spycedconcepts.co.uk)

We read everything.
