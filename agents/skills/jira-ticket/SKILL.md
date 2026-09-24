---
name: jira-ticket
description: >-
  Investigate, scope, implement, or create a Jira ticket via Atlassian MCP and
  sync its status (e.g. Ready for Review after PR open). Use for Jira URLs/keys,
  follow-up tickets under an epic, and post-PR Jira handoff.
---

# Jira Ticket

## Pick branch

| Branch              | Signals                                                |
| ------------------- | ------------------------------------------------------ |
| implement (default) | Jira URL or key (`ABC-123`) to investigate / implement |
| create              | "file a ticket", follow-up under an epic               |
| Post-PR sync        | ticket has a new PR URL; "open PR + move to review"    |

## Shared prep

- Normalize the key immediately; use it consistently in branch name, status, handoff.
- Atlassian MCP is required — never rely on copied ticket text when Jira is accessible; never ask the user to restate fetchable details. Fetch summary, description, status, type, priority, labels, assignee, parent/epic, links, comments, attachments; read linked Confluence via MCP (not title snippets). Mark missing-AC assumptions.
- Verify the correct repository before planning or editing (`AGENTS.md` is authoritative).
- Observability cue: [`../CONTEXT.md`](../CONTEXT.md); no vendor recipes. Fold evidence into plan and test strategy.
- **Product gate:** non-trivial user-facing scope → `product-owner` `gate`; continue on Build Now only (stop on Build Later / Research Further / Reject). Multi-slice / UX-mandated AC → `product-owner` `story-slice` → `$dev` `plan`. Skip for pure bug fix/refactor/infra.
- Everything else (security cue, Assure, phase commits, land) follows `$dev` Shared prep + Handoff.

## Branch reference

### implement

1. Fetch ticket + observability evidence; read code; gate if applicable.
2. Emit `$dev` `plan` (include ticket facts, files read, skills required, branch name, assumptions in the plan or session notes). Delivery offer is the consent gate — [`../CONTEXT.md`](../CONTEXT.md).
3. Fresh branch from the default branch named `TICKET-ID-short-kebab-summary` (exact key prefix, lowercase ASCII slug) → `$dev` `implement`. Interrupt only on real ambiguity, missing access, or risky guesses.
4. Post-delivery Assure per `$dev` Handoff; PR ask → `pull-request` `open` → Post-PR sync.

### create

- Use `createJiraIssue`; never invent keys. Draft from code-backed evidence (paths, keys, blast radius, AC); match Story/Task/Bug to the ask.
- Parent under the named epic (`parent` / Epic Link); verify parent/epic after create; transition out of unhelpful defaults (e.g. On Hold → Ready) unless asked to hold.
- Link predecessors: `getIssueLinkTypes` → exact type name (e.g. `Related to`).
- Don't implement unless also asked.

### Status lifecycle

Transition without asking when unambiguous; ask once if transitions conflict. Always `getTransitionsForJiraIssue` for the issue first.

| Event                             | Target                                                  |
| --------------------------------- | ------------------------------------------------------- |
| Ticket created                    | **Ready** (or equivalent)                               |
| Implementation started (optional) | **In Progress** — only if asked or the workflow uses it |
| PR opened                         | **Ready for Review**                                    |
| User asks Done / Won't Do         | As requested — never invent Done on merge               |

Review transition name order: `Ready for review` → `In Review` / `Code Review` → ask with the transition list.

### Post-PR sync

Run in the same session as `pull-request` `open` (don't require the user to restate "Ready for Review"):

1. Confirm PR URL (`gh pr view --json url`).
2. `getTransitionsForJiraIssue` → transition to Ready for Review per the table.
3. Comment PR URL + branch if comment tools exist (on failure still transition).
4. Report key, new status, PR URL; on failure list available transitions.

## Handoff

`$dev` Handoff (Assure, land, Delivery Ledger) plus: branch name, commands run, PR URL if opened, Jira status after sync, residual risks. Unavailable skill → say so; continue the closest local workflow.

## Completion criteria

- implement: `$dev` plan emitted; delivery offer handled; delivered per `$dev`; Jira synced if a PR opened.
- create: issue created with verified parent/epic, correct links and status.
- Post-PR sync: transitioned (or transitions listed) and reported.
