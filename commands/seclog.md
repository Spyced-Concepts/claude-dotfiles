# Security Log Review

Run a security incident review. Find active security incidents tracked in your knowledge directories — look for files named `security-incidents`, `incidents`, or similar. 

Present active (non-closed) incidents as a prioritised table sorted by:
1. Severity — Critical first, then High, Moderate, Low, Info
2. Within same severity: days open descending (oldest first)
3. Tie-break: fewest SLA days remaining first

**Table columns:** ID | Severity | Title | Opened | Days open | SLA (days left · deadline) | Planned action date | Assignee | Status

Calculate days open and SLA days remaining using today's date (run `date +%Y-%m-%d`).

Follow the table with a single brief plain-text summary — one or two sentences. Highlight: any items due today, any overdue items, anything needing immediate action before other work proceeds.

If any active incident is missing a resolution plan, hard date, or planned action date — flag those specific items after the summary and ask for the missing information before proceeding.

---
*Customise this command for your setup by editing `~/.claude/commands/seclog.md`.*
*Point it at your specific security incidents file path for a more precise result.*
