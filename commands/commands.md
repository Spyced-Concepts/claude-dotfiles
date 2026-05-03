# List Available Commands

List all custom commands available in this Claude Code session.

Run:
```bash
ls ~/.claude/commands/*.md 2>/dev/null
```

For each `.md` file found, extract and display the first heading (the command name) and the first non-heading line (the description).

Present as a clean table. Show the command name and your configured prefix so the user knows exactly how to invoke each one:

| Invoke as | Command | Description |
|---|---|---|
| {prefix}commandname | commandname | first line description |

Read the configured prefix from `~/.claude/machine.json` (`command_prefix` field) to show the correct invocation. If no prefix is configured, show the bare command name.

If no commands directory exists or it is empty, say so and point the user to the claude-dotfiles setup guide at https://github.com/Spyced-Concepts/claude-dotfiles
