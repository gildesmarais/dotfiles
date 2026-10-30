# Finish

Production-readiness baseline. Report only — no boy-scout edits. PR targets: PR patch + surrounding code at the recorded head SHA.

## Output format (required)

All lenses fold into one report. Always emit **Findings** and **Readiness**; other sections only when non-empty or a Critical exists.

- **Findings** — Critical / Important / Nice-to-Have; each with impact + recommended action.
- **Readiness** — Production readiness: Yes / No / Conditional; top risks; immediate actions.
- Optional: **Non-Goals**, **Confidence & Uncertainty** (known vs inferred/unverified), **Compliance & Risk Posture** (passes, flags, minimum remediation or compensating controls).

## Incident / fix-diff postures

For `fix`, `Revert`, or production-incident diffs, fold into Findings (no extra lens):

1. Did the fix wander onto a second surface, or does a neighboring layer absorb a boundary failure? → `$dev` → `{lang}-dev` → `architecture`.
2. Does a path assume an invisible contract (shape, reload, cache identity, cutover), or treat disclosure/access as mere presence? → overlay, `security`, else `architecture`.
3. Do validate and execute see the same truth; is each guard owned at one lifecycle point; does the published contract accept only what runtime accepts?
4. Dual public API or silent old-shape hydrate? → [`legacy.md`](legacy.md).
5. Races across a startup/suspension gate; parse/unwrap or generated-client types escaping the transport edge; checker silenced instead of fixed → `{lang}-dev`.
6. Repeated harden/follow-up commits hinting at a missing principle?

## Surfaces

Independent review passes folded into this report; not lenses or executions; `quality` skips them. Code diffs only (skip docs-only and trivial diffs and say so). Use a host review subagent if one exists (security review only when the `security` lens is selected), else a second inline pass. Give it the repo path, target (`branch changes` or `uncommitted changes`), a base branch only when not the repo default, and user instructions; it computes the diff. Failure: retry once (per-file change description if the diff could not be computed), then name the blocker and continue inline. Never fix, publish, or launch a second review from their output.
