#!/usr/bin/env bash
# claude-dotfiles update script
# Pull the latest configuration and re-deploy symlinks.
# https://github.com/Spyced-Concepts/claude-dotfiles

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Help ──────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF

Usage: bash $(basename "$0") [OPTIONS]

Pull the latest claude-dotfiles and redeploy symlinks.

Options:
  -h, --help   Show this help message and exit

What this does:
  1. git pull in the claude-dotfiles repo
  2. Re-runs setup.sh to refresh any new symlinks or config

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

echo ""
echo "claude-dotfiles update"
echo "======================"

# Pull latest
echo "Pulling latest from origin ..."
cd "$DOTFILES_DIR"
git pull

# Re-run setup to ensure symlinks are current
echo "Redeploying symlinks ..."
bash "$DOTFILES_DIR/scripts/setup.sh"

echo "Update complete."
echo ""
