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
| implement (default) | Jira URL or key (`ABC-123`) to investigate / implement |
| challenge           | review / challenge / gate an incoming ticket; `ops-github` ticket item |
| create              | "file a ticket", follow-up under an epic               |
| groom               | groom backlog, epic cleanup, reparent orphans, board sync after sequencing |
| Post-PR sync        | ticket has a new PR URL; "open PR + move to review"    |

## Shared prep

- Atlassian MCP required: fetch the ticket (fields, parent/epic, links, comments, attachments) and linked Confluence; never ask the user to restate it; mark missing-AC assumptions.
- **Product gate:** non-trivial user-facing scope → `product-owner` `gate`; continue on Build Now only. Multi-slice / UX-mandated AC → `product-owner` `story-slice` → `$dev` `plan`. Skip for bug fix/refactor/infra.
- Observability/security cues, Assure, phase commits, land: `$dev` Shared prep + Handoff via **Handoff load** ([`../CONTEXT.md`](../CONTEXT.md)).

## Branch reference

### challenge

[`reference/challenge.md`](reference/challenge.md)

### implement

Fetch ticket + observability evidence; read code; gate → `$dev` `plan` → fresh branch `TICKET-ID-short-kebab-summary` → `$dev` `implement` → Handoff. PR ask → `pull-request` `open` → Post-PR sync. Interrupt only on real ambiguity or missing access.

### groom

[`reference/groom.md`](reference/groom.md)

### create

- `createJiraIssue`; draft from code evidence; match Story/Task/Bug to the ask. Don't implement unless asked.
- Parent under the named epic (`parent` / Epic Link); verify after create; transition out of unhelpful defaults (e.g. On Hold → Ready) unless asked.
- Link predecessors: `getIssueLinkTypes` → exact type name.
- Epic: set start/due dates; link its portfolio item if the project has one.

### Status lifecycle

`getTransitionsForJiraIssue` first; transition when unambiguous, else ask once.

| Event                             | Target                                                  |
| --------------------------------- | ------------------------------------------------------- |
| Ticket created                    | **Ready** (or equivalent)                               |
| Implementation started (optional) | **In Progress** — only if asked or the workflow uses it |
| PR opened                         | **Ready for Review**                                    |
| User asks Done / Won't Do         | As requested — never invent Done on merge               |

Before closing as Done / duplicate / superseded, comment a redirect naming the canonical target and team channel.

Review transition: `Ready for review` → `In Review` / `Code Review` → ask.

### Post-PR sync

After `pull-request` `open`: transition per the table, comment PR URL + branch if comment tools exist (transition even if the comment fails). Report key, status, PR URL; on failure list transitions.

## Handoff

`groom` Create adding user-facing scope → `product-owner` `gate`. `$dev` Handoff plus: branch, commands run, PR URL, Jira status after sync, residual risks. Unavailable skill → say so; continue locally.

## Completion criteria

- challenge: per [`reference/challenge.md`](reference/challenge.md).
- implement: `$dev` plan emitted; delivered per `$dev`; Jira synced if a PR opened.
- groom: per [`reference/groom.md`](reference/groom.md).
- create: issue created with verified parent/epic, correct links and status.
- Post-PR sync: transitioned (or transitions listed) and reported.
