"""
Claude PR review script — called by claude-review.yml GitHub Action.
Reads the PR diff, calls the Claude API, writes the review to GITHUB_OUTPUT.
"""
import json
import os
import sys
import urllib.request
import urllib.error

runner_temp = os.environ.get("RUNNER_TEMP", "/tmp")
diff_path   = os.path.join(runner_temp, "pr_diff.txt")
diff        = open(diff_path).read()
pr_title  = os.environ.get("PR_TITLE", "")
pr_body   = os.environ.get("PR_BODY", "")
pr_number = os.environ.get("PR_NUMBER", "")
api_key   = os.environ.get("ANTHROPIC_API_KEY", "")

if not api_key:
    print("::error::ANTHROPIC_API_KEY secret not configured")
    sys.exit(1)

system = (
    "You are reviewing a pull request for claude-dotfiles — a personal "
    "configuration framework for Claude Code (Anthropic's AI CLI). "
    "The project uses bash scripts targeting macOS, Linux, and Windows (Git Bash). "
    "All documentation (--help, man pages, UAT.md) is enforced by check-docs.sh. "
    "Review concisely. Flag blockers clearly. Be direct."
)

body_excerpt = pr_body[:500] if pr_body else "(no description)"
diff_block   = diff.strip() if diff.strip() else "(empty diff)"

user = (
    f"PR #{pr_number}: {pr_title}\n\n"
    f"{body_excerpt}\n\n"
    "Diff:\n"
    "```diff\n"
    f"{diff_block}\n"
    "```\n\n"
    "Review against these criteria:\n"
    "1. **Correctness** — does the code do what it claims? Are edge cases handled?\n"
    "2. **Cross-platform** — will it work on macOS, Linux, and Windows Git Bash?\n"
    "3. **Bash quality** — set -euo pipefail, quoting, portability, no bashisms\n"
    "4. **Security** — no hardcoded secrets, no path injection, no unsafe variable "
    "expansion, no insecure temp file usage, inputs validated at boundaries\n"
    "5. **Code quality** — no magic numbers or strings (use named constants), no code "
    "smells (duplicated logic, deep nesting, overly long functions), correct approach "
    "for the problem\n"
    "6. **Dependencies** — no unnecessary community modules; bash builtins and Python "
    "stdlib only; flag any import that is not from the Python standard library\n"
    "7. **Documentation** — --help updated, man page present, check-docs standards met\n"
    "8. **UAT coverage** — does the PR reference relevant UAT-NNN test case IDs?\n"
    "9. **PR scope** — single concern? or should it be split?\n\n"
    "End your review with exactly one of:\n"
    "APPROVE\n"
    "APPROVE WITH NOTES\n"
    "REQUEST CHANGES"
)

payload = {
    "model": "claude-sonnet-4-6",
    "max_tokens": 1024,
    "system": [{"type": "text", "text": system, "cache_control": {"type": "ephemeral"}}],
    "messages": [{"role": "user", "content": user}],
}

req = urllib.request.Request(
    "https://api.anthropic.com/v1/messages",
    data=json.dumps(payload).encode(),
    headers={
        "x-api-key": api_key,
        "anthropic-version": "2023-06-01",
        "anthropic-beta": "prompt-caching-2024-07-31",
        "content-type": "application/json",
    },
    method="POST",
)

try:
    with urllib.request.urlopen(req) as resp:
        data = json.load(resp)
        review = data["content"][0]["text"]
except urllib.error.HTTPError as e:
    err_body = e.read().decode()
    print(f"::error::Claude API error {e.code}: {err_body}")
    sys.exit(1)

delimiter = "CLAUDE_REVIEW_EOF"
with open(os.environ["GITHUB_OUTPUT"], "a") as out:
    out.write(f"review<<{delimiter}\n{review}\n{delimiter}\n")

print("Review complete.")
