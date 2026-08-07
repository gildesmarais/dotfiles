# Finish

Production-readiness baseline for a local change, branch, commit range, or pull request. Findings report only — no boy-scout edits.

After scope prep in `SKILL.md`, continue here. For a pull request, review the PR patch and surrounding code at the recorded head SHA; never substitute the local working tree or local `HEAD`.

## Workflow

1. Establish scope and assumptions

- Capture explicit assumptions and missing context.

2. Review in priority order

- Production readiness
- Industry-standard patterns
- Maintainability and ownership transfer
- Risk identification and due diligence
- Compliance posture clarity

3. Apply the review workflow

- Assess architecture, boundaries, responsibilities.
- Evaluate code quality, failure modes, edge cases.
- Validate config, logging, security, and ops concerns.
- Enumerate risks, debt, limitations, and compliance gaps.

4. Use the autonomous review loop until convergence or blocked

- Scan → Evaluate → Decide → Document → Re-check.
- Stop only when Critical is empty and Important has owners or rationale.

## Output format (required)

**Findings**

- Categorize as Critical / Important / Nice-to-Have.
- Each finding includes impact and recommended action.

**Non-Goals**

- List explicit exclusions and intentionally unaddressed areas.

**Confidence & Uncertainty**

- Separate known facts from inferred or unverified items.

**Compliance & Risk Posture**

- What would pass review.
- What would be flagged.
- Minimum viable remediation or compensating controls.

**Executive Summary**

- Production readiness: Yes / No / Conditional.
- Top risks.
- Immediate actions.

## Guardrails

- Do not add features or redesign unless current design creates material risk.
- Prefer proven, conventional solutions.
- Optimize for clarity over novelty.
- Treat undocumented behavior as a defect.
- If deviating from standards, write explicit justification.

## Incident / fix-diff postures

When the target is a `fix`, `Revert`, or production-incident shaped diff, ask:

1. Did this fix wander onto a second surface? → remediate via `$dev` → routed `{lang}-dev` (one-surface; overlay `$dev` loaded for this change when applicable).
2. Is a neighboring layer absorbing a boundary failure? → `$dev` → routed `{lang}-dev` → `architecture`.
3. Does the path assume an invisible contract (shape, reload, cache identity, cutover successor)? → active framework overlay if present (overlay `$dev` loaded for this change), else `architecture`.
4. Is disclosure or access treated as mere presence? → overlay when present (+ **security** when sensitive), else `architecture` / **security**.
5. Did validate and execute see the same truth?
6. Is each guard or policy owned at one lifecycle point?
7. Does the published contract accept only what runtime accepts?
8. Do repeated harden / review-follow-up commits hint a missing principle rather than noise?
9. Dual public API or silent old-shape hydrate without user-required compat? → load [`legacy.md`](legacy.md); flag as debt (findings) or delete under `quality`.
10. Did uniqueness or readiness race across a suspension/startup gate?
11. Did a durable/plain bag get treated as a live domain object without rehydrate?
12. Did parse/unwrap or generated-client types escape the transport/adapter edge?
13. Was a wire enum renamed in app code instead of normalized once?
14. Did the change silence the checker with `as` / `!` / bare suppression instead of earning the type? → `$dev` → routed `typescript-dev`.

Fold answers into the single Findings report; do not invent a separate review lens beyond the selected table in `SKILL.md`.
