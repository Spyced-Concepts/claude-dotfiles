# uninstall

Uninstall claude-dotfiles from this machine and return to a clean state.

Read `dotfiles_dir` from `~/.claude/machine.json`.

Explain to the user what uninstall does before running it:
- Removes symlinks from ~/.claude/
- Offers to restore a plain local CLAUDE.md
- Offers to remove machine.json and settings.json
- Offers to delete the repos (with strong confirmation)

Ask the user to confirm they want to proceed, then run:
`bash <dotfiles_dir>/scripts/uninstall.sh`

Show the output and guide the user through any prompts. After completion,
confirm what was removed and remind them how to reinstall if needed:
`curl -fsSL https://raw.githubusercontent.com/Spyced-Concepts/claude-dotfiles/main/install.sh | bash`
