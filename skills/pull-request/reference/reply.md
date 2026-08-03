# Reply

Respond on existing GitHub review threads without introducing new findings or changing code.

Use when the user explicitly wants reply-only: "just reply", "draft responses", "respond on GitHub".

## Workflow

### 1. Discover PR

- `git branch --show-current`
- `gh pr view --json url,number`
- Use `gh pr view` first for the current branch. Fall back to `gh pr status` only if `gh pr view` does not identify the PR cleanly.
- Only ask the user when there is no matching PR or multiple plausible PRs.

### 2. Fetch threads

```bash
./scripts/gh-review-comments --filter unresolved --format json <pr-url>
```

Resolve the script path relative to this skill directory. If the helper cannot run, fall back to [`gh-api.md`](gh-api.md).

### 3. Assess and classify each thread

Read the commented file and surrounding code before drafting anything. Do not rely on the reviewer summary alone.

Classify each thread:

- `valid/actionable` — needs a substantive reply (may note deferred fix)
- `needs user decision` — block and ask before posting
- `stale/not applicable` — reply explaining why
- `already addressed` — reply citing existing code or commit
- `pushback` — reviewer misread; reply with correction

### 4. Draft replies

Draft replies in Conventional Comments style when it fits.

Prefer concise labels such as `note:`, `issue:`, `suggestion:`, or `question:` only when they make the reply clearer. Do not force labels into every reply. Keep the tone direct, factual, and grounded in verified code behavior.

When the reviewer is correct:

```text
issue: Good catch. This path still uses the legacy behavior because ... I will update it to ... so both identity-provider flows stay aligned.
```

When the reviewer is partly right but the current change should stay:

```text
note: I agree with the cleanup direction, but I am keeping the current guard for now because ... During the migration this still protects the proxy-backed path. I would treat the tighter invariant as follow-up work.
```

When the reviewer is wrong:

```text
note: This is already covered by ... The behavior differs at runtime because ... so removing this branch would break parity for ...
```

When the user asks only for draft text, do not post.

### 5. Post replies

Post replies with `gh` on the exact review thread. See [`gh-api.md`](gh-api.md) for `addPullRequestReviewThreadReply` and batch patterns.

Match by thread id, not only by path and line, before replying.

### 6. Summary

Return a short execution summary:

- which threads received replies
- which were skipped and why
- discussion URLs when useful

Do **not** implement, commit, push, or resolve unless the user asks.

## Boundaries

- Do not resolve threads unless the user asks.
- Do not make code changes.
- Do not post new inline findings — use **comment** branch for that.
- Do not post a reply that hides uncertainty. If verification is incomplete, say what is still unverified.
