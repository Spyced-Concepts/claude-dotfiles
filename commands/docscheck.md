# docscheck

Run the documentation quality check for claude-dotfiles.

Read `dotfiles_dir` from `~/.claude/machine.json`.

Run: `bash <dotfiles_dir>/scripts/check-docs.sh`

Show the full output to the user. If any checks fail, explain what each failure means and tell the user exactly how to fix it.

If all checks pass, confirm that the documentation meets project standards and is ready for a PR.
