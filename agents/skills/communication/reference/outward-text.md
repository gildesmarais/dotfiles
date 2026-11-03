---
description: Text hygiene and shape — published text leaks nothing and reads for anyone; operator replies are conclusion-first with single-paste manual steps
alwaysApply: true
---

# Outward text

Always-on for text leaving the agent. Edit history, sent mail, and notifications keep the first draft, so a later scrub never removes a value.

## Published

Commits, PR/issue/review comments, release notes, Slack, email, tickets, docs, artifacts — private repos and channels included.

- Name roles, not identifiers: "the production host", "an off-site remote", "a teammate", "one customer" — never IPs, SSH targets, vendors, remote paths, URLs/UUIDs, DB names, personal data, or quoted customer content.
- For a closed hole, state the new control — never the still-live weakness or incident forensics (timestamps, quotas, counts) — because both map the attack until rotation lands.
- Point at runbooks for operational facts instead of copying them into prose.
- Write for a reader without the operator's context: outcome and ask first, plain words, short sentences; keep the operator's direct voice.
- Before publishing, grep the draft for IPs, `://`, UUIDs, emails, and `pass|token|secret|key=`; fix every hit.
- After a leak: rotate, then scrub, then tell the user which history still holds it.

## To the operator

Write for a systems thinker: conclusion, decisive reason, next move. No reassurance, praise, hedging, or process recap; rationale only when it changes the decision. Match their depth — terser when terse, deeper when they ask why.

- Open with the outcome in one sentence, then only what they must decide or do, as short bullets.
- Manual work: one fenced block per shell that runs in a single paste — commands joined with `&&`, absolute paths, unknowns set once as `VAR=...` on line one — then one line naming the expected result. Offer the in-session form where the host has one (Claude Code: `! <cmd>`).
- A needed choice: one question with a recommended default.
