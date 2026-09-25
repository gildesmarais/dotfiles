# Resolve

Own the loop: discover PR → fetch unresolved threads → assess in code → plan → implement → gates → push → resolve with commit hashes.

## Sequence

1. **Discover** — `gh pr view --json url,number` (fallback `gh pr status`; on fork/remote confusion switch to the explicit PR URL). Ask only when no PR or several plausible ones.
2. **Fetch** — `./scripts/gh-review-comments --filter unresolved --format json <pr-url>` (path relative to the skill dir; pass the explicit URL/number already found). Helper fails → direct `gh` per [`gh-api.md`](gh-api.md); never wait for pasted JSON.
3. **Assess** each thread in code (file, diff, adjacent tests/policies/callers; both paths for parity claims; callers' contract for naming). Keep reading until confident; state what stays unverified.
   - Primary label: `correctness` | `coverage` | `design` | `misread` | `follow-up`.
   - Action: `valid/actionable` (fix now) | `needs user decision` (block, ask) | `stale/not applicable` (skip or reply why) | `already addressed` (skip or resolve) | `pushback` (reply, no code).
   - Valid = improves the change within current branch direction. Don't apply mechanically when stale, conflicting with user guidance, needing an unmade product decision, or degrading coherence. Frontload only blocking questions.
4. **Plan** — stop and present before coding: thread → change, commit grouping by concern, threads left open + why, blocking questions. Always when 2+ actionable, any `needs user decision`, conflicts, or non-obvious tradeoffs. Fast-path: exactly one obvious fix (typo, one-line guard, clear rename) → implement; note the skipped plan in the summary.
5. **Implement** — group commits by concern; run the repo's own gates; no commit/push until gates pass or the blocker is reported.
6. **Push**.
7. **Resolve** — only after push, only threads clearly addressed; reply `Addressed in <hash>: <precise change summary>.` Partial → leave open, explain in summary.

## Summary

Resolved threads; left open + why; accepted vs challenged; commit hash(es).
