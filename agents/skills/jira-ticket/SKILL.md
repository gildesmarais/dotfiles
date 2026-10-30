---
name: jira-ticket
description: >-
  Investigate, scope, implement, or create a Jira ticket via Atlassian MCP and
  sync its status (e.g. Ready for Review after PR open). Use for Jira URLs/keys,
  follow-up tickets under an epic, and post-PR Jira handoff.
disable-model-invocation: true
---

# Jira Ticket

## Pick branch

| Branch              | Signals                                                |
| ------------------- | ------------------------------------------------------ |
| implement (default) | Jira URL or key (`ABC-123`) to investigate / implement |
| create              | "file a ticket", follow-up under an epic               |
| Post-PR sync        | ticket has a new PR URL; "open PR + move to review"    |

## Shared prep

- Atlassian MCP required: fetch the ticket (fields, parent/epic, links, comments, attachments) and linked Confluence rather than relying on pasted text or asking the user to restate it. Mark missing-AC assumptions.
- Verify the correct repository before planning or editing.
- **Product gate:** non-trivial user-facing scope → `product-owner` `gate`; continue on Build Now only. Multi-slice / UX-mandated AC → `product-owner` `story-slice` → `$dev` `plan`. Skip for pure bug fix/refactor/infra.
- Observability/security cues, Assure, phase commits, land: `$dev` Shared prep + Handoff.

## Branch reference

### implement

Fetch ticket + observability evidence; read code; gate if applicable → `$dev` `plan` → fresh branch `TICKET-ID-short-kebab-summary` → `$dev` `implement` → Handoff. PR ask → `pull-request` `open` → Post-PR sync. Interrupt only on real ambiguity, missing access, or risky guesses.

### create

- `createJiraIssue`; draft from code-backed evidence; match Story/Task/Bug to the ask. Don't implement unless also asked.
- Parent under the named epic (`parent` / Epic Link); verify after create; transition out of unhelpful defaults (e.g. On Hold → Ready) unless asked to hold.
- Link predecessors: `getIssueLinkTypes` → exact type name.

### Status lifecycle

Always `getTransitionsForJiraIssue` first; transition without asking when unambiguous, ask once if transitions conflict.

| Event                             | Target                                                  |
| --------------------------------- | ------------------------------------------------------- |
| Ticket created                    | **Ready** (or equivalent)                               |
| Implementation started (optional) | **In Progress** — only if asked or the workflow uses it |
| PR opened                         | **Ready for Review**                                    |
| User asks Done / Won't Do         | As requested — never invent Done on merge               |

Review transition preference: `Ready for review` → `In Review` / `Code Review` → ask with the transition list.

### Post-PR sync

After `pull-request` `open`: confirm the PR URL, transition per the table above, comment PR URL + branch if comment tools exist (on comment failure still transition). Report key, new status, PR URL; on failure list available transitions.

## Handoff

`$dev` Handoff plus: branch name, commands run, PR URL if opened, Jira status after sync, residual risks.

## Completion criteria

- implement: `$dev` plan emitted; delivered per `$dev`; Jira synced if a PR opened.
- create: issue created with verified parent/epic, correct links and status.
- Post-PR sync: transitioned (or transitions listed) and reported.
