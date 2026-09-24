# Security

Security/compliance lens. Apply when the change touches authn/authz, sessions, secrets, permissions; confidential, regulated, or multi-tenant data flow; external interfaces, webhooks, workers, integrations; logging, audit trails, exports/reports, resilience controls; or compliance/incident-evidence posture. Otherwise skip. Project security guidance (Rails policy patterns, worker idempotency/retry, webhook signature/replay, tenant rules for exports/admin, local gates) layers on top; its absence never blocks.

## Method

1. Threat context: actors (external, authenticated, admin, staff, third-party), asset sensitivity (public/internal/confidential/regulated), exposure (public/internal API, job, admin UI, integration). State assumptions when incomplete.
2. Map changed assets, trust boundaries, entry points; check whether tests, policies, validation, logging, rate limits, retries, config changed together. Run targeted verification when it changes confidence; say when not run.
3. STRIDE abuse paths: spoofing, tampering, repudiation, disclosure, DoS, privilege escalation.
4. Controls: least privilege / deny-by-default; input validation and safe queries — prefer structure over substring matching; treat untrusted-text matching and follow-up request policy as abuse surface; data minimization/redaction; audit/forensics readiness; retries, timeouts, rate limits.
5. No exploitability, applicability, or control claims without code evidence; missing deployment/infra/product context → lower confidence, record in `Assumptions / Gaps`. No code edits unless fixes are asked after review.

## Severity

- `Critical`: likely exploit → breach, auth bypass, secrets leak, cross-tenant exposure, regulated-data integrity loss.
- `Important`: real exploitation path or control gap — tenant-bound privilege escalation, PII in logs/exports, replayable webhook corrupting state, ambiguous tenant boundary.
- `Nice-to-Have`: defense-in-depth without a concrete current failure.

## Control mapping (not legal advice)

Frameworks: `ISO 27001`, `BSI C5` (usually applicable to security-relevant backend/infra/data changes); `NIS2`, `DORA`, `KRITIS` (resilience, incident handling, dependencies, continuity, critical ops); `EU MDR`, `IEC 62304`, `ISO 13485` (patient safety, clinical logic, lifecycle/design controls, medical data integrity, traceability). Decide applicability per framework; insufficient evidence → `Assessed: No` + reason, no speculation. Non-EU scope → say so; no framework claims beyond evidence. Tags only on clear mapping, e.g. `ISO27001-AccessControl`, `ISO27001-LoggingMonitoring`, `BSI-C5-IAM`, `BSI-C5-DataProtection`, `NIS2-IncidentHandling`, `DORA-ICTRisk`, `KRITIS-Resilience`, `EU-MDR-Traceability`, `IEC62304-ChangeControl`, `ISO13485-DesignControl`.

## Output

Severity-ordered, folded into the `finish` report; no control essays, no repeated evidence. Per finding: `Severity`, `Category`, `Evidence` (path:line), `Abuse path`, `Risk`, `Recommended fix` (minimal, testable), `Control tags` when applicable, `Confidence`.

Always:

- No findings → `No Critical or Important findings detected` + 1–3 residual risks/verification gaps.
- `Assumptions / Gaps` (or `None`).
- `Compliance coverage summary`: one line per relevant framework, `Framework | Assessed: Yes/No | Reason or controls checked`; `Not assessed in this review` when out of scope.

Compact path (≤2 files and no authn/authz, secrets, sensitive data/tenant, privileged/audit/logging/export, or external/webhook/resilience changes): threat context + the three "always" items only.
