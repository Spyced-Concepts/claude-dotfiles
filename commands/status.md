# status

Check the health and sync state of your claude-dotfiles installation.

Read `dotfiles_dir` from `~/.claude/machine.json`.

Run: `bash <dotfiles_dir>/scripts/status.sh`

If `dotfiles_dir` is not set in machine.json, fall back to deriving the path
from the symlink target of `~/.claude/CLAUDE.md` — use `readlink ~/.claude/CLAUDE.md`
and go two levels up (parent of the scripts/ directory).

Show the full output to the user. If any issues are found, explain what they mean
in plain language and tell the user exactly what to run to fix each one.
