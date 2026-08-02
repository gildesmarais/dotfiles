# Finish

Production-readiness assessment for a git branch. Findings report only — no boy-scout edits.

After shared prep (SKILL.md), continue here.

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
