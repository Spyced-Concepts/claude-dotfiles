#!/usr/bin/env bash
# claude-dotfiles uninstall
#
# Removes claude-dotfiles from this machine. Offers to restore a plain
# local CLAUDE.md so Claude Code continues to work. Does not delete any
# repos or personal data without explicit confirmation.
#
# Usage:
#   bash <dotfiles-dir>/scripts/uninstall.sh [OPTIONS]
#
# Options:
#   -h, --help   Show this help message and exit
#   -y, --yes    Skip the initial confirmation prompt
#
# Man page: man claude-dotfiles-uninstall
# More info: https://github.com/Spyced-Concepts/claude-dotfiles

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
MACHINE_JSON="$CLAUDE_DIR/machine.json"
CONFIRM=false

# ── Help ──────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF

Usage: bash $(basename "$0") [OPTIONS]

Uninstall claude-dotfiles from this machine. Returns Claude Code to a
standalone configuration with no dependency on any git repo.

Options:
  -h, --help   Show this help message and exit
  -y, --yes    Skip the initial confirmation prompt

Steps:
  1. Removes ~/.claude/CLAUDE.md symlink; offers to restore a plain local copy
  2. Removes command symlinks from ~/.claude/commands/
  3. Offers to remove ~/.claude/machine.json and ~/.claude/settings.json
  4. Offers to delete the dotfiles repo and personal config repo

Man page: man claude-dotfiles-uninstall
More info: https://github.com/Spyced-Concepts/claude-dotfiles
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    -y|--yes)  CONFIRM=true ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

# ── Helpers ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET}  $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET}   $*"; }
bad()  { echo -e "  ${RED}✗${RESET}  $*"; }

_json_field() {
  python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get(sys.argv[2], ''))
except: print('')
" "$1" "$2" 2>/dev/null
}

# Read personal_config_dir before potentially removing machine.json
personal_dir=""
[ -f "$MACHINE_JSON" ] && personal_dir=$(_json_field "$MACHINE_JSON" "personal_config_dir")

echo ""
echo -e "${BOLD}claude-dotfiles uninstall${RESET}"
echo "═════════════════════════"
echo ""
echo "  This removes claude-dotfiles from this machine."
echo "  You will be asked before anything is deleted."
echo ""

if ! $CONFIRM; then
  read -p "  Continue? (y/n): " answer
  case "$answer" in
    y|Y) ;;
    *) echo "  Aborted."; exit 0 ;;
  esac
fi

echo ""

# ── 1. CLAUDE.md ──────────────────────────────────────────────────────────────

echo "── CLAUDE.md ───────────────────────────────────────────────────────────"

CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if [ -L "$CLAUDE_MD" ]; then
  rm "$CLAUDE_MD"
  ok "Removed ~/.claude/CLAUDE.md symlink"

  echo ""
  echo "  Claude Code needs ~/.claude/CLAUDE.md to work. Options:"
  echo ""
  echo "  1. Restore a plain local copy (recommended) — Claude Code continues"
  echo "     to work; no longer linked to any git repo"
  echo "  2. Leave it absent — Claude Code has no global instructions until"
  echo "     you create one manually"
  echo ""
  read -p "  Restore a plain local CLAUDE.md? (y/n): " restore_claude_md
  if [ "$restore_claude_md" = "y" ]; then
    if [ -n "$personal_dir" ] && [ -f "$personal_dir/CLAUDE.md" ]; then
      cp "$personal_dir/CLAUDE.md" "$CLAUDE_MD"
      ok "Restored ~/.claude/CLAUDE.md from your personal config (plain file)"
    elif [ -f "$DOTFILES_DIR/CLAUDE.md" ]; then
      cp "$DOTFILES_DIR/CLAUDE.md" "$CLAUDE_MD"
      ok "Restored ~/.claude/CLAUDE.md from public template (plain file)"
    else
      warn "Could not find a CLAUDE.md to restore — creating a minimal one"
      cat > "$CLAUDE_MD" << 'MDEOF'
# Claude Code — Global Configuration

You are running without claude-dotfiles. Edit this file directly to
add your personal configuration.
MDEOF
      ok "Created minimal ~/.claude/CLAUDE.md"
    fi
    warn "This file is now a plain local file — edit it directly"
    warn "It is no longer tracked by any git repo"
  fi
elif [ -f "$CLAUDE_MD" ]; then
  warn "~/.claude/CLAUDE.md is a regular file — leaving it unchanged"
else
  warn "~/.claude/CLAUDE.md not found — nothing to remove"
fi

echo ""

# ── 2. Command symlinks ───────────────────────────────────────────────────────

echo "── Commands ────────────────────────────────────────────────────────────"

COMMANDS_DIR="$CLAUDE_DIR/commands"
removed_cmds=0
skipped_cmds=0

if [ -d "$COMMANDS_DIR" ]; then
  for link in "$COMMANDS_DIR/"*.md; do
    [ -e "$link" ] || continue
    if [ -L "$link" ]; then
      rm "$link"
      removed_cmds=$((removed_cmds + 1))
    else
      skipped_cmds=$((skipped_cmds + 1))
    fi
  done
  ok "Removed $removed_cmds command symlink(s)"
  [ $skipped_cmds -gt 0 ] && warn "$skipped_cmds non-symlink file(s) left in ~/.claude/commands/"
else
  warn "~/.claude/commands/ not found — nothing to remove"
fi

echo ""

# ── 3. machine.json and settings.json ────────────────────────────────────────

echo "── Configuration files ─────────────────────────────────────────────────"
echo ""
echo "  machine.json holds your machine paths and preferences."
echo "  settings.json holds your permissions allowlist."
echo ""

read -p "  Remove ~/.claude/machine.json? (y/n): " rm_machine
if [ "$rm_machine" = "y" ] && [ -f "$MACHINE_JSON" ]; then
  rm "$MACHINE_JSON"
  ok "Removed ~/.claude/machine.json"
elif [ "$rm_machine" != "y" ]; then
  warn "Keeping ~/.claude/machine.json"
fi

read -p "  Remove ~/.claude/settings.json? (y/n): " rm_settings
if [ "$rm_settings" = "y" ] && [ -f "$CLAUDE_DIR/settings.json" ]; then
  rm "$CLAUDE_DIR/settings.json"
  ok "Removed ~/.claude/settings.json"
elif [ "$rm_settings" != "y" ]; then
  warn "Keeping ~/.claude/settings.json"
fi

echo ""

# ── 4. Delete repos ───────────────────────────────────────────────────────────

echo "── Repositories ────────────────────────────────────────────────────────"
echo ""
echo "  These repos are NOT deleted by default."
echo "  You must confirm each one separately."
echo ""

# Personal config repo — warn strongly, it's the user's own data
if [ -n "$personal_dir" ] && [ -d "$personal_dir" ]; then
  echo -e "  ${YELLOW}⚠  Your personal config repo contains your custom CLAUDE.md,"
  echo -e "     commands, and configuration. Make sure it is pushed to GitHub${RESET}"
  echo -e "  ${YELLOW}   before deleting it here.${RESET}"
  echo ""
  read -p "  Delete personal config repo at $personal_dir? (y/n): " rm_personal
  if [ "$rm_personal" = "y" ]; then
    read -p "  Are you sure? This cannot be undone locally. (type YES to confirm): " rm_personal_confirm
    if [ "$rm_personal_confirm" = "YES" ]; then
      rm -rf "$personal_dir"
      ok "Deleted $personal_dir"
    else
      warn "Keeping personal config repo"
    fi
  else
    warn "Keeping $personal_dir"
  fi
fi

# Dotfiles repo
echo ""
read -p "  Delete the claude-dotfiles repo at $DOTFILES_DIR? (y/n): " rm_dotfiles
if [ "$rm_dotfiles" = "y" ]; then
  read -p "  Are you sure? (type YES to confirm): " rm_dotfiles_confirm
  if [ "$rm_dotfiles_confirm" = "YES" ]; then
    # The repo dir is what this script lives in — delete on next tick
    echo "  Scheduling deletion of $DOTFILES_DIR ..."
    (sleep 1 && rm -rf "$DOTFILES_DIR") &
    ok "Deletion scheduled for $DOTFILES_DIR"
  else
    warn "Keeping $DOTFILES_DIR"
  fi
else
  warn "Keeping $DOTFILES_DIR"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "═════════════════════════"
echo -e "${GREEN}${BOLD}Uninstall complete.${RESET}"
echo ""
echo "  Claude Code will continue to work using ~/.claude/CLAUDE.md"
echo "  (now a plain local file, no longer linked to any repo)."
echo ""
echo "  To reinstall claude-dotfiles at any time:"
echo "    curl -fsSL https://raw.githubusercontent.com/Spyced-Concepts/claude-dotfiles/main/install.sh | bash"
echo ""
