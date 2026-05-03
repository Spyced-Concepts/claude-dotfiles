#!/usr/bin/env bash
# claude-dotfiles installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Spyced-Concepts/claude-dotfiles/main/install.sh | bash
#
# What this does:
#   1. Checks that Claude Code is installed
#   2. Downloads claude-dotfiles to ~/.local/share/claude-dotfiles
#   3. Runs the guided setup
#   4. Tells you what to do next

set -e

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${BOLD}$*${RESET}"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $*"; }
fail()    { echo -e "${RED}✗${RESET}  $*"; exit 1; }

# ── Install location ──────────────────────────────────────────────────────────

# Use XDG Base Directory if available, otherwise ~/claude-dotfiles
if [ -n "$XDG_DATA_HOME" ]; then
  INSTALL_DIR="$XDG_DATA_HOME/claude-dotfiles"
elif [ -d "$HOME/.local/share" ]; then
  INSTALL_DIR="$HOME/.local/share/claude-dotfiles"
else
  INSTALL_DIR="$HOME/claude-dotfiles"
fi

echo ""
echo -e "${BOLD}claude-dotfiles${RESET} — Claude Code configuration framework"
echo "=================================================="
echo ""

# ── Check Claude Code ─────────────────────────────────────────────────────────

if ! command -v claude &>/dev/null; then
  fail "Claude Code is not installed.

  Install it first:
    npm install -g @anthropic-ai/claude-code

  Then re-run this installer."
fi
success "Claude Code found: $(claude --version 2>/dev/null | head -1)"

# ── Check git ─────────────────────────────────────────────────────────────────

if ! command -v git &>/dev/null; then
  fail "git is not installed.

  macOS:   xcode-select --install
  Ubuntu:  sudo apt install git
  Windows: https://git-scm.com/download/win

  Then re-run this installer."
fi
success "git found"

# ── Download claude-dotfiles ──────────────────────────────────────────────────

echo ""
info "Installing claude-dotfiles to $INSTALL_DIR ..."
echo ""

if [ -d "$INSTALL_DIR/.git" ]; then
  warn "claude-dotfiles already installed — updating ..."
  git -C "$INSTALL_DIR" pull --quiet
  success "Updated to latest version"
else
  git clone --quiet https://github.com/Spyced-Concepts/claude-dotfiles.git "$INSTALL_DIR"
  success "Downloaded"
fi

# ── Run setup ─────────────────────────────────────────────────────────────────

echo ""
info "Running setup ..."
echo ""
bash "$INSTALL_DIR/scripts/setup.sh"

# ── Add to PATH if needed ─────────────────────────────────────────────────────

# Add an update alias to shell config if not already there
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

UPDATE_ALIAS="alias claude-update='bash ${INSTALL_DIR}/scripts/update.sh'"
if [ -n "$SHELL_RC" ] && ! grep -qF "claude-update" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# claude-dotfiles" >> "$SHELL_RC"
  echo "$UPDATE_ALIAS" >> "$SHELL_RC"
  success "Added 'claude-update' command to $SHELL_RC"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "=================================================="
echo -e "${GREEN}${BOLD}All done!${RESET}"
echo ""
echo "  Claude Code is now configured on this machine."
echo ""
echo "  ${BOLD}What to do next:${RESET}"
echo "  Open Claude Code in any folder:"
echo ""
echo "    claude"
echo ""
echo "  Then just start a conversation. If this is your first time,"
echo "  Claude will help you get set up — no technical knowledge needed."
echo ""
echo "  To update claude-dotfiles in future:"
echo "    claude-update"
echo ""
echo "  Learn more: https://github.com/Spyced-Concepts/claude-dotfiles"
echo ""
