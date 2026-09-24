# Publish

End-to-end PR review: retrieve → fresh multi-lens ledger → reconcile drafts/threads → recheck SHA → submit one friendly `COMMENT` review → thread replies → verify URLs. Load [`conventional-comments.md`](conventional-comments.md) when drafting and [`github-state.md`](github-state.md) right before mutating.

## Hard rules

- Submit only `event: "COMMENT"`; never `REQUEST_CHANGES` or `APPROVE`, even for Critical. Reject any payload with another event.
- Build a **fresh** ledger against the PR head; existing pending drafts are reconcile input, not truth.
- Never edit others' comments or resolve their threads; never publish on a stale head SHA or guessed line; never change application code.

## 1. Retrieve

Use the `pr-context.sh --publish` snapshot from Shared prep (or run `./scripts/pr-context.sh --publish <pr>` once). It carries owner/repo/number, title/body, base/head, head SHA, commits, files, checks, `me`, current user's pending review + drafts, unresolved threads. Read patch + code at the PR head; record the verified head SHA. Apply target-repo `AGENTS.md` and any language skills it routes to.

## 2. Ledger

Apply `finish` + selected lenses. Prioritize correctness, regressions, security/privacy, data integrity, ops behavior, missing tests. No style preferences, speculation, or alternatives without material risk; CI failures only when proven PR-caused. Seek 0–2 earned `praise`.

| Field      | Values                                                            |
| ---------- | ----------------------------------------------------------------- |
| Severity   | Critical / Important / Nice-to-Have                               |
| Confidence | High / Medium / Low + concrete impact                             |
| Evidence   | path + RIGHT-side diff line on verified head SHA                  |
| Coverage   | new thread / current-user draft / existing human or bot thread    |
| Action     | `publish-inline` / `reply-existing` / `review-body-only` / `drop` |
| Wording    | Conventional Comments body                                        |

Publish high-confidence Critical/Important; Nice-to-Have only if materially useful. Drop decline, soft, optional, speculative, duplicate, already-answered. Prefer a substantive reply on an existing thread over a duplicate inline; never a bare "agree". Regex-validate every inline comment and labeled reply before posting.

## 3. Reconcile own drafts

Snapshot pending review ID, body, all drafts before mutating. Keep verified drafts; delete only `drop` ones, per comment — never discard the whole pending review for convenience. If recreate is unavoidable, rebuild and verify the full preserved ledger first.

## 4. Stale guard

Re-fetch head SHA immediately before the first mutation; if changed, stop, refresh diff, re-anchor, revalidate.

## 5. Publish

Per [`github-state.md`](github-state.md): no pending → one REST create with `COMMENT`; pending → delete dropped drafts, append new, submit `COMMENT` with final body. Thread replies only after the main review succeeds. Partial failure → inspect actual state before retry. Draft-only requested → stop at PENDING, do not submit. No valid findings → publish a short COMMENT summary only if publication was explicitly asked; else report "no findings".

## 6. Verify

Fetch the review + inline comments via API; confirm no pending review remains (unless draft-only); return review URL and every new comment/reply URL; state no code changed.

## Review body

- `## Review findings`, one outcome sentence, severity-ordered findings with impact (don't paste inline bodies), optional short "What looks solid".
- Never "Request changes" / "blocking review". Conventional Comments only for inline comments and replies.
- Close with "When this is ready, feel free to re-request my review." Offer at most one topic-specific live route (`sync`, `huddle`, or `chat`) only when trade-offs are faster live; none for straightforward fixes.
