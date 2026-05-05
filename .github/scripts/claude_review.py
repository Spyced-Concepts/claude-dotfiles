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

if not os.path.exists(diff_path):
    print(f"::error::Diff file not found at {diff_path}")
    sys.exit(1)

with open(diff_path, encoding="utf-8") as f:
    diff = f.read()
pr_title  = os.environ.get("PR_TITLE", "")
pr_body   = os.environ.get("PR_BODY", "")
pr_number = os.environ.get("PR_NUMBER", "")
# Provider configuration — set AI_API_KEY (secret) and AI_MODEL (variable)
# in your GitHub repository settings. Default provider is Anthropic Claude.
# To use a different provider, adapt the API call below to match its format.
api_key = os.environ.get("AI_API_KEY", "")
model   = os.environ.get("AI_MODEL", "")

if not api_key:
    print("::error::AI_API_KEY secret not configured in repository secrets")
    sys.exit(1)
if not model:
    print("::error::AI_MODEL variable not configured in repository variables")
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
    "1. **Merge conflicts** — check the diff for conflict markers (<<<<<<, =======, "
    ">>>>>>>). If any are present, flag immediately as a blocker — the PR cannot be "
    "merged until conflicts are resolved.\n"
    "2. **Correctness** — does the code do what it claims? Are edge cases handled?\n"
    "3. **Cross-platform** — will it work on macOS, Linux, and Windows Git Bash?\n"
    "4. **Bash quality** — set -euo pipefail, quoting, portability, no bashisms\n"
    "5. **Security** — no hardcoded secrets, no path injection, no unsafe variable "
    "expansion, no insecure temp file usage, inputs validated at boundaries\n"
    "6. **Code quality** — no magic numbers or magic strings (named constants for "
    "non-obvious values), no code smells (duplicated logic, deep nesting, overly long "
    "functions), correct approach for the problem\n"
    "7. **Dependencies** — no unnecessary community modules; bash builtins and Python "
    "stdlib only; flag any import that is not from the Python standard library\n"
    "8. **Documentation** — --help updated, man page present, check-docs standards met\n"
    "9. **UAT coverage** — does the PR reference relevant UAT-NNN test case IDs?\n"
    "10. **PR scope** — single concern? or should it be split?\n\n"
    "End your review with exactly one of:\n"
    "APPROVE\n"
    "APPROVE WITH NOTES\n"
    "REQUEST CHANGES"
)


payload = {
    "model": model,
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
        data = json.loads(resp.read().decode("utf-8"))
    content = data.get("content", [])
    if not content or content[0].get("type") != "text":
        print("::error::Unexpected API response structure")
        sys.exit(1)
    review = content[0]["text"]
except urllib.error.HTTPError as e:
    print(f"::error::Claude API HTTP error {e.code}: {e.read().decode()}")
    sys.exit(1)
except urllib.error.URLError as e:
    print(f"::error::Network error reaching Claude API: {e.reason}")
    sys.exit(1)

delimiter = "CLAUDE_REVIEW_EOF"
with open(os.environ["GITHUB_OUTPUT"], "a") as out:
    out.write(f"review<<{delimiter}\n{review}\n{delimiter}\n")

print("Review complete.")
