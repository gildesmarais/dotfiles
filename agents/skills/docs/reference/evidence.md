# Docs — `evidence`

Prove a stated control from the repository. Do not change the system under assessment.

Use for auditor or control-evidence packs, including an Assessment / Evidence / Scope / Task brief.

## Objective

A reader who stops after the summary and results table has the control answer.

## Verdicts

- **Met** — enforced in code, IaC, or tests you read
- **Partial** — part of the control holds
- **Not met** — the property fails on the evidence
- **Unverified** — production or live value not read

Never report an estate-wide pass on a mixed control. Never invent live config.

## Evidence

Use the ladder in [`architecture.md`](architecture.md). Isolating a gap is a **published** finding, not handoff-only.

## Shape

Inverted pyramid:

1. Executive summary — pack job, control answer, 3–6 headlines, residual or compensating note if relevant, deep-dive anchors. No citation dumps.
2. Assessment results — compact table of in-scope surfaces. Related items: one link down.
3. How to read — scoring, evidence tier, date, access note for private sources.
4. Deep dives — two-sentence recap plus link up, then evidence.
5. Gaps — in the body and in the summary.
6. Snapshot — date and source revision ids.

If the user supplied Assessment / Evidence / Scope / Task, that is purpose and blast radius.

## Cite

Name the source. On a code host, use the default-branch URL with a line range. Snapshot revisions so a moving branch cannot silently change the claim. Vendor behavior: official public doc plus in-repo wiring. No secrets, credentials, raw tokens, or secret values. Repo path conventions stay in that repo's `AGENTS.md`.

## Scope

Cover every named surface. Treat clients as read-only unless the ask mutates them.

## Boundaries

- Do not remediate the system under assessment.
- Do not present unimplemented architecture as current.
- Do not hide Not met or Unverified as an appendix-only afterthought.

## Handoff additions

- verification tier
- verdict mix
- gaps left in the document
