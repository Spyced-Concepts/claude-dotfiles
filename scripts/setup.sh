#!/usr/bin/env bash
# claude-dotfiles setup script
# Run once on a new machine to deploy your Claude Code configuration.
# https://github.com/Spyced-Concepts/claude-dotfiles

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

# ── Help ──────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF

Usage: bash $(basename "$0") [OPTIONS]

Run guided first-time setup of claude-dotfiles on this machine.

Options:
  -h, --help   Show this help message and exit

What this does:
  1. Symlinks CLAUDE.md to ~/.claude/CLAUDE.md
  2. Sets up built-in commands in ~/.claude/commands/
  3. Creates or updates ~/.claude/machine.json
  4. Creates or updates ~/.claude/settings.json
  5. Connects your personal private config repo (optional)

Re-running is safe — existing config is preserved and updated in place.

Man page: man claude-dotfiles-setup
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

# Detect GitHub CLI — optional; enables automated repo creation
GH_AVAILABLE=false
if command -v gh &>/dev/null; then
  GH_AVAILABLE=true
  echo "✓ GitHub CLI (gh) found — automated repo setup available"
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
echo "── Custom commands ────────────────────────────────────────────────────"
echo ""
echo "  claude-dotfiles includes built-in commands (daily, todo, week-review,"
echo "  journal, health-check, update) that Claude runs when you type a"
echo "  configured prefix followed by the command name."
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
    echo "  ✓ Prefix '${chosen_prefix}' noted — will be saved to machine.json after config."
  else
    chosen_prefix=""
    echo "  Enable later by setting command_prefix_enabled: true in machine.json"
  fi
fi

# ── machine.json ─────────────────────────────────────────────────────────────

echo ""
echo "── Machine configuration ──────────────────────────────────────────────"
echo ""

MACHINE_JSON="$CLAUDE_DIR/machine.json"

_read_json_field() {
  python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get(sys.argv[2], ''))
except: print('')
" "$1" "$2" 2>/dev/null
}

if [ -f "$MACHINE_JSON" ]; then
  echo "  ~/.claude/machine.json exists. Update fields below."
  echo "  Press Enter to keep the current value shown in [brackets]."
  echo ""

  cur_name=$(_read_json_field "$MACHINE_JSON" "name")
  cur_os=$(_read_json_field "$MACHINE_JSON" "os")
  cur_home=$(_read_json_field "$MACHINE_JSON" "home")
  cur_project=$(_read_json_field "$MACHINE_JSON" "project_root")
  cur_kr=$(_read_json_field "$MACHINE_JSON" "knowledge_root")

  read -p "  Machine name [${cur_name:-my-machine}]: " machine_name
  machine_name="${machine_name:-${cur_name:-my-machine}}"

  read -p "  OS [${cur_os:-linux}]: " machine_os
  machine_os="${machine_os:-${cur_os:-linux}}"

  read -p "  Home directory [${cur_home:-$HOME}]: " machine_home
  machine_home="${machine_home:-${cur_home:-$HOME}}"

  read -p "  Projects folder [${cur_project:-$HOME/Projects}]: " project_root
  project_root="${project_root:-${cur_project:-$HOME/Projects}}"

  read -p "  Knowledge root [${cur_kr:-}]: " knowledge_root
  knowledge_root="${knowledge_root:-${cur_kr}}"

  # Preserve existing knowledge_dirs; update top-level scalar fields only
  python3 - "$MACHINE_JSON" "$machine_name" "$machine_os" "$machine_home" "$project_root" "$knowledge_root" "$DOTFILES_DIR" << 'PYEOF'
import json, sys
path, name, os_, home, proj, kr, dotfiles = sys.argv[1:8]
with open(path) as f:
    c = json.load(f)
c["name"] = name
c["os"] = os_
c["home"] = home
if proj: c["project_root"] = proj
if kr: c["knowledge_root"] = kr
elif "knowledge_root" in c and not kr:
    pass  # keep existing if user left blank
if dotfiles: c["dotfiles_dir"] = dotfiles
with open(path, "w") as f:
    json.dump(c, f, indent=2)
    f.write("\n")
PYEOF

  echo ""
  echo "  ✓ ~/.claude/machine.json updated."
  echo ""
  cat "$MACHINE_JSON"
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
  "project_root": "$project_root",
  "dotfiles_dir": "$DOTFILES_DIR"
}
JSONEOF

  echo ""
  echo "  ✓ ~/.claude/machine.json created."
  echo ""
  cat "$MACHINE_JSON"
fi

# ── Apply command prefix to machine.json ─────────────────────────────────────

if [ -n "$chosen_prefix" ] && [ -f "$MACHINE_JSON" ] && command -v python3 &>/dev/null; then
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
  echo "✓ Command prefix '${chosen_prefix}' saved to machine.json"
elif [ -n "$chosen_prefix" ]; then
  echo "⚠️  Could not save prefix automatically. Add to ~/.claude/machine.json:"
  echo "   \"command_prefix_enabled\": true,"
  echo "   \"command_prefix\": \"${chosen_prefix}\""
fi

# ── settings.json ────────────────────────────────────────────────────────────

echo ""
SETTINGS_JSON="$CLAUDE_DIR/settings.json"
if [ ! -f "$SETTINGS_JSON" ]; then
  cp "$DOTFILES_DIR/settings.json.template" "$SETTINGS_JSON"
  echo "✓ ~/.claude/settings.json created from template."
  echo "  Edit it to customise your permissions allowlist: $SETTINGS_JSON"
else
  echo "✓ ~/.claude/settings.json exists."
  echo ""
  echo "  Current allowlist entries:"
  python3 -c "
import json
try:
    c = json.load(open('$SETTINGS_JSON'))
    for e in c.get('permissions', {}).get('allow', []):
        print(f'    {e}')
except: print('    (could not read)')
" 2>/dev/null
  echo ""
  read -p "  Add a new allowlist entry? (paste entry or press Enter to skip): " new_entry
  while [ -n "$new_entry" ]; do
    python3 - "$SETTINGS_JSON" "$new_entry" << 'PYEOF'
import json, sys
path, entry = sys.argv[1], sys.argv[2]
with open(path) as f:
    c = json.load(f)
allows = c.setdefault("permissions", {}).setdefault("allow", [])
if entry not in allows:
    allows.append(entry)
with open(path, "w") as f:
    json.dump(c, f, indent=2)
    f.write("\n")
PYEOF
    echo "  ✓ Added: $new_entry"
    read -p "  Add another? (paste entry or press Enter to skip): " new_entry
  done
fi

# ── Personal config repo ─────────────────────────────────────────────────────
#
# Your private config repo holds YOUR content: your identity, personal commands,
# and any customisations to CLAUDE.md. It is completely separate from this
# public tool — clone claude-dotfiles cleanly; keep your own config in your own
# private repo.
#
# Why a separate repo? Forks of claude-dotfiles invite accidental PRs of personal
# data into the public repo. Keeping them separate is the right architecture.

echo ""
echo "── Personal config repo ───────────────────────────────────────────────"
echo ""
echo "  Your identity, custom commands, and personal Claude Code instructions"
echo "  belong in YOUR OWN private GitHub repo — separate from this tool."
echo "  It is what keeps your configuration in sync across all your machines."
echo ""

# Check if already configured in machine.json
PERSONAL_CONFIG_DIR=""
if [ -f "$MACHINE_JSON" ] && command -v python3 &>/dev/null; then
  PERSONAL_CONFIG_DIR=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('personal_config_dir', ''))
except: print('')
" "$MACHINE_JSON" 2>/dev/null)
fi

if [ -n "$PERSONAL_CONFIG_DIR" ] && [ -d "$PERSONAL_CONFIG_DIR/.git" ]; then
  echo "  ✓ Personal config already linked: $PERSONAL_CONFIG_DIR"
  echo "    Pulling latest changes ..."
  git -C "$PERSONAL_CONFIG_DIR" pull --quiet 2>/dev/null \
    && echo "    ✓ Up to date" \
    || echo "    ⚠️  Could not pull — check manually"
else
  read -p "  Have you already set up a personal config repo? (y/n/s to skip): " has_config_repo

  case "$has_config_repo" in

    y|Y)
      echo ""
      echo "  Paste the clone URL for your private repo."
      echo "  SSH example:   git@github.com:you/claude-config.git"
      echo "  HTTPS example: https://github.com/you/claude-config.git"
      echo ""
      read -p "  Clone URL: " config_clone_url
      if [ -n "$config_clone_url" ]; then
        PERSONAL_CONFIG_DIR="$HOME/.local/share/claude-config"
        mkdir -p "$(dirname "$PERSONAL_CONFIG_DIR")"
        if git clone "$config_clone_url" "$PERSONAL_CONFIG_DIR" 2>/dev/null; then
          echo "  ✓ Cloned to $PERSONAL_CONFIG_DIR"
        else
          echo "  ⚠️  Clone failed. Check the URL and try again."
          PERSONAL_CONFIG_DIR=""
        fi
      fi
      ;;

    n|N)
      echo ""
      if $GH_AVAILABLE; then
        echo "  The GitHub CLI is installed — we can create your private repo now."
        echo ""
        read -p "  Repo name [claude-config]: " repo_name
        repo_name="${repo_name:-claude-config}"
        PERSONAL_CONFIG_DIR="$HOME/.local/share/$repo_name"

        if [ -d "$PERSONAL_CONFIG_DIR/.git" ]; then
          echo "  ✓ $PERSONAL_CONFIG_DIR already exists — using it."
        else
          mkdir -p "$HOME/.local/share"
          # gh repo create --clone puts the repo in the cwd
          _prev_dir="$PWD"
          cd "$HOME/.local/share"
          if gh repo create "$repo_name" --private \
              --description "Personal Claude Code configuration" \
              --clone 2>/dev/null; then
            echo "  ✓ Created and cloned: $PERSONAL_CONFIG_DIR"
          else
            echo "  ⚠️  Could not create repo. Try running: gh auth login"
            echo "     Then re-run setup."
            PERSONAL_CONFIG_DIR=""
          fi
          cd "$_prev_dir"
        fi

        # Scaffold initial files if the repo is empty
        if [ -n "$PERSONAL_CONFIG_DIR" ] && [ -d "$PERSONAL_CONFIG_DIR" ] \
            && [ ! -f "$PERSONAL_CONFIG_DIR/CLAUDE.md" ]; then
          mkdir -p "$PERSONAL_CONFIG_DIR/commands"

          # Scaffold CLAUDE.md from the public template
          cp "$DOTFILES_DIR/CLAUDE.md" "$PERSONAL_CONFIG_DIR/CLAUDE.md"

          cat > "$PERSONAL_CONFIG_DIR/.gitignore" << 'GIEOF'
*.local
GIEOF

          cat > "$PERSONAL_CONFIG_DIR/README.md" << 'REEOF'
# Personal Claude Code Config

My private Claude Code configuration — built on [claude-dotfiles](https://github.com/Spyced-Concepts/claude-dotfiles).

Contains my personal CLAUDE.md, custom commands, and configuration.
REEOF

          cd "$PERSONAL_CONFIG_DIR"
          git add .
          git commit -m "Initial personal config scaffold" --quiet
          git push --quiet
          cd "$_prev_dir"
          echo "  ✓ Scaffolded CLAUDE.md template, commands/, and pushed initial commit"
          echo ""
          echo "  ⚠️  IMPORTANT: Edit your CLAUDE.md to fill in your real identity."
          echo "     Open: $PERSONAL_CONFIG_DIR/CLAUDE.md"
          echo "     Replace [Your Name], [Your Role], [Your Location] with your details."
        fi
      else
        # No gh CLI — show manual options
        echo "  The GitHub CLI (gh) is not installed. Here are your options:"
        echo ""
        echo "  ┌─ Option A: Install gh, then re-run setup (recommended) ──────────"
        echo "  │  Install from: https://cli.github.com/"
        echo "  │  After installing: bash $DOTFILES_DIR/scripts/setup.sh"
        echo "  │"
        echo "  ├─ Option B: Create the repo on GitHub, then connect it ───────────"
        echo "  │  1. Go to: https://github.com/new"
        echo "  │  2. Name it 'claude-config', set it to PRIVATE, click Create"
        echo "  │  3. Copy the clone URL (SSH or HTTPS)"
        echo "  │  4. Re-run setup — you'll be prompted to paste the URL"
        echo "  │"
        echo "  └─ Option C: Skip for now ─────────────────────────────────────────"
        echo "     Open Claude Code and type: setup"
        echo "     Claude will walk you through creating your private config."
        echo ""
        read -p "  Do you have a clone URL ready right now? (paste URL or Enter to skip): " config_clone_url
        if [ -n "$config_clone_url" ]; then
          PERSONAL_CONFIG_DIR="$HOME/.local/share/claude-config"
          mkdir -p "$(dirname "$PERSONAL_CONFIG_DIR")"
          if git clone "$config_clone_url" "$PERSONAL_CONFIG_DIR" 2>/dev/null; then
            echo "  ✓ Cloned to $PERSONAL_CONFIG_DIR"
          else
            echo "  ⚠️  Clone failed. Check the URL and try again."
            PERSONAL_CONFIG_DIR=""
          fi
        fi
      fi
      ;;

    *)
      echo "  Skipping. To set this up later:"
      echo "  - Open Claude Code and type: setup"
      echo "  - Claude will walk you through it interactively."
      ;;

  esac
fi

# Wire up personal config if we have a dir
if [ -n "$PERSONAL_CONFIG_DIR" ] && [ -d "$PERSONAL_CONFIG_DIR" ]; then

  # Prefer private CLAUDE.md over the public template
  if [ -f "$PERSONAL_CONFIG_DIR/CLAUDE.md" ]; then
    ln -sf "$PERSONAL_CONFIG_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    echo "  ✓ ~/.claude/CLAUDE.md → your personal CLAUDE.md"
  fi

  # Symlink personal commands — these override public built-ins of the same name
  if [ -d "$PERSONAL_CONFIG_DIR/commands" ]; then
    COMMANDS_DIR_P="$CLAUDE_DIR/commands"
    mkdir -p "$COMMANDS_DIR_P"
    linked_personal=0
    for cmd in "$PERSONAL_CONFIG_DIR/commands/"*.md; do
      [ -f "$cmd" ] || continue
      ln -sf "$cmd" "$COMMANDS_DIR_P/$(basename "$cmd")"
      linked_personal=$((linked_personal + 1))
    done
    [ $linked_personal -gt 0 ] \
      && echo "  ✓ $linked_personal personal command(s) linked (override built-ins)"
  fi

  # Save personal_config_dir to machine.json
  if [ -f "$MACHINE_JSON" ] && command -v python3 &>/dev/null; then
    python3 - "$MACHINE_JSON" "$PERSONAL_CONFIG_DIR" << 'PYEOF'
import json, sys
path, d = sys.argv[1], sys.argv[2]
with open(path) as f:
    c = json.load(f)
c["personal_config_dir"] = d
with open(path, "w") as f:
    json.dump(c, f, indent=2)
    f.write("\n")
PYEOF
    echo "  ✓ Saved personal_config_dir to machine.json"
  fi
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════"
if [ -n "$PERSONAL_CONFIG_DIR" ] && [ -d "$PERSONAL_CONFIG_DIR" ]; then
  echo "  Setup complete."
else
  echo "  Setup partially complete."
  echo ""
  echo "  ⚠️  Your personal config repo is not connected."
  echo "     Setup is complete when your identity, custom commands,"
  echo "     and CLAUDE.md are in a private GitHub repo linked here."
  echo ""
  echo "     Re-run setup at any time to connect it:"
  echo "       bash $DOTFILES_DIR/scripts/setup.sh"
fi
echo "════════════════════════════════════════"
echo ""
echo "  Next steps:"
echo "  1. Review ~/.claude/machine.json — edit paths if needed"
echo "  2. Review ~/.claude/settings.json — add any tool permissions"
echo "  3. Open Claude Code in any directory"
if [ "$setup_commands" = "y" ] && [ -n "$chosen_prefix" ]; then
  echo "  4. Try a command: type ${chosen_prefix}commands to list all available commands"
elif [ "$setup_commands" = "y" ]; then
  echo "  4. Enable commands: set command_prefix_enabled: true in ~/.claude/machine.json"
fi
echo ""
echo "  Check status at any time:"
echo "    bash $DOTFILES_DIR/scripts/status.sh"
echo ""
