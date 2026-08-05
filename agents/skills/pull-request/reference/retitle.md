# Retitle

Update an existing PR’s **title and description** only. No commit, push, or code changes unless the user explicitly asks.

Load [`pr-narrative.md`](pr-narrative.md) for title, body template, voice, Review map gates, and tests-first ordering.

## Triggers

Use this branch when the user wants to refresh PR narrative: update title, update description, update PR title/desc, refresh PR summary, `/pull-request update title+desc`, or ambiguous “update the PR” with no code or review-feedback ask.

## Workflow

1. Resolve the PR (`gh pr view` / URL / current branch).
2. Detect base branch; rebuild narrative from full `base...HEAD`, **not** the latest commit alone:
   - `git log --oneline <base>...HEAD`
   - `git diff --stat <base>...HEAD`
   - `git diff <base>...HEAD` (enough to name concrete behaviors; do not invent)
3. Classify size with the gates in `pr-narrative.md` (>400 lines and/or >15 files → large).
4. Draft title + body per `pr-narrative.md` (tests-first Review map).
5. Apply with `gh pr edit`:

```bash
gh pr edit <number-or-url> --title "..." --body "$(cat <<'EOF'
...
EOF
)"
```

6. Confirm with `gh pr view` (title + body). Report the new title and a short note on Review map choice (large vs small; tests-first vs “No test delta”).

## Safety

- Edit-only: `gh pr edit` for title/body.
- Do not amend commits, force-push, or stage files as part of this branch.
- If the PR does not exist yet, stop and route to **open** (or ask) instead of inventing a PR.

## Output

Report:

- PR URL / number
- new title
- whether Review map was full, one-liner, or “No test delta …”
- size classification (lines + file count vs gates)
