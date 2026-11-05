---
name: ticket
description: >-
  Investigate, challenge, implement, or create a ticket (Jira or GitHub issue),
  groom a backlog/board, and sync status after a PR. Use for ticket URLs/keys,
  incoming-ticket challenge, follow-ups under an epic, backlog cleanup, post-PR
  handoff.
---

# Ticket

## Pick branch

| Branch              | Signals                                                |
| ------------------- | ------------------------------------------------------ |
| implement (default) | Jira key/URL (`ABC-123`) or GitHub issue URL/`#N` |
| challenge           | review / gate an incoming ticket; `ops-github` ticket item |
| create              | "file a ticket", follow-up under an epic               |
| groom               | backlog/epic cleanup, reparent orphans, board sync after sequencing |
| Post-PR sync        | ticket has a new PR URL; "open PR + move to review"    |

## Shared prep

- **Tracker:** `<project>/.agents/tracker.md` (`kind: jira|github`, status names, link types, epic/parent field, team channel, portfolio link type); absent → infer from input, ask once if ambiguous, never guess across orgs. Load only the matching adapter ([`reference/jira.md`](reference/jira.md) | [`reference/github.md`](reference/github.md)); it owns every tracker call. Fetch fields, parent/epic, links, comments, attachments, linked docs; never ask the user to restate; mark assumed AC.
- **Product gate:** non-trivial user-facing scope → `product-owner` `gate`; continue on Build Now only. Multi-slice / UX-mandated AC → `product-owner` `story-slice` → `$dev` `plan`. Skip bug fix/refactor/infra.
- Observability/security cues, Assure, phase commits, land: `$dev` Shared prep + Handoff via **Handoff load** ([`../CONTEXT.md`](../CONTEXT.md)).

## Branch reference

### challenge

[`reference/challenge.md`](reference/challenge.md)

### implement

Fetch ticket + observability evidence; read code; gate → `$dev` `plan` → fresh branch `TICKET-ID-short-kebab-summary` → `$dev` `implement` → Handoff. PR ask → `pull-request` `open` → Post-PR sync. Interrupt only for real ambiguity or missing access.

### groom

[`reference/groom.md`](reference/groom.md)

### create

- Draft from code evidence; match type (story/task/bug) to the ask; don't implement unless asked.
- Parent under the named epic; verify; leave unhelpful default statuses (e.g. On Hold → Ready) unless asked.
- Link predecessors with the project's exact link type.
- Epic/parent has start and due dates and its portfolio link where the project has one.

### Status lifecycle

List available status changes first; apply if unambiguous, else ask once. Targets: created → **Ready** (or equivalent); started → **In Progress** only if asked or workflow-used; PR opened → **Ready for Review** (else `In Review`/`Code Review`, else ask); Done / Won't Do only as requested — never invent Done on merge.

Before closing as Done/duplicate/superseded (incl. completed epic/idea): comment a redirect naming the canonical target and team channel (`<project>/.agents/tracker.md` if configured); close with the matching reason, hidden from grouped views.

### Post-PR sync

After `pull-request` `open`: sync per Status lifecycle and adapter; comment PR URL + branch (sync even if commenting fails). Report ticket ID, status, PR URL; on failure, list status changes.

## Handoff

`$dev` Handoff plus: branch, commands run, PR URL, ticket status, residual risks. Unavailable skill → say so; continue locally.

## Completion criteria

- challenge: per [`reference/challenge.md`](reference/challenge.md).
- implement: `$dev` plan emitted; delivered per `$dev`; ticket synced if PR opened.
- groom: per [`reference/groom.md`](reference/groom.md).
- create: issue created; parent/epic verified; links and status correct.
- Post-PR sync: synced (or status changes listed) and reported.
