---
name: communication
description: >-
  Distill and draft written communication. Use to summarize raw one-on-one
  notes, refine an internal Slack message or announcement, distill a comparable
  project status update, draft a sprint recap and kickoff from Jira for a team
  channel, or draft a customer, partner, or public-facing message.
disable-model-invocation: true
---

# Communication

## Pick branch

Load exactly one reference. Every branch returns only the final artifact.

| User intent                                                                | Branch → reference                                                                    |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Summarize raw 1:1 notes into a shared two-person summary (I/You voice)     | `one-on-one` → [`reference/one-on-one.md`](reference/one-on-one.md)                   |
| Draft/refine an internal Slack message, announcement, or escalation        | `slack-message` → [`reference/slack-message.md`](reference/slack-message.md)          |
| Distill a project status line comparable across projects                   | `project-update` → [`reference/project-update.md`](reference/project-update.md)       |
| Sprint recap / kickoff from Jira for a team channel                        | `sprint-update` → [`reference/sprint-update.md`](reference/sprint-update.md)          |
| Draft a customer, partner, or public-facing message (email, support reply) | `external-message` → [`reference/external-message.md`](reference/external-message.md) |
| Marketing copy or public PR/press statement                                | out of scope                                                                          |

## Shared prep

Every branch, and any text leaving the workstation even without this skill: [`reference/outward-text.md`](reference/outward-text.md). Hosts load it always-on.

## Branch reference

Per the table; one reference only.

## Handoff

README, runbook, or product doc rather than a message → stop → `docs` `editor` (never reverse).

## Completion criteria

Per-branch Done when / output contract in the matched reference.
