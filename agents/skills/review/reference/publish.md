# Publish

End-to-end PR review publish: retrieve → fresh multi-lens review → reconcile drafts → submit a friendly GitHub `COMMENT` review.

Load references progressively, not all up front:

1. Use [`finish.md`](finish.md) as the baseline and load only the additional lenses selected by `SKILL.md`.
2. Load [`conventional-comments.md`](conventional-comments.md) when drafting bodies.
3. Load [`github-state.md`](github-state.md) immediately before reconciling or publishing GitHub state.

## Hard rules

- When submitting, always use `event: "COMMENT"`.
- Never submit `REQUEST_CHANGES` or `APPROVE`, even for Critical findings.
- Reject any generated payload whose event is `REQUEST_CHANGES` or `APPROVE`.
- Always build a **fresh** finding ledger against the PR head. Existing pending drafts are input to reconcile, not the final source of truth.
- Never alter another reviewer’s comments or resolve their threads.
- Never publish against a stale head SHA or a guessed line.
- Do not change application code in this branch.

## Workflow

```text
retrieve → inspect → fresh ledger → reconcile drafts/threads → recheck SHA
  → (no pending) create COMMENT review
  → (pending) delete dropped own drafts → append kept/new → submit COMMENT
  → useful thread replies → verify URLs
```

### 1. Retrieve one coherent snapshot

Use the coherent publish snapshot captured during `SKILL.md` scope prep. If this execution was entered after prep, resolve the PR from URL, number, or current branch and run the skill-local helper once:

```bash
./scripts/pr-context.sh --publish <pr-url-or-number>
```

Capture at minimum: owner/repo/number/url, title/body, base/head, head SHA, commits, changed files, checks summary, current user login, current user’s pending review + draft comments, unresolved review threads.

Read the PR patch and surrounding code from the **PR head**, not the local dirty tree. Record the head SHA every finding was verified against.
Read `AGENTS.md` from the target repository when present and apply its project-specific guidance.

### 2. Review findings-first

- Apply the `finish` baseline and every additional lens selected from the scoped diff.
- Load repo-specific language/framework skills when `AGENTS.md` routes to them.
- Prioritize correctness, regressions, security/privacy, data integrity, operational behavior, and missing tests.
- Do not post style preferences, speculative concerns, or implementation alternatives without material risk.
- Include CI failures only after proving they are caused by the PR.
- Actively look for 0–2 earned `praise` opportunities (see human touch in `conventional-comments.md`).

### 3. Build a fresh finding ledger

Each candidate records:

| Field      | Values                                                            |
| ---------- | ----------------------------------------------------------------- |
| Severity   | Critical / Important / Nice-to-Have                               |
| Confidence | High / Medium / Low + concrete impact                             |
| Evidence   | path + RIGHT-side diff line on verified head SHA                  |
| Coverage   | new thread / current-user draft / existing human or bot thread    |
| Action     | `publish-inline` / `reply-existing` / `review-body-only` / `drop` |
| Wording    | Conventional Comments body                                        |

Triage:

- Publish Critical and Important findings with high confidence.
- Publish Nice-to-Have only when materially useful and concise.
- Drop decline, soft, optional, speculative, duplicate, and already-answered drafts.
- Prefer a substantive reply on an existing thread over a duplicate inline comment.
- Do not post a bare “agree.” Reply only when adding verified evidence, impact, or a precise remediation distinction.
- Validate every inline comment and every labeled thread reply against the Conventional Comments regex before posting.

### 4. Reconcile the current user’s draft review safely

- Snapshot the pending review ID, body, and every draft comment before mutations.
- Preserve verified draft comments; remove only comments classified `drop`.
- Prefer deleting individual draft comments. Do not delete the whole pending review merely for convenience.
- If GitHub requires deleting/recreating the pending review, reconstruct the complete preserved ledger and verify it before submission.

### 5. Guard against stale publishing

Immediately before the first mutation, fetch the head SHA again:

- If unchanged, publish.
- If changed, stop mutation, refresh the diff, re-anchor affected comments, and revalidate findings.

### 6. Publish one friendly review

Follow [`github-state.md`](github-state.md):

- **No pending review:** create the review and inline comments in one REST request with `event: "COMMENT"`.
- **Pending review exists:** remove discarded own drafts, append verified new comments, set the final body when submitting, submit with `event: "COMMENT"`.
- Post existing-thread replies only after the main review succeeds.
- If a partial write fails, inspect actual GitHub state before retrying to avoid duplicates.

If the user asked only for GitHub-pending drafts, stop after creating/appending PENDING — do not submit.

### 7. Verify and report

- Fetch the submitted review and its inline comments through the API.
- Confirm no pending review remains after publish (unless draft-only was requested).
- Return the review URL and direct URLs for every new inline comment/reply.
- Explicitly state that no code was changed.

## Review body style

- Start with `## Review findings`.
- Short outcome sentence (e.g. “I found a few important issues worth addressing.”).
- Severity-ordered findings with impact — do not paste full inline comments.
- Short “What looks solid” when useful; mention one standout design choice when praise is earned.
- Do not say “Request changes” or “blocking review.”
- Conventional Comments are for inline comments and thread replies only.

End with a short, natural handoff:

- Invite re-request of review when ready: “When this is ready, feel free to re-request my review.”
- If ambiguity/trade-offs would be faster live, offer one low-pressure route with one word (`sync`, `huddle`, or `chat`) — topic-specific, not canned.
- Do not stack “sync/huddle/meet” or invite a meeting when fixes are straightforward.

Example closing:

```text
The read-only support boundary and staged completion flow are thoughtfully separated. When the points above are ready, feel free to re-request my review. If the historical completion semantics would be easier to settle live, ping me for a quick huddle.
```

If no valid findings remain: publish a concise COMMENT summary only when the user explicitly asked to publish; otherwise return “no findings” without creating review noise.

## Completion checklist

- [ ] Fresh ledger verified on recorded head SHA
- [ ] Drafts reconciled (kept / dropped / added)
- [ ] Every posted body matches Conventional Comments
- [ ] Submit event is `COMMENT` only, or explicit draft-only state remains PENDING
- [ ] Review + discussion URLs reported
- [ ] No application code changed
