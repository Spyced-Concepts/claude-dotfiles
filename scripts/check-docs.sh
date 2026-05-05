#!/usr/bin/env bash
# claude-dotfiles documentation checker
#
# Verifies that all scripts, commands, man pages, and documentation meet
# project standards. Run before every PR and on every push.
#
# Checks:
#   1. Every script in scripts/ has -h / --help support
#   2. Every script in scripts/ has a man page in man/man1/
#   3. Every man page has required sections (NAME, SYNOPSIS, DESCRIPTION,
#      OPTIONS, EXIT STATUS, EXAMPLES, SEE ALSO)
#   4. Every command file in commands/ has a title line (# Title)
#   5. README.md contains required sections
#
# Usage:
#   bash <dotfiles-dir>/scripts/check-docs.sh [OPTIONS]
#
# Options:
#   -h, --help     Show this help message and exit
#   -q, --quiet    Suppress output; exit code only
#
# Exit codes:
#   0  All checks passed
#   1  One or more checks failed
#
# Man page: man claude-dotfiles-check-docs
# More info: https://github.com/Spyced-Concepts/claude-dotfiles

set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUIET=false

# ── Argument parsing ──────────────────────────────────────────────────────────

usage() {
  cat <<EOF

Usage: bash $(basename "$0") [OPTIONS]

Check that all documentation meets project standards.

Options:
  -h, --help     Show this help message and exit
  -q, --quiet    Suppress output; use exit code only

Checks performed:
  1. scripts/     — every script has -h/--help support
  2. man/man1/    — every script has a man page
  3. man pages    — required sections present (NAME, SYNOPSIS, DESCRIPTION,
                    OPTIONS, EXIT STATUS, EXAMPLES, SEE ALSO)
  4. commands/    — every command file has a title line
  5. README.md    — required sections present

Exit codes:
  0   All checks passed
  1   One or more checks failed

More info: https://github.com/Spyced-Concepts/claude-dotfiles
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h|--help)  usage; exit 0 ;;
    -q|--quiet) QUIET=true ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
BOLD='\033[1m'; RESET='\033[0m'

_out()  { $QUIET || echo -e "$*"; }
ok()    { _out "  ${GREEN}✓${RESET}  $*"; }
fail()  { _out "  ${RED}✗${RESET}  $*"; ISSUES=$((ISSUES + 1)); }
hdr()   { _out "  ${BOLD}$*${RESET}"; }

ISSUES=0

_out ""
_out "${BOLD}claude-dotfiles documentation check${RESET}"
_out "════════════════════════════════════"

# ── Required man page sections ────────────────────────────────────────────────

REQUIRED_MAN_SECTIONS=(".SH NAME" ".SH SYNOPSIS" ".SH DESCRIPTION" ".SH OPTIONS" ".SH EXIT STATUS" ".SH EXAMPLES" ".SH SEE ALSO")

_check_man_page() {
  local manfile="$1"
  local missing=()
  for section in "${REQUIRED_MAN_SECTIONS[@]}"; do
    grep -q "^${section}" "$manfile" || missing+=("$section")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    fail "$(basename "$manfile") — missing sections: ${missing[*]}"
    return 1
  fi
  return 0
}

# ── 1. Scripts: --help support ────────────────────────────────────────────────

_out ""
hdr "1. Scripts — --help support"

for script in "$DOTFILES_DIR/scripts/"*.sh; do
  [ -f "$script" ] || continue
  name=$(basename "$script")
  if grep -q -- '--help' "$script" 2>/dev/null; then
    ok "$name  --help supported"
  else
    fail "$name  no --help flag found"
  fi
done

# ── 2. Scripts: man pages ─────────────────────────────────────────────────────

_out ""
hdr "2. Scripts — man pages"

for script in "$DOTFILES_DIR/scripts/"*.sh; do
  [ -f "$script" ] || continue
  name=$(basename "$script" .sh)
  manfile="$DOTFILES_DIR/man/man1/claude-dotfiles-${name}.1"
  if [ -f "$manfile" ]; then
    ok "claude-dotfiles-${name}.1 — present"
  else
    fail "claude-dotfiles-${name}.1 — missing  (expected: $manfile)"
  fi
done

# ── 3. Man pages: required sections ──────────────────────────────────────────

_out ""
hdr "3. Man pages — required sections"

for manfile in "$DOTFILES_DIR/man/man1/"*.1; do
  [ -f "$manfile" ] || continue
  name=$(basename "$manfile")
  missing_sections=()
  all_ok=true
  for section in "${REQUIRED_MAN_SECTIONS[@]}"; do
    grep -q "^${section}" "$manfile" || { missing_sections+=("$section"); all_ok=false; }
  done
  if $all_ok; then
    ok "$name  all required sections present"
  else
    fail "$name  missing: ${missing_sections[*]}"
  fi
done

# ── 4. Commands: title line ───────────────────────────────────────────────────

_out ""
hdr "4. Commands — title lines"

for cmd in "$DOTFILES_DIR/commands/"*.md; do
  [ -f "$cmd" ] || continue
  name=$(basename "$cmd")
  first_line=$(head -1 "$cmd")
  if echo "$first_line" | grep -q '^# '; then
    ok "$name  — $(echo "$first_line" | sed 's/^# //')"
  else
    fail "$name  — no title line (expected: # Title)"
  fi
done

# ── 5. README.md: required sections ──────────────────────────────────────────

_out ""
hdr "5. README.md — required sections"

README="$DOTFILES_DIR/README.md"
REQUIRED_README_SECTIONS=("## What it does" "## Quick start" "## CLI reference" "## File structure" "## machine.json structure" "## OS compatibility" "## Contributing" "## Licence")

for section in "${REQUIRED_README_SECTIONS[@]}"; do
  if grep -q "^${section}" "$README" 2>/dev/null; then
    ok "$section"
  else
    fail "$section  — missing from README.md"
  fi
done

# ── Summary ───────────────────────────────────────────────────────────────────

_out ""
_out "════════════════════════════════════"
if [ $ISSUES -eq 0 ]; then
  _out "${GREEN}${BOLD}All documentation checks passed.${RESET}"
else
  _out "${RED}${BOLD}$ISSUES check(s) failed — see above.${RESET}"
  _out ""
  _out "  Fix all failures before opening a PR."
fi
_out ""

exit $((ISSUES > 0 ? 1 : 0))
