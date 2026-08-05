# Resolve

Close out GitHub PR review feedback on the current branch. Own the full resolve loop: discover the PR, fetch unresolved threads, assess validity in code, plan fixes, implement, run quality gates, push, and resolve addressed threads with commit-hash references.

## Support files

- Use the bundled helper at `scripts/gh-review-comments`.
- Resolve that path relative to this skill directory, not the repo working directory.
- Run it from the skill directory or invoke it by an absolute path derived from the skill location.
- Prefer:
  `./scripts/gh-review-comments --filter unresolved --format json <pr-url>`
- Expect a top-level JSON object with `pr` metadata and `threads`.
- Expect each thread entry to include `thread_id`, `resolved`, `path`, `line`, `html_url`, and `comments`.
- If `gh pr view` already returned a PR URL or number, pass that explicit identifier into the helper instead of relying on helper-side rediscovery.
- If the helper cannot run, fall back to direct `gh` queries per [`gh-api.md`](gh-api.md) rather than asking the user to fetch review data manually.

## Canonical sequence (mandatory order)

### 1. Discover PR

- `git branch --show-current`
- `gh pr view --json url,number`
- Use `gh pr view` first for the current branch. Fall back to `gh pr status` only if `gh pr view` does not identify the PR cleanly.
- Only ask the user when there is no matching PR or multiple plausible PRs.
- If PR discovery is confused by fork context or local repo remotes, switch to the explicit PR URL and continue.

### 2. Fetch unresolved threads

```bash
./scripts/gh-review-comments --filter unresolved --format json <pr-url>
```

Prefer the bundled helper with JSON output so comment text, paths, line numbers, resolution state, and URLs remain structured.

### 3. Assess each thread in code

Read the commented file and surrounding code before drafting anything. Read the relevant diff or commit context. Read adjacent tests, policies, serializers, or service objects when the comment touches behavior outside the local line. Do not rely on the reviewer summary alone.

**Verification standard:**

- Make no assumptions about auth flow, runtime object type, policy behavior, or test coverage.
- When a comment concerns parity between flows, inspect both paths.
- When a comment concerns naming or abstraction, inspect who calls the code and what contract those callers rely on.
- When a comment concerns tests, verify whether the asserted path is actually covered and whether that coverage is meaningful.
- If confidence is not high after verification, do more reading. Do not bluff.

**Classification labels** (one primary per thread):

- `correctness`: the reviewer found a real bug, regression, or missing case
- `coverage`: the reviewer identified a meaningful missing test or missing parity check
- `design`: naming, abstraction, ownership, or code placement feedback
- `misread`: the reviewer misunderstood the code or missed surrounding context
- `follow-up`: the reviewer is directionally right, but the current code is acceptable and the improvement belongs in later cleanup

### 4. Decide per thread

Classify each thread into an action bucket:

- `valid/actionable` — will fix in this pass
- `needs user decision` — block and ask
- `stale/not applicable` — skip or reply explaining why
- `already addressed` — skip or resolve if already on branch
- `pushback` — reviewer misread; reply without code change

**Decision heuristics:**

- If the comment is correct and requires code changes, implement first when the user asked to address the PR end to end.
- If the comment is weak or incorrect, reply with the correction and keep the code unchanged.
- If the comment surfaces a good refactor but not a blocking issue, reply with the correction and suggest the follow-up only if it improves the code.

Be stricter on coherence than on literal compliance. A comment is valid when addressing it improves correctness, clarity, consistency, maintainability, or user experience within the current branch direction. Do not apply comments mechanically when they conflict with explicit user guidance, are stale relative to current code, require product decisions the user has not made, or would degrade the coherence of the overall change.

**Frontload only blocking questions:**

- product intent is unclear
- multiple plausible interpretations would change the edit
- the comment conflicts with current branch direction
- a required fact is not discoverable locally

### 5. Create implementation plan

**Stop and present plan before coding**, unless the fast-path applies:

- numbered list mapping thread → intended change
- grouped commits if comments span distinct concerns
- threads left open and why
- blocking questions upfront

**Fast-path (skip formal plan):** exactly one `valid/actionable` thread and the fix is obvious (e.g. typo, single-line guard, clear rename). Proceed directly to implement; mention the skipped plan in the final summary.

**Always plan when:** 2+ actionable threads, any `needs user decision`, conflicting comments, or non-obvious design tradeoffs.

### 6. Implement

After plan is clear (or fast-path applies). Get user approval if ambiguous scope. Implement valid findings autonomously. Group commits by concern when comments fall into distinct areas.

### 7. Quality gates

Rely on the local repo instructions for which quality gates to run. Do not redefine repo-specific checks in this skill. Do not commit or push until the relevant repo-level gates have passed, or you have clearly reported why a gate could not run.

### 8. Commit + push

Push the branch after the grouped commit set is ready.

### 9. Resolve threads

Resolve only after push. Resolve only the review comments clearly addressed in the pushed commit(s). Leave ambiguous or partially addressed comments open.

Prefer this template:

```text
Addressed in <hash>: <precise change summary>.
```

If a comment is only partly addressed, leave it unresolved and explain why in your user-facing summary instead of force-resolving it.

See [`gh-api.md`](gh-api.md) for thread fetch, resolve mutations, and verification.

### 10. Summary

Report:

- which threads were resolved
- which were left open and why
- commit hash(es)
- which comments were accepted vs. challenged

## Boundaries

- Do not make code changes just because a reviewer suggested them without verification.
- Do not claim parity, coverage, or correctness without reading the relevant code.
- Do not post a reply that hides uncertainty. If verification is incomplete, say what is still unverified.
- Do not wait for pasted GitHub review JSON when the PR can be discovered and queried directly.

## Operating style

- Prefer end-to-end ownership over partial analysis.
- Keep the workflow agent-compatible: deterministic commands, explicit flags, and local relative paths.
- Keep user updates concise and concrete.
- Mention the pushed commit hash in the final closeout summary.
