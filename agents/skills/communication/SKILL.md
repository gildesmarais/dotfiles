---
name: communication
description: >-
  Distill and draft written communication. Use to summarize raw one-on-one
  notes, refine an internal Slack message or announcement, distill a comparable
  project status update, or draft a customer, partner, or public-facing message.
---

# Communication

## Pick branch

| User intent                                                                | Branch             |
| -------------------------------------------------------------------------- | ------------------ |
| Summarize raw 1:1 notes into a shared two-person summary (I/You voice)     | `one-on-one`       |
| Draft/refine an internal Slack message, announcement, or escalation        | `slack-message`    |
| Distill a project status line comparable across projects                   | `project-update`   |
| Draft a customer, partner, or public-facing message (email, support reply) | `external-message` |
| Marketing copy or public PR/press statement                                | out of scope       |

## Branch reference

Load exactly one:

- **`one-on-one`** → [`reference/one-on-one.md`](reference/one-on-one.md)
- **`slack-message`** → [`reference/slack-message.md`](reference/slack-message.md)
- **`project-update`** → [`reference/project-update.md`](reference/project-update.md)
- **`external-message`** → [`reference/external-message.md`](reference/external-message.md)

Every branch returns only the final artifact; add improvement notes only when asked.

## Handoff

README, runbook, or product doc rather than a message → stop → `docs` **`editor`** (never reverse).

## Completion criteria

Per-branch Done when / output contract in the matched reference.
