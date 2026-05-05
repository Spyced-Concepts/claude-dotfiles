#!/usr/bin/env bash
# claude-dotfiles update
#
# Pull the latest claude-dotfiles and personal config, then redeploy
# all symlinks non-interactively. Safe to run any time — makes no
# interactive prompts and does not change machine.json or settings.json.
#
# Usage:
#   bash <dotfiles-dir>/scripts/update.sh [OPTIONS]
#
# Options:
#   -h, --help   Show this help message and exit
#
# Man page: man claude-dotfiles-update
# More info: https://github.com/Spyced-Concepts/claude-dotfiles

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
MACHINE_JSON="$CLAUDE_DIR/machine.json"

# ── Help ──────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF

Usage: bash $(basename "$0") [OPTIONS]

Pull the latest claude-dotfiles and personal config, then redeploy symlinks.

Options:
  -h, --help   Show this help message and exit

What this does:
  1. git pull on the claude-dotfiles repo
  2. git pull on your personal config repo (if configured)
  3. Refreshes ~/.claude/CLAUDE.md symlink
  4. Refreshes all command symlinks in ~/.claude/commands/
     (public commands first, personal commands override)

Does NOT modify machine.json or settings.json.
Run setup.sh to change configuration interactively.

Man page: man claude-dotfiles-update
More info: https://github.com/Spyced-Concepts/claude-dotfiles
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

# ── Helper ────────────────────────────────────────────────────────────────────

_json_field() {
  python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get(sys.argv[2], ''))
except: print('')
" "$1" "$2" 2>/dev/null
}

echo ""
echo "claude-dotfiles update"
echo "======================"

# ── 1. Pull claude-dotfiles ───────────────────────────────────────────────────

echo ""
echo "── claude-dotfiles ─────────────────────────────────────────────────────"
echo "  Pulling latest from origin ..."
git -C "$DOTFILES_DIR" pull
echo "  ✓ Done"

# ── 2. Pull personal config ───────────────────────────────────────────────────

echo ""
echo "── Personal config repo ────────────────────────────────────────────────"

personal_dir=""
[ -f "$MACHINE_JSON" ] && personal_dir=$(_json_field "$MACHINE_JSON" "personal_config_dir")

if [ -z "$personal_dir" ]; then
  echo "  ⚠️  No personal config repo configured."
  echo "     Run setup.sh to connect one: bash $DOTFILES_DIR/scripts/setup.sh"
elif [ ! -d "$personal_dir/.git" ]; then
  echo "  ⚠️  Personal config dir not found at: $personal_dir"
  echo "     Run setup.sh to repair: bash $DOTFILES_DIR/scripts/setup.sh"
else
  echo "  Pulling latest from origin ..."
  git -C "$personal_dir" pull
  echo "  ✓ Done  ($personal_dir)"
fi

# ── 3. Refresh CLAUDE.md symlink ──────────────────────────────────────────────

echo ""
echo "── CLAUDE.md ───────────────────────────────────────────────────────────"

if [ -n "$personal_dir" ] && [ -f "$personal_dir/CLAUDE.md" ]; then
  ln -sf "$personal_dir/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  echo "  ✓ ~/.claude/CLAUDE.md → personal config"
else
  ln -sf "$DOTFILES_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  echo "  ✓ ~/.claude/CLAUDE.md → public template"
fi

# ── 4. Refresh command symlinks ───────────────────────────────────────────────
#
# Public commands first; personal commands override by symlinking last.
# Removing a command from either repo removes it on next update.

echo ""
echo "── Commands ────────────────────────────────────────────────────────────"

COMMANDS_DIR="$CLAUDE_DIR/commands"
mkdir -p "$COMMANDS_DIR"

# Remove stale symlinks that no longer have a source file
for link in "$COMMANDS_DIR/"*.md; do
  [ -L "$link" ] || continue
  target=$(readlink "$link")
  [ -f "$target" ] || { rm "$link"; echo "  ✗ Removed stale: $(basename "$link")"; }
done

# Public built-in commands
public_count=0
for cmd in "$DOTFILES_DIR/commands/"*.md; do
  [ -f "$cmd" ] || continue
  ln -sf "$cmd" "$COMMANDS_DIR/$(basename "$cmd")"
  public_count=$((public_count + 1))
done
echo "  ✓ $public_count public command(s) linked"

# Personal commands (override public if same name)
personal_count=0
if [ -n "$personal_dir" ] && [ -d "$personal_dir/commands" ]; then
  for cmd in "$personal_dir/commands/"*.md; do
    [ -f "$cmd" ] || continue
    ln -sf "$cmd" "$COMMANDS_DIR/$(basename "$cmd")"
    personal_count=$((personal_count + 1))
  done
  echo "  ✓ $personal_count personal command(s) linked (override public if same name)"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════"
echo "  Update complete."
echo ""
echo "  Run status check: bash $DOTFILES_DIR/scripts/status.sh"
echo "════════════════════════════════════"
echo ""
