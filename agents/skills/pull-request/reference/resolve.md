# Resolve

Own the loop: fetch unresolved threads → assess in code → plan → implement → gates → push → resolve with commit hashes.

## Sequence

1. **Fetch** — unresolved threads via Shared prep (fallback [`gh-api.md`](gh-api.md)).
2. **Assess** each thread in code (file, diff, adjacent tests/policies/callers; both paths for parity claims; callers' contract for naming); state what stays unverified.
   - Primary label: `correctness` | `coverage` | `design` | `misread` | `follow-up`.
   - Action: `valid/actionable` (fix now) | `needs user decision` (block, ask) | `stale/not applicable` (skip or reply why) | `already addressed` (skip or resolve) | `pushback` (reply, no code).
   - Valid = improves the change within current branch direction. Don't apply when stale, conflicting with user guidance, needing an unmade product decision, or degrading coherence. Ask only blocking questions, up front.
3. **Plan** — stop and present before coding: thread → change, commit grouping by concern, threads left open + why, blocking questions. Always when 2+ actionable, any `needs user decision`, conflicts, or non-obvious tradeoffs. Fast-path: exactly one obvious fix → implement; note skipped plan.
4. **Implement** — group commits by concern; run the repo's own gates; no commit/push until gates pass or the blocker is reported.
5. **Push**, then **Resolve** only threads clearly addressed; reply `Addressed in <hash>: <precise change summary>.` Partial → leave open, explain in summary.

## Summary

Resolved threads; left open + why; accepted vs challenged; commit hash(es).
