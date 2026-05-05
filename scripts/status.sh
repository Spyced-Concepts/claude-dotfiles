#!/usr/bin/env bash
# claude-dotfiles status
#
# Checks the health and sync state of your claude-dotfiles installation.
#
# Usage:
#   bash <dotfiles-dir>/scripts/status.sh [OPTIONS]
#
# Options:
#   -h, --help     Show this help message and exit
#   -q, --quiet    Suppress output; exit code only (0 = ok, 1 = issues found)
#
# Exit codes:
#   0  All checks passed
#   1  One or more checks flagged a warning or error
#
# Man page: man claude-dotfiles-status
# More info: https://github.com/Spyced-Concepts/claude-dotfiles

set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
MACHINE_JSON="$CLAUDE_DIR/machine.json"
QUIET=false

# ── Argument parsing ──────────────────────────────────────────────────────────

usage() {
  cat <<EOF

Usage: bash $(basename "$0") [OPTIONS]

Check the health and sync state of your claude-dotfiles installation.

Options:
  -h, --help     Show this help message and exit
  -q, --quiet    Suppress output; use exit code only

Checks performed:
  1. ~/.claude/machine.json   — present and readable
  2. ~/.claude/CLAUDE.md      — symlink intact; identity filled in
  3. claude-dotfiles          — up to date with remote
  4. Personal config repo     — in sync with remote

Exit codes:
  0   All checks passed
  1   One or more issues found

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

_out() { $QUIET || echo -e "$*"; }
ok()   { _out "  ${GREEN}✓${RESET}  $*"; }
warn() { _out "  ${YELLOW}⚠${RESET}   $*"; }
bad()  { _out "  ${RED}✗${RESET}  $*"; }
hdr()  { _out "  ${BOLD}$*${RESET}"; }

ISSUES=0

_out ""
_out "${BOLD}claude-dotfiles status${RESET}"
_out "══════════════════════"

# ── Helper: read a field from machine.json ────────────────────────────────────

_json_field() {
  python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get(sys.argv[2], ''))
except: print('')
" "$1" "$2" 2>/dev/null
}

# ── 1. machine.json ───────────────────────────────────────────────────────────

_out ""
hdr "Machine config"

if [ ! -f "$MACHINE_JSON" ]; then
  bad "~/.claude/machine.json not found"
  warn "Run: bash $DOTFILES_DIR/scripts/setup.sh"
  ISSUES=$((ISSUES + 1))
else
  machine_name=$(_json_field "$MACHINE_JSON" "name")
  machine_os=$(_json_field "$MACHINE_JSON" "os")
  ok "~/.claude/machine.json  ($machine_name / $machine_os)"
fi

# ── 2. CLAUDE.md ──────────────────────────────────────────────────────────────

_out ""
hdr "CLAUDE.md"

CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if [ ! -e "$CLAUDE_MD" ]; then
  bad "~/.claude/CLAUDE.md missing"
  warn "Run: bash $DOTFILES_DIR/scripts/setup.sh"
  ISSUES=$((ISSUES + 1))
elif [ -L "$CLAUDE_MD" ]; then
  target=$(readlink "$CLAUDE_MD")
  if [ -f "$target" ]; then
    ok "~/.claude/CLAUDE.md → $target"
  else
    bad "Symlink broken (target missing: $target)"
    warn "Run: bash $DOTFILES_DIR/scripts/setup.sh"
    ISSUES=$((ISSUES + 1))
  fi
else
  ok "~/.claude/CLAUDE.md (regular file)"
fi

if [ -f "$CLAUDE_MD" ] && grep -q '\[Your Name\]' "$CLAUDE_MD" 2>/dev/null; then
  warn "Identity section still has placeholder values — edit your personal CLAUDE.md"
  ISSUES=$((ISSUES + 1))
fi

# ── 3. claude-dotfiles version ────────────────────────────────────────────────

_out ""
hdr "claude-dotfiles"

dotfiles_dir=""
[ -f "$MACHINE_JSON" ] && dotfiles_dir=$(_json_field "$MACHINE_JSON" "dotfiles_dir")
[ -z "$dotfiles_dir" ] && dotfiles_dir="$DOTFILES_DIR"

if [ ! -d "$dotfiles_dir/.git" ]; then
  bad "Repo not found at $dotfiles_dir"
  ISSUES=$((ISSUES + 1))
else
  ok "Installed at $dotfiles_dir"
  _out "     Fetching remote state ..."
  git -C "$dotfiles_dir" fetch --quiet origin 2>/dev/null || true

  local_sha=$(git -C "$dotfiles_dir" rev-parse HEAD 2>/dev/null || echo "")
  remote_sha=$(git -C "$dotfiles_dir" rev-parse "@{u}" 2>/dev/null || echo "")

  if [ -z "$remote_sha" ]; then
    warn "Cannot check remote (no upstream tracking branch set)"
  elif [ "$local_sha" = "$remote_sha" ]; then
    ok "Up to date  (${local_sha:0:7})"
  else
    remote_ahead=$(git -C "$dotfiles_dir" rev-list "HEAD..@{u}" --count 2>/dev/null || echo 0)
    local_ahead=$(git -C "$dotfiles_dir"  rev-list "@{u}..HEAD"  --count 2>/dev/null || echo 0)
    [ "$remote_ahead" -gt 0 ] && {
      warn "$remote_ahead update(s) available"
      warn "Run: bash $dotfiles_dir/scripts/update.sh"
      ISSUES=$((ISSUES + 1))
    }
    [ "$local_ahead" -gt 0 ] && warn "$local_ahead local commit(s) not yet pushed"
  fi
fi

# ── 4. Personal config repo ───────────────────────────────────────────────────

_out ""
hdr "Personal config repo"

personal_dir=""
[ -f "$MACHINE_JSON" ] && personal_dir=$(_json_field "$MACHINE_JSON" "personal_config_dir")

if [ -z "$personal_dir" ]; then
  bad "Not connected — setup is incomplete without a personal config repo"
  warn "Your identity, custom commands, and personal CLAUDE.md live here."
  warn "Run: bash $dotfiles_dir/scripts/setup.sh"
  ISSUES=$((ISSUES + 1))
elif [ ! -d "$personal_dir/.git" ]; then
  bad "Repo not found at $personal_dir"
  warn "Update personal_config_dir in ~/.claude/machine.json or re-run setup"
  ISSUES=$((ISSUES + 1))
else
  ok "Found at $personal_dir"
  _out "     Fetching remote state ..."
  git -C "$personal_dir" fetch --quiet origin 2>/dev/null || true

  status_out=$(git -C "$personal_dir" status -b --porcelain 2>/dev/null)
  if echo "$status_out" | grep -q '\[behind'; then
    count=$(echo "$status_out" | grep -oE 'behind [0-9]+' | grep -oE '[0-9]+' || echo "?")
    warn "$count unpulled commit(s) — run: git -C \"$personal_dir\" pull"
    ISSUES=$((ISSUES + 1))
  elif echo "$status_out" | grep -q '\[ahead'; then
    count=$(echo "$status_out" | grep -oE 'ahead [0-9]+' | grep -oE '[0-9]+' || echo "?")
    warn "$count unpushed commit(s) — run: git -C \"$personal_dir\" push"
    ISSUES=$((ISSUES + 1))
  else
    ok "In sync with remote"
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────

_out ""
_out "══════════════════════"
if [ $ISSUES -eq 0 ]; then
  _out "${GREEN}${BOLD}All checks passed.${RESET}"
else
  _out "${YELLOW}${BOLD}$ISSUES issue(s) found — see warnings above.${RESET}"
fi
_out ""

exit $((ISSUES > 0 ? 1 : 0))
