# Finish

Production-readiness baseline. Report only — no boy-scout edits. PR targets: PR patch + surrounding code at the recorded head SHA, never the local tree or `HEAD`.

## Output format (required)

All lenses fold into this single report.

**Findings** — Critical / Important / Nice-to-Have; each with impact + recommended action.

**Non-Goals** — explicit exclusions and intentionally unaddressed areas.

**Confidence & Uncertainty** — known facts vs inferred/unverified.

**Compliance & Risk Posture** — what passes, what gets flagged, minimum viable remediation or compensating controls.

**Executive Summary** — Production readiness: Yes / No / Conditional; top risks; immediate actions.

## Incident / fix-diff postures

For `fix`, `Revert`, or production-incident diffs, fold these into Findings (no extra lens):

1. Did the fix wander onto a second surface, or does a neighboring layer absorb a boundary failure? → `$dev` → `{lang}-dev` → `architecture`.
2. Does a path assume an invisible contract (shape, reload, cache identity, cutover), or treat disclosure/access as mere presence? → overlay, `security`, else `architecture`.
3. Do validate and execute see the same truth; is each guard owned at one lifecycle point; does the published contract accept only what runtime accepts?
4. Dual public API or silent old-shape hydrate without required compat? → [`legacy.md`](legacy.md).
5. Races across a startup/suspension gate; parse/unwrap or generated-client types escaping the transport edge; checker silenced instead of fixed → `{lang}-dev`.
6. Repeated harden/follow-up commits hinting at a missing principle?

## Surfaces

Independent review passes folded into this one report; not lenses or executions. `quality` does not run them. Run only for a code diff (skip docs-only and trivial diffs and say so). Use a host review subagent when one exists (a security review only when the `security` lens is selected), else a second inline pass. Let the subagent compute the diff: give it the repo path, the target (`branch changes` or `uncommitted changes`), a base branch only when it is not the repo default, and any user instructions. Failure: retry once (per-file change description if the diff could not be computed), then name the blocker and continue inline. Do not fix, publish, or launch a second review from their output.
