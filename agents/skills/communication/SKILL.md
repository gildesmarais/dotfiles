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

Load exactly one and follow it through completion:

- **`one-on-one`** → [`reference/one-on-one.md`](reference/one-on-one.md)
- **`slack-message`** → [`reference/slack-message.md`](reference/slack-message.md)
- **`project-update`** → [`reference/project-update.md`](reference/project-update.md)
- **`external-message`** → [`reference/external-message.md`](reference/external-message.md)

Every branch returns only the final artifact; add improvement notes only when asked.

## Handoff

README, runbook, or product doc rather than a message → stop → `docs` **`editor`** (never reverse; no long-form docs from this skill).

## Completion criteria

| Branch             | Done when                                                                                             |
| ------------------ | ----------------------------------------------------------------------------------------------------- |
| `one-on-one`       | Two-person dialogue summary (I/You voice), one bullet per topic, shareable with the other participant |
| `slack-message`    | Slack-ready internal message returned; sensitive framing applied when relevant                        |
| `project-update`   | Single comparable status line returned in required format (≤200 chars unless user asks otherwise)     |
| `external-message` | External message returned with no internal jargon, no unconfirmed commitments, legal-safe tone        |
