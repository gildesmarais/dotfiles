---
name: ops-slack
description: >-
  Slack digest of chores still waiting and prod health still open, each with
  its permalink. Use for /ops-slack, check my slack, health and chore, less
  noise, or where that was posted.
disable-model-invocation: true
---

# Ops Slack

Read Slack. Return chores and prod health that still need the operator, each with its permalink. Never post, draft, or schedule.

## Pick branch

Default and only branch: **`digest`**.

Skip: PR and issue queues → `ops-github`; service APM review → `ops-chore`; he asks to work a live incident → `triage` after the digest names it.

## Shared prep

1. Slack search and read tools only. Ask mode blocks them: say so and stop.
2. Load operator Slack user id, pager/incident/excluded channel ids, and chronic monitor exclusions from `<project>/.agents/tracker.md` (`## Slack digest`), or `~/.local/state/ops-slack/config.md` outside a project; ask once if absent. Mentions use `to:<@<operator-id>>`. Window: local yesterday 00:00 through now. `is:saved` has no date limit; keep a saved item only when the ask is still unanswered.
3. Do not write to Slack. Do not quote a secret; point at the message to delete.

## Branch reference

- **`digest`** — [`reference/digest.md`](reference/digest.md)

## Handoff

Digest only. A named review → `review.gil` when asked. A monitor worth retuning → `trustworthy-alerts`. A live outage he asks to work → `triage`.

## Completion criteria

Lead sentence, **Do**, **Health**, one line of what was dropped. Every kept item has a permalink. No Slack writes. No secret values.
