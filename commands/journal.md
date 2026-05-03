# Journal Entry

Create a dated working notes entry for today's session.

First, get today's date:

```bash
date +%Y-%m-%d
```

Then ask: **"What would you like to capture in today's journal entry?"**

Wait for a response. Then:

1. Find the most appropriate knowledge directory for journal or working notes (look for folders named `journal`, `notes`, `working-notes`, `log`, or similar)
2. Create a new file named `YYYY-MM-DD.md` (using today's date) in that folder, or append to an existing file for today if one already exists
3. Write the entry with a clear timestamp heading

If no obvious journal directory exists, ask which knowledge directory to use before writing.

Keep the format simple — a heading with the date, the content as written, no extra structure imposed unless the user asks for it.

---
*Customise this command for your setup by editing `~/.claude/commands/journal.md`*
