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

For `fix`, `Revert`, or production-incident diffs, check (fold into Findings; no extra lens):

1. Fix wandered onto a second surface? → `$dev` → routed `{lang}-dev`.
2. Neighboring layer absorbing a boundary failure? → `$dev` → `{lang}-dev` → `architecture`.
3. Path assumes an invisible contract (shape, reload, cache identity, cutover)? → overlay, else `architecture`.
4. Disclosure/access treated as mere presence? → overlay (+ `security` when sensitive), else `architecture` / `security`.
5. Did validate and execute see the same truth? Is each guard owned at one lifecycle point? Does the published contract accept only what runtime accepts?
6. Dual public API or silent old-shape hydrate without user-required compat? → [`legacy.md`](legacy.md).
7. Uniqueness/readiness race across a suspension/startup gate? Durable bag treated as live domain object without rehydrate?
8. Parse/unwrap or generated-client types escaping the transport edge? Wire enum renamed in app code instead of normalized once?
9. Checker silenced with `as` / `!` / bare suppression? → `$dev` → `typescript-dev`.
10. Repeated harden/review-follow-up commits hinting a missing principle?
