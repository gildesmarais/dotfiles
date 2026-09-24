# Retitle

Edit an existing PR's title + body only — no commit, amend, stage, push, or force-push unless explicitly asked. No PR yet → route to **open** (or ask). Standard: [`pr-narrative.md`](pr-narrative.md).

## Sequence

1. Resolve PR (URL / number / current branch) and base.
2. Rebuild from full `base...HEAD`, not the latest commit: `git log --oneline <base>...HEAD`, `git diff --stat <base>...HEAD`, `git diff <base>...HEAD` (enough to name concrete behaviors).
3. Size-classify per `pr-narrative.md` gates; draft title + body (tests-first Review map).
4. Apply and confirm:

```bash
gh pr edit <number-or-url> --title "..." --body "$(cat <<'EOF'
...
EOF
)"
gh pr view <number-or-url> --json title,body
```

## Output

PR URL, new title, size (lines + files vs gates), Review map form (full / one-liner / "No test delta …").
