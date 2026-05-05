# Security Policy

## Reporting a security vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

If you discover a security issue in claude-dotfiles, report it privately via the contact form at:

**[spycedconcepts.co.uk](https://spycedconcepts.co.uk)**

Include:
- A description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested mitigations (optional)

We aim to acknowledge all security reports within 48 hours and will keep you informed as we investigate and address the issue.

---

## Security considerations for users

### Running scripts from the internet

The one-line installer uses `curl | bash`, which executes a remote script directly.
**Before running any install command, verify the URL is the official GitHub repository:**

```
https://github.com/Spyced-Concepts/claude-dotfiles
```

If you prefer to inspect the script before running it:

```bash
curl -fsSL https://raw.githubusercontent.com/Spyced-Concepts/claude-dotfiles/main/install.sh > install.sh
cat install.sh        # review it
bash install.sh       # then run it
```

### Your personal config repo must be private

Your personal config repo contains your name, role, location, and any custom
instructions you give Claude. **This repo must be set to private on GitHub.**
Never make it public. The setup script creates it as private by default.

If you accidentally made it public: go to your repo's Settings → Danger Zone → Change repository visibility → Private.

### Files that must never be committed

The following files contain machine-specific paths or permissions and are
excluded by `.gitignore` in this repo. Never commit them to any public or
shared repo:

| File | Why |
|---|---|
| `~/.claude/machine.json` | Local filesystem paths |
| `~/.claude/settings.json` | Permissions allowlist |

### CLAUDE.md

`~/.claude/CLAUDE.md` is your global Claude Code configuration. It is loaded
in every Claude session. Review its contents to ensure it only instructs Claude
to take actions you expect. If it contains sensitive information (passwords,
API keys, personal data beyond what you intend), move that information
elsewhere.

### setup.sh and update.sh

These are shell scripts that run on your machine. Review them before running:

```bash
cat scripts/setup.sh
cat scripts/update.sh
```

`setup.sh` creates symlinks, writes `~/.claude/machine.json` and
`~/.claude/settings.json`, and may call `gh` to create a private GitHub repo.
`update.sh` pulls from the remote and re-runs `setup.sh`.

---

## Scope

claude-dotfiles is a configuration framework. In-scope security issues include:

- **Injection vulnerabilities** in setup.sh, update.sh, status.sh, check-docs.sh
- **Symlink attacks** involving `~/.claude/CLAUDE.md` or `~/.claude/commands/`
- **Information disclosure** — any scenario where sensitive data could be
  written to a public location
- **Dependency issues** — any supply chain concern with the scripts or templates

Out of scope: issues in Claude Code itself (Anthropic's software), GitHub, or
the user's private config repo.

---

## Supported versions

| Version | Supported |
|---|---|
| 1.x.x (latest) | ✓ |
| < 1.0.0 | ✗ |

---

## Disclosure policy

We follow responsible disclosure. Once a vulnerability is confirmed and patched,
we will publish details in a GitHub Security Advisory and note the fix in
`VERSION.md`.
