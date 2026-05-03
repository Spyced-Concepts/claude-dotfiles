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

## Scope

claude-dotfiles is a configuration framework. Security considerations include:

- **machine.json** — contains local filesystem paths; never commit this file (excluded by `.gitignore`)
- **settings.json** — contains permissions allowlist; never commit this file (excluded by `.gitignore`)
- **CLAUDE.md** — the global config template; review before symlinking to ensure it doesn't instruct Claude to take actions you wouldn't expect
- **setup.sh / update.sh** — shell scripts; review before running, as with any install script

---

## Supported versions

| Version | Supported |
|---|---|
| 1.x.x (latest) | ✓ |
| < 1.0.0 | ✗ |

---

## Disclosure policy

We follow responsible disclosure. Once a vulnerability is confirmed and patched, we will publish details in a GitHub Security Advisory and note the fix in `VERSION.md`.
