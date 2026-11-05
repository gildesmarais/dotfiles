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
| implement (default) | Jira URL or key (`ABC-123`) to implement |
| challenge           | review / gate an incoming ticket; `ops-github` ticket item |
| create              | "file a ticket", follow-up under an epic               |
| groom               | backlog/epic cleanup, reparent orphans, board sync after sequencing |
| Post-PR sync        | ticket has a new PR URL; "open PR + move to review"    |

## Shared prep

- Atlassian MCP required: fetch the ticket (fields, parent/epic, links, comments, attachments) and linked Confluence; never ask the user to restate it; mark assumed AC.
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

- `createJiraIssue`; draft from code evidence; match Story/Task/Bug to the ask; don't implement unless asked.
- Parent under the named epic (`parent` / Epic Link); verify; transition out of unhelpful defaults (e.g. On Hold → Ready) unless asked.
- Link predecessors via `getIssueLinkTypes` exact type name.
- Epic: set start/due dates; link its portfolio item if the project has one.

### Status lifecycle

`getTransitionsForJiraIssue` first; transition if unambiguous, else ask once.

| Event                             | Target                                                  |
| --------------------------------- | ------------------------------------------------------- |
| Ticket created                    | **Ready** (or equivalent)                               |
| Implementation started (optional) | **In Progress** — only if asked or workflow-used |
| PR opened                         | **Ready for Review**                                    |
| User asks Done / Won't Do         | As requested; never invent Done on merge                |

Before closing as Done / duplicate / superseded (incl. completed Epic/idea): comment a redirect naming the canonical target and team channel (`<project>/.agents/product.md` if configured); set the archive flag and terminal board-column field so grouped views hide it.

Review transition: `Ready for review` → `In Review` / `Code Review` → ask.

### Post-PR sync

After `pull-request` `open`: transition per the table; comment PR URL + branch if comment tools exist (transition even if the comment fails). Report key, status, PR URL; on failure, list transitions.

## Handoff

`$dev` Handoff plus: branch, commands run, PR URL, Jira status, residual risks. Unavailable skill → say so; continue locally.

## Completion criteria

- challenge: per [`reference/challenge.md`](reference/challenge.md).
- implement: `$dev` plan emitted; delivered per `$dev`; Jira synced if PR opened.
- groom: per [`reference/groom.md`](reference/groom.md).
- create: issue created; parent/epic verified; links and status correct.
- Post-PR sync: transitioned (or transitions listed) and reported.
