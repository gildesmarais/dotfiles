---
name: communication
description: >
  Distill and draft written communication. Use when summarizing raw one-on-one
  notes, refining an internal Slack message or announcement, distilling a
  comparable project status update, or drafting a customer, partner, or
  public-facing message.
---

# Communication

Drafting or distilling a written communication artifact for a specific audience and format.

## Pick branch

Map the user prompt to exactly one branch:

| User intent                                                                | Branch                                    |
| -------------------------------------------------------------------------- | ----------------------------------------- |
| Summarize raw 1:1 / speaker-attributed notes                               | `one-on-one`                              |
| Draft/refine an internal Slack message, announcement, or escalation        | `slack-message`                           |
| Distill a project status line comparable across projects                   | `project-update`                          |
| Draft a customer, partner, or public-facing message (email, support reply) | `external-message`                        |
| Draft marketing copy or public PR/press statement                          | out of scope — no branch handles this yet |

When the ask is actually a README, runbook, or product doc rather than a message, use the `docs` skill instead.

## Branch reference

Load exactly one disclosed reference file and follow it through completion:

- **`one-on-one`** → [`reference/one-on-one.md`](reference/one-on-one.md)
- **`slack-message`** → [`reference/slack-message.md`](reference/slack-message.md)
- **`project-update`** → [`reference/project-update.md`](reference/project-update.md)
- **`external-message`** → [`reference/external-message.md`](reference/external-message.md)

## Handoff

When the ask is a README, runbook, or product doc rather than a message, stop and continue with the `docs` skill **`editor`** branch. Do not draft long-form documentation from this skill.

## Completion criteria

| Branch             | Done when                                                                                         |
| ------------------ | ------------------------------------------------------------------------------------------------- |
| `one-on-one`       | Compact speaker-aware bullet summary returned (usually 4–6 bullets)                               |
| `slack-message`    | Slack-ready internal message returned; sensitive framing applied when relevant                    |
| `project-update`   | Single comparable status line returned in required format (≤200 chars unless user asks otherwise) |
| `external-message` | External message returned with no internal jargon, no unconfirmed commitments, legal-safe tone    |
