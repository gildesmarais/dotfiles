# Security

Security/compliance lens. Apply when the change touches authn/authz, sessions, secrets, permissions; confidential, regulated, or multi-tenant data; external interfaces, webhooks, workers; logging, audit trails, exports; or compliance posture. Otherwise skip. Project security guidance layers on top; its absence never blocks.

## Method

1. Threat context: actors, asset sensitivity, exposure. State assumptions when incomplete.
2. Map changed assets, trust boundaries, entry points; check whether tests, policies, validation, logging, rate limits, retries, config changed together.
3. Abuse paths via STRIDE categories; controls: least privilege / deny-by-default; input validation and safe queries; untrusted-text matching; data minimization/redaction; audit readiness; retries, timeouts, rate limits.
4. No exploitability or control claims without code evidence; missing context → lower confidence, record in `Assumptions / Gaps`. No code edits unless fixes are asked after review.

## Severity

- `Critical`: likely exploit → breach, auth bypass, secrets leak, cross-tenant exposure, regulated-data integrity loss.
- `Important`: real exploitation path or control gap — tenant-bound privilege escalation, PII in logs/exports, replayable webhook, ambiguous tenant boundary.
- `Nice-to-Have`: defense-in-depth without a concrete current failure.

## Control mapping (not legal advice)

Frameworks: `ISO 27001`, `BSI C5`; `NIS2`, `DORA`, `KRITIS`; `EU MDR`, `IEC 62304`, `ISO 13485`. Decide applicability per framework; insufficient evidence → `Assessed: No` + reason. Non-EU scope → say so. Tags only on clear mapping.

## Output

Severity-ordered, folded into the `finish` report. Per finding: `Severity`, `Category`, `Evidence` (path:line), `Abuse path`, `Risk`, `Recommended fix`, `Control tags` when applicable, `Confidence`.

Always: No findings → say so + 1–3 residual risks; `Assumptions / Gaps` (or `None`); `Compliance coverage summary` one line per relevant framework.

Compact path (≤2 files and no authn/authz, secrets, sensitive data/tenant, privileged/audit/logging/export, or external/webhook/resilience changes): threat context + the three "always" items only.
