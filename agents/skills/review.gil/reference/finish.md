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
5. Races across a startup/suspension gate; parse/unwrap or generated-client types escaping the transport edge; checker silenced instead of fixed; durable bags used as live domain objects without rehydrate; wire enum renamed in app code instead of normalized once → `{lang}-dev`.
6. Repeated harden/follow-up commits hinting at a missing principle?
7. Different clocks for server/data/clients: break for lagged client, pre-backfill pod, or existing session? Can temp compat be removed later? Any mechanism counts; find only real breaks or undeletable temp paths — not missing names.


## Surfaces

Review passes folded here (not lenses/executions; `quality` skips). Code diffs only — skip docs-only/trivial and say so. Prefer host review subagent (security review only with `security` lens), else second inline pass. Pass repo path, target (`branch changes` | `uncommitted changes`), non-default base if needed, user instructions; it computes the diff. Fail → retry once (per-file desc if no diff), name blocker, continue inline. Never fix, publish, or relaunch from output.

