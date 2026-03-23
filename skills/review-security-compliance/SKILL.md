---
name: review-security-compliance
description: "Security and compliance-focused code review workflow for changes that may impact confidentiality, integrity, availability, privacy, auditability, or regulatory controls. Use for threat-driven review, control-gap assessment, and remediation guidance."
---

# Review Security Compliance

## Purpose

Review code and configuration changes for security and compliance risk with findings-first output.
Focus on practical risk reduction, auditable evidence, and concise reporting.

Use this skill when a change may affect:

- authentication or authorization boundaries
- tenant isolation or sensitive data handling
- externally reachable APIs, webhooks, or integrations
- privileged operations, auditability, or operational resilience
- regulated workflows or evidence relevant to certification controls

When another project guide exists, follow it in addition to this skill.
If no project-specific guidance exists, this skill is self-sufficient.

## Reusable Review Scope

Run this review when at least one is true:

- the change touches authn, authz, sessions, secrets, or permissions
- the change affects data flow for confidential, regulated, or multi-tenant data
- the change adds or alters an external interface, webhook, background worker, or third-party integration
- the change alters logging, audit trails, export/report behavior, or resilience controls
- the change could plausibly affect compliance posture or incident evidence quality

If none apply, do not force this skill into the review.

## Threat Context

Before analysis, identify:

- actor classes: external user, authenticated user, admin, internal staff, third-party system
- asset sensitivity: public, internal, confidential, regulated
- exposure surface: public API, internal API, background job, admin UI, integration boundary

If context is incomplete, state assumptions explicitly and narrow claims accordingly.

## Review Prep

Build evidence before writing findings:

1. Inspect the diff and the surrounding code.
2. Map changed assets, trust boundaries, and entry points.
3. Check nearby tests, validation logic, policies, and logging behavior when present.
4. Run targeted verification commands when they materially affect confidence.
5. If evidence is missing, lower confidence and say so plainly.

Do not invent exploitability, framework applicability, or verification evidence.

## Method

1. Identify abuse paths using STRIDE-style thinking:
   - spoofing
   - tampering
   - repudiation
   - information disclosure
   - denial of service
   - privilege escalation
2. Evaluate control coverage:
   - least privilege and deny-by-default authorization
   - input validation and safe query construction
   - data minimization and sensitive data redaction
   - auditability and incident forensics readiness
   - resilience boundaries such as retries, timeouts, and rate limits
3. Produce severity-ranked findings with minimal, testable remediation.

## Control Mapping

Map findings to control intent for auditability. This is not legal advice or a certification statement.

Frameworks available for mapping when applicable:

- `ISO 27001`
- `BSI C5`
- `NIS2`
- `DORA`
- `KRITIS`
- `EU MDR`
- `IEC 62304`
- `ISO 13485`

Use concise control tags only when the finding clearly maps to the framework, for example:

- `ISO27001-AccessControl`
- `ISO27001-LoggingMonitoring`
- `BSI-C5-IAM`
- `BSI-C5-DataProtection`
- `NIS2-IncidentHandling`
- `DORA-ICTRisk`
- `KRITIS-Resilience`
- `EU-MDR-Traceability`
- `IEC62304-ChangeControl`
- `ISO13485-DesignControl`

## Applicability Rules

Make an explicit applicability decision per framework.
Only assess a framework when the change touches its control surface and there is enough evidence to say something meaningful.

Default heuristics:

- `ISO 27001` and `BSI C5`: usually applicable for security-relevant backend, infrastructure, and data-handling changes
- `NIS2`, `DORA`, `KRITIS`: applicable when the change affects resilience, incident handling, service dependencies, operational continuity, or critical operations
- `EU MDR`, `IEC 62304`, `ISO 13485`: applicable when the change affects patient safety, clinical logic, software lifecycle controls, medical data integrity, design controls, or regulated traceability

If evidence is insufficient:

- mark `Assessed: No`
- give a short reason
- do not speculate

If the repository context indicates a non-EU regulatory scope, say so explicitly and avoid framework-specific claims beyond the evidence.

## Severity Model

- `Critical`: likely exploit leading to data breach, auth bypass, major integrity loss, or regulated-data compromise
- `High`: meaningful exploitation path with material impact
- `Medium`: weakness requiring additional conditions or with bounded impact
- `Low`: hardening or defense-in-depth issue

Severity anchors:

- `Critical`: cross-tenant exposure, auth bypass, secrets leakage, integrity compromise of regulated data
- `High`: tenant-bound privilege escalation, PII leakage in logs or exports, replayable webhook causing state corruption, ambiguous tenant boundary enforcement

## Output Format

Keep output efficient and precise.
Prefer short findings over exhaustive prose.
Only include sections that add evidence or change the decision.

For each finding, include:

- `Severity`
- `Category`
- `Evidence` (file path + line)
- `Abuse path`
- `Risk`
- `Recommended fix`
- `Control tags` when applicable
- `Confidence`

If no findings:

- State `No critical/high findings detected`
- List residual risks or verification gaps in 1 to 3 bullets

Always include a short `Assumptions / Gaps` section when any context, exploitability, or applicability decision depends on incomplete evidence:

- list missing context, skipped verification, or bounded claims
- state `None` when not needed

Always include a short `Compliance coverage summary`:

- one line per relevant framework
- format: `Framework | Assessed: Yes/No | Reason or controls checked`
- include `Not assessed in this review` when a framework is out of scope for the change

Do not produce long control essays.
Do not restate the same evidence in multiple sections.

## Review Lenses

Assess against practical control intent:

- access control and least privilege
- secure development and change management
- logging and monitoring for sensitive operations
- data protection and privacy-by-default
- incident response readiness through traceability and audit evidence

## Optional Project Overlay

If the repository provides project-specific review guidance, incorporate it after the core review.
Useful overlays include:

- framework-specific concerns such as Rails policy patterns
- queue or worker guarantees such as idempotency and retry safety
- webhook signature and replay protections
- tenant-boundary rules for exports, reports, and admin tooling
- local validation commands or review gates

If no overlay exists, do not block the review.

## Low-Impact Path

Use compact format only when all are true:

- the change touches `<=2` files
- no authn or authz boundary changes
- no secrets handling or credential flow changes
- no sensitive data-flow or tenant-boundary changes
- no privileged operation, audit trail, or sensitive logging/export changes
- no external integration, webhook, or resilience behavior changes

Compact format still requires:

- threat context
- `No critical/high findings detected` if applicable
- `Assumptions / Gaps`
- compliance coverage summary

## Reporting Discipline

- findings first, ordered by severity
- use precise file references
- keep remediation minimal, actionable, and testable
- prefer explicit assumptions over broad claims
- optimize for signal density, not completeness theater

## Operational Guardrails

Before writing findings:

1. Establish the review target explicitly: branch, PR, commit range, or named files.
2. Review the actual diff first, then inspect surrounding code needed to support each claim.
3. Distinguish committed changes from unrelated local workspace edits.
4. Check whether tests, policy code, validation, logging, rate limiting, retry behavior, and configuration changed together.
5. Run targeted verification commands when they materially change confidence, and report when they were not run.

Operational rules:

- Do not edit code unless the user explicitly asks for fixes after the review.
- Do not report exploitability, framework applicability, or control coverage without code evidence.
- If a claim depends on missing deployment, infrastructure, or product context, downgrade confidence and move the gap into `Assumptions / Gaps`.
