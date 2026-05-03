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

# ── CLAUDE.md symlink ────────────────────────────────────────────────────────

CLAUDE_MD_TARGET="$CLAUDE_DIR/CLAUDE.md"
CLAUDE_MD_SOURCE="$DOTFILES_DIR/CLAUDE.md"

if [ -L "$CLAUDE_MD_TARGET" ]; then
  echo "✓ ~/.claude/CLAUDE.md symlink exists — updating ..."
  ln -sf "$CLAUDE_MD_SOURCE" "$CLAUDE_MD_TARGET"
elif [ -f "$CLAUDE_MD_TARGET" ]; then
  echo "⚠️  ~/.claude/CLAUDE.md exists as a regular file."
  read -p "   Replace with symlink? (y/n): " replace
  if [ "$replace" = "y" ]; then
    cp "$CLAUDE_MD_TARGET" "$CLAUDE_MD_TARGET.backup"
    echo "   Backed up to ~/.claude/CLAUDE.md.backup"
    ln -sf "$CLAUDE_MD_SOURCE" "$CLAUDE_MD_TARGET"
    echo "✓ Symlink created."
  fi
else
  ln -sf "$CLAUDE_MD_SOURCE" "$CLAUDE_MD_TARGET"
  echo "✓ ~/.claude/CLAUDE.md symlinked."
fi

# ── Commands ─────────────────────────────────────────────────────────────────

echo ""
echo "── Custom slash commands ──────────────────────────────────────────────"
echo ""
echo "  claude-dotfiles includes built-in slash commands (/seclog,"
echo "  /monthly-check, /quarterly-review) that you can invoke directly"
echo "  in any Claude Code session."
echo ""
read -p "  Set up built-in commands? (y/n): " setup_commands

if [ "$setup_commands" = "y" ]; then
  COMMANDS_DIR="$CLAUDE_DIR/commands"

  # Always use a real directory — never a symlink to a directory.
  # This allows personal commands from a private config repo to be
  # added alongside (and override) public built-in commands.
  if [ -L "$COMMANDS_DIR" ]; then
    echo "  ⚠️  ~/.claude/commands is a symlink — converting to directory ..."
    rm "$COMMANDS_DIR"
  fi

  mkdir -p "$COMMANDS_DIR"

  # Symlink each public command file individually
  for cmd in "$DOTFILES_DIR/commands/"*.md; do
    [ -f "$cmd" ] || continue
    ln -sf "$cmd" "$COMMANDS_DIR/$(basename "$cmd")"
  done
  echo "  ✓ Built-in commands linked in ~/.claude/commands/"
  echo ""
  echo "  Commands available:"
  for cmd in "$DOTFILES_DIR/commands/"*.md; do
    name=$(basename "$cmd" .md)
    echo "    $(printf '%-22s' "$name") — $(head -1 "$cmd" | sed 's/^# *//')"
  done
  echo ""
  echo "  To add personal commands: symlink your own .md files into ~/.claude/commands/"
  echo "  Personal commands with the same name as a built-in will override it."
  echo "  The file content becomes the instruction Claude runs."
  echo ""
  echo "  ── Command prefix ────────────────────────────────────────"
  echo "  Commands are disabled by default. To invoke them, enable a"
  echo "  prefix in ~/.claude/machine.json. The default prefix is --"
  echo "  so you would type:  --daily  --health-check  --commands"
  echo ""
  echo "  You can use any prefix you like: --, !, >, cmd:, run:"
  echo "  Leave prefix empty to use command names directly (e.g. daily)"
  echo "  Note: the / prefix won't work — Claude Code intercepts it."
  echo ""
  read -p "  Enable command prefix now? (y/n): " enable_prefix
  if [ "$enable_prefix" = "y" ]; then
    read -p "  Prefix to use [--]: " chosen_prefix
    chosen_prefix="${chosen_prefix:---}"

    # Update machine.json with prefix settings
    if [ -f "$MACHINE_JSON" ] && command -v python3 &>/dev/null; then
      python3 - "$MACHINE_JSON" "$chosen_prefix" << 'PYEOF'
import json, sys
path, prefix = sys.argv[1], sys.argv[2]
with open(path) as f:
    c = json.load(f)
c["command_prefix_enabled"] = True
c["command_prefix"] = prefix
with open(path, "w") as f:
    json.dump(c, f, indent=2)
    f.write("\n")
PYEOF
      echo "  ✓ Command prefix set to: '${chosen_prefix}' — try ${chosen_prefix}commands"
    else
      echo "  ⚠️  Set manually in ~/.claude/machine.json:"
      echo "     \"command_prefix_enabled\": true,"
      echo "     \"command_prefix\": \"${chosen_prefix}\""
    fi
  else
    echo "  Enable later by setting command_prefix_enabled: true in machine.json"
  fi
fi

# ── machine.json ─────────────────────────────────────────────────────────────

echo ""
echo "── Machine configuration ──────────────────────────────────────────────"
echo ""

MACHINE_JSON="$CLAUDE_DIR/machine.json"

if [ -f "$MACHINE_JSON" ]; then
  echo "  ✓ ~/.claude/machine.json already exists — leaving unchanged."
  echo "    Edit it directly or delete it and re-run this script to reconfigure."
else
  echo "  Building your machine.json ..."
  echo ""

  read -p "  Machine name (e.g. macbook-pro, work-laptop): " machine_name
  machine_name="${machine_name:-my-machine}"

  # Detect OS
  case "$(uname -s)" in
    Darwin) detected_os="macos" ;;
    Linux)  detected_os="linux" ;;
    MINGW*|MSYS*|CYGWIN*) detected_os="windows" ;;
    *) detected_os="linux" ;;
  esac
  read -p "  OS [$detected_os]: " machine_os
  machine_os="${machine_os:-$detected_os}"

  echo ""
  echo "  ── Projects ──────────────────────────────────────────────────────"
  echo "  Your projects folder is where code lives — git repositories,"
  echo "  source files, compiled artefacts, and build outputs."
  echo ""
  read -p "  Projects folder [$HOME/Projects]: " project_root
  project_root="${project_root:-$HOME/Projects}"

  echo ""
  echo "  ── Knowledge directories ─────────────────────────────────────────"
  echo "  Knowledge directories are where your thinking lives — notes, docs,"
  echo "  todos, tasks, plans, research, and reference material. Claude reads"
  echo "  these to understand your context. This can be a single parent folder"
  echo "  or individual directories — however you organise your work."
  echo ""

  knowledge_root=""
  knowledge_dirs_json=""

  read -p "  Do you have a parent folder containing all your knowledge/docs? (y/n): " has_root
  if [ "$has_root" = "y" ]; then
    read -p "  Path to knowledge parent folder [$HOME]: " knowledge_root
    knowledge_root="${knowledge_root:-$HOME}"

    if [ -d "$knowledge_root" ]; then
      echo ""
      echo "  Found these subdirectories in $knowledge_root:"
      subdirs=()
      while IFS= read -r -d '' dir; do
        name=$(basename "$dir")
        # Skip hidden dirs and common non-knowledge dirs
        case "$name" in
          .*|node_modules|__pycache__|.git|Desktop|Downloads|Library|Applications) continue ;;
        esac
        subdirs+=("$name")
        echo "    - $name"
      done < <(find "$knowledge_root" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z)

      echo ""
      read -p "  Use all of these as knowledge directories? (y/n/select): " use_all

      if [ "$use_all" = "y" ]; then
        for name in "${subdirs[@]}"; do
          entry="\"$name\": \"$knowledge_root/$name\""
          knowledge_dirs_json="${knowledge_dirs_json:+$knowledge_dirs_json, }$entry"
        done
      elif [ "$use_all" = "select" ]; then
        echo "  Enter the names you want (space-separated):"
        read -p "  > " selected
        for name in $selected; do
          if [ -d "$knowledge_root/$name" ]; then
            entry="\"$name\": \"$knowledge_root/$name\""
            knowledge_dirs_json="${knowledge_dirs_json:+$knowledge_dirs_json, }$entry"
          else
            echo "  ⚠️  $knowledge_root/$name not found — skipping"
          fi
        done
      fi
    else
      echo "  ⚠️  Directory not found: $knowledge_root"
    fi
  fi

  # Allow adding individual dirs on top
  echo ""
  read -p "  Add individual knowledge directories? (y/n): " add_individual
  while [ "$add_individual" = "y" ]; do
    read -p "  Name (used as variable, e.g. 'notes'): " kname
    read -p "  Path: " kpath
    if [ -n "$kname" ] && [ -n "$kpath" ]; then
      entry="\"$kname\": \"$kpath\""
      knowledge_dirs_json="${knowledge_dirs_json:+$knowledge_dirs_json, }$entry"
    fi
    read -p "  Add another? (y/n): " add_individual
  done

  # Build knowledge_root line
  knowledge_root_line=""
  if [ -n "$knowledge_root" ]; then
    knowledge_root_line="
  \"knowledge_root\": \"$knowledge_root\","
  fi

  # Write machine.json
  cat > "$MACHINE_JSON" << JSONEOF
{
  "name": "$machine_name",
  "os": "$machine_os",
  "home": "$HOME",$knowledge_root_line
  "knowledge_dirs": {
    $knowledge_dirs_json
  },
  "project_root": "$project_root"
}
JSONEOF

  echo ""
  echo "  ✓ ~/.claude/machine.json created."
  echo ""
  cat "$MACHINE_JSON"
fi

# ── settings.json ────────────────────────────────────────────────────────────

echo ""
SETTINGS_JSON="$CLAUDE_DIR/settings.json"
if [ ! -f "$SETTINGS_JSON" ]; then
  cp "$DOTFILES_DIR/settings.json.template" "$SETTINGS_JSON"
  echo "✓ ~/.claude/settings.json created from template."
  echo "  Edit it to customise your permissions allowlist: $SETTINGS_JSON"
else
  echo "✓ ~/.claude/settings.json already exists — leaving unchanged."
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════"
echo "  Setup complete."
echo "════════════════════════════════════════"
echo ""
echo "  Next steps:"
echo "  1. Review ~/.claude/machine.json — edit paths if needed"
echo "  2. Review ~/.claude/settings.json — add any tool permissions"
echo "  3. Open Claude Code in any directory"
if [ "$setup_commands" = "y" ]; then
echo "  4. Try a built-in command: /seclog"
fi
echo ""
