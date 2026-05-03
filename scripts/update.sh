#!/usr/bin/env bash
# claude-dotfiles update script
# Pull the latest configuration and re-deploy symlinks.
# https://github.com/Spyced-Concepts/claude-dotfiles

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
