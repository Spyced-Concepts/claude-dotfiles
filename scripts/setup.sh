#!/usr/bin/env bash
# claude-dotfiles setup script
# Run once on a new machine to deploy your Claude Code configuration.
# https://github.com/Spyced-Concepts/claude-dotfiles

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo ""
echo "claude-dotfiles setup"
echo "====================="
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Check claude is installed
if ! command -v claude &> /dev/null; then
  echo "⚠️  Claude Code CLI not found."
  echo "   Install it: npm install -g @anthropic-ai/claude-code"
  echo "   Then re-run this script."
  exit 1
fi

# Create ~/.claude if needed
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "Creating ~/.claude ..."
  mkdir -p "$CLAUDE_DIR"
fi

# Symlink CLAUDE.md
CLAUDE_MD_TARGET="$CLAUDE_DIR/CLAUDE.md"
CLAUDE_MD_SOURCE="$DOTFILES_DIR/CLAUDE.md"

if [ -L "$CLAUDE_MD_TARGET" ]; then
  echo "✓ ~/.claude/CLAUDE.md symlink already exists — updating ..."
  ln -sf "$CLAUDE_MD_SOURCE" "$CLAUDE_MD_TARGET"
elif [ -f "$CLAUDE_MD_TARGET" ]; then
  echo "⚠️  ~/.claude/CLAUDE.md exists as a regular file."
  read -p "   Replace with symlink? (y/n): " replace
  if [ "$replace" == "y" ]; then
    cp "$CLAUDE_MD_TARGET" "$CLAUDE_MD_TARGET.backup"
    echo "   Backed up to ~/.claude/CLAUDE.md.backup"
    ln -sf "$CLAUDE_MD_SOURCE" "$CLAUDE_MD_TARGET"
    echo "✓ Symlink created."
  fi
else
  ln -sf "$CLAUDE_MD_SOURCE" "$CLAUDE_MD_TARGET"
  echo "✓ ~/.claude/CLAUDE.md symlinked."
fi

# Copy machine.json template if machine.json doesn't exist
MACHINE_JSON="$CLAUDE_DIR/machine.json"
if [ ! -f "$MACHINE_JSON" ]; then
  cp "$DOTFILES_DIR/machine.json.template" "$MACHINE_JSON"
  echo "✓ ~/.claude/machine.json created from template."
  echo ""
  echo "  Edit it now to set your machine-specific paths:"
  echo "  $MACHINE_JSON"
else
  echo "✓ ~/.claude/machine.json already exists — leaving unchanged."
fi

# Copy settings.json template if settings.json doesn't exist
SETTINGS_JSON="$CLAUDE_DIR/settings.json"
if [ ! -f "$SETTINGS_JSON" ]; then
  cp "$DOTFILES_DIR/settings.json.template" "$SETTINGS_JSON"
  echo "✓ ~/.claude/settings.json created from template."
  echo ""
  echo "  Edit it to customise your permissions allowlist:"
  echo "  $SETTINGS_JSON"
else
  echo "✓ ~/.claude/settings.json already exists — leaving unchanged."
fi

echo ""
echo "Setup complete."
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/machine.json with your machine-specific paths"
echo "  2. Edit ~/.claude/settings.json to customise your allowlist"
echo "  3. Open Claude Code in any directory and type: setup"
echo "     Claude will walk you through the machine config interactively."
echo ""
