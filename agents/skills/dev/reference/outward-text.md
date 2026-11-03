---
description: Outward-text hygiene — no secrets, host identifiers, live weaknesses, or incident forensics in published text
alwaysApply: true
---

# Outward text

Always-on for text that leaves the workstation: PR titles/bodies, commit messages, issue/PR/review comments, release notes, chat posts, artifacts. Private repos included — GitHub keeps PR/comment edit history and commits are hard to rewrite, so a later scrub never removes a value.

## Checklist

- When drafting outward text, always describe the fix in generic roles ("the production host", "an off-site remote", "a heartbeat ping", "provider snapshots") to prevent leaking host IPs, SSH targets, storage vendors and remote paths, heartbeat URLs/UUIDs, or production DB names.
- When a change closes a hole, always state the new control, never the still-live weakness ("passphrase was hardcoded", "old key valid until X", "bound to `*`") or incident forensics (outage timestamps, quota numbers, leaked-file counts), to prevent handing out a map before rotation lands.
- Before `gh pr create|edit`, `gh * comment`, a release, or a commit with a body, always grep the draft for IPs, `://`, UUIDs, and `pass|token|secret|key=` and fix every hit, because scrubbing after publish leaves the edit history.

## Anti-patterns

- Avoid copying runbook facts into PR prose; code and runbooks may name operational facts the procedure needs (never secret values), the narrative points at them instead.
- Avoid silent cleanup after a leak; rotate the value first, then scrub, then tell the user that edit history and commit messages still hold it.
