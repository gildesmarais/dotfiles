# Docs — `evidence`

Prove a stated control from the repo. Never change or remediate the system under assessment. A user-supplied Assessment / Evidence / Scope / Task brief defines purpose and blast radius.

## Verdicts

- **Met** — enforced in code, IaC, or tests you read
- **Partial** — part of the control holds
- **Not met** — the property fails on the evidence
- **Unverified** — production or live value not read

Never report an estate-wide pass on a mixed control; never invent live config.

## Evidence

Ladder: [`architecture.md`](architecture.md). Cover every named surface; clients are read-only. An isolated gap is a published finding, not handoff-only.

## Shape

Inverted pyramid:

1. Executive summary — pack job, control answer, 3–6 headlines, residual or compensating note, deep-dive anchors; the reader who stops here has the answer. No citation dumps.
2. Assessment results — compact table of in-scope surfaces. Related items: one link down.
3. How to read — scoring, evidence tier, date, access note for private sources.
4. Deep dives — two-sentence recap plus link up, then evidence.
5. Gaps — in the body and in the summary (never appendix-only).
6. Snapshot — date and source revision ids.

## Cite

On a code host, use the default-branch URL with a line range; snapshot revisions so a moving branch cannot silently change the claim. Vendor behavior: official public doc plus in-repo wiring. No secrets, credentials, or tokens.

## Handoff additions

- verification tier
- verdict mix
- gaps left in the document
