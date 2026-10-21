# Publish

End-to-end PR review: retrieve → fresh multi-lens ledger → reconcile drafts/threads → recheck SHA → submit one friendly `COMMENT` review → thread replies → verify URLs. Load [`conventional-comments.md`](conventional-comments.md) when drafting. Mutation steps → [`github-state.md`](github-state.md).

## Hard rules

- Submit only `event: "COMMENT"`; never `REQUEST_CHANGES` or `APPROVE`, even for Critical. Reject any payload with another event.
- Build a **fresh** ledger against the PR head; existing pending drafts are reconcile input, not truth.
- Never edit others' comments or resolve their threads; never publish on a stale head SHA or guessed line; never change application code.

## 1. Retrieve

Use the `pr-context.sh --publish` snapshot from Shared prep (or run `./scripts/pr-context.sh --publish <pr>` once). Read patch + code at the PR head; record the verified head SHA. Apply target-repo `AGENTS.md`.

## 2. Ledger

Apply `finish` + selected lenses. Publish high-confidence Critical/Important; Nice-to-Have only if materially useful. Drop decline, soft, optional, speculative, duplicate, already-answered. Prefer a substantive reply on an existing thread over a duplicate inline. Seek 0–2 earned `praise`.

| Field      | Values                                                            |
| ---------- | ----------------------------------------------------------------- |
| Severity   | Critical / Important / Nice-to-Have                               |
| Confidence | High / Medium / Low + concrete impact                             |
| Evidence   | path + RIGHT-side diff line on verified head SHA                  |
| Coverage   | new thread / current-user draft / existing human or bot thread    |
| Action     | `publish-inline` / `reply-existing` / `review-body-only` / `drop` |
| Wording    | Conventional Comments body                                        |

Regex-validate every inline comment and labeled reply before posting.

## 3. Reconcile → stale guard → publish → verify

Fail-closed procedure: [`github-state.md`](github-state.md) — keep verified drafts; re-fetch head SHA before first mutation (stale → abort/re-anchor); submit `COMMENT` only; draft-only → stop at PENDING; verify URLs; state no code changed.

## Review body

- `## Review findings`, one outcome sentence, severity-ordered findings with impact (don't paste inline bodies), optional short "What looks solid".
- Never "Request changes" / "blocking review". Conventional Comments only for inline comments and replies.
- Close with "When this is ready, feel free to re-request my review."
