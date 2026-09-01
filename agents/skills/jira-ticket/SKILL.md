---
name: jira-ticket
description: >-
  Investigate, scope, implement, or create a Jira ticket with Atlassian MCP;
  sync status (e.g. Ready for Review after PR open); use observability MCP when
  the issue links APM/errors/logs. Use for Jira URLs/keys, follow-up ticket
  creation under an epic, and post-PR Jira handoff.
---

# Jira Ticket

Turn a Jira ticket into an implementation workflow — or **create** a well-scoped follow-up from session evidence.

Start from the ticket (or create ask), gather evidence with Atlassian MCP, verify the codebase, route via `$dev` **`plan`** then **`implement`**, follow `$dev` Shared prep + Handoff for observability, product gate, Assure, phase commits, and land. When a PR opens for the ticket, run [Post-PR Jira sync](#post-pr-jira-sync).

## Inputs

- Accept a Jira URL or key (`ABC-123`). Normalize immediately; use consistently in branch names, status, handoff.
- **Create:** use Atlassian MCP `createJiraIssue` — do not invent keys. Match Story/Task/Bug to the ask; set epic via `parent` / Epic Link; link with the project's real link type (e.g. `Related to`).

## Hard Requirements

- Use Atlassian MCP — do not rely on copied ticket text when Jira is accessible.
- Verify the correct repository before planning or editing (`AGENTS.md` is authoritative).
- Read local code before claims; do not assume architecture from ticket wording.
- Follow `$dev` Shared prep (observability cue, security cue, product gate, Assure, phase commits).

## Workflow

1. Normalize input (or create issue if "file a ticket").
2. Verify repository and load repo context.
3. Fetch Jira details with Atlassian MCP.
4. Fetch observability evidence when issue links APM/errors/logs (see below).
5. Read code; determine affected surface.
6. Non-trivial user-facing scope → `product-owner` **`gate`**; stop on Build Later / Research Further / Reject.
7. Planning Checkpoint via `$dev` **`plan`** when phases/commits matter.
8. Present assessment + proposed branch name; wait for agreement.
9. Fresh branch from default → implement via `$dev` **`implement`**.
10. Post-delivery Assure + validation per `$dev` Handoff.
11. PR ask → `pull-request` **`open`** → [Post-PR Jira sync](#post-pr-jira-sync).

## Jira Investigation

- Fetch: summary, description, status, type, priority, labels, assignee, parent/epic, links, comments, attachments, linked Confluence.
- Distinguish facts from inference; mark missing AC assumptions explicitly.
- Confluence references → read via Atlassian MCP, not title-only snippets.

## Create ticket (when asked)

- Draft summary + description from **code-backed evidence** (paths, keys, blast radius, AC).
- Parent under named epic; after create verify parent/epic; transition from unhelpful defaults (e.g. On Hold → Ready) unless user asked to hold.
- Link predecessors via `getIssueLinkTypes` → correct type name.
- Do **not** implement unless user also asked to implement.

## Observability evidence

When Jira links APM/errors/logs, use the matching observability MCP (discover tools on the server when links appear).

**Datadog links** (when host matches): incident → `get_datadog_incident`; notebook → `get_datadog_notebook`; trace → `get_datadog_trace`; error-tracking UUID → error-tracking tools or `search_datadog_spans` / logs with `@issue.id:<uuid>`.

Fold findings into plan and test strategy. Details: `$dev` observability cue.

## Code Reading

Search for ticket terms, errors, models, paths, flags, domain nouns. Read surrounding implementation, not first match. Check contracts in controllers, services, policies, serializers, workers, routes, migrations, specs when relevant.

## Skill Routing

- **Product gate:** non-trivial user-facing scope → `product-owner` **`gate`**; **Build Now** only. Skip for pure bugfix/refactor/infra.
- **Build:** `$dev` **`plan`** / **`implement`** (routes runtime + overlays from change surface).
- **Assure / land:** `$dev` Handoff → `review.gil` / `pull-request` **`open`**.
- Unavailable skill → say so; continue closest local workflow.

## Planning Checkpoint

Before branching, emit `$dev` **`plan`**, then provide:

- `Ticket facts` · `Files read` · `Skills required` (gate skip/rationale, runtime, security review if needed)
- `Branch name` · `Implementation plan` · `Assumptions`

Wait for explicit agreement.

## Branch Creation

Fresh default branch. Name: `TICKET-ID-short-kebab-summary` (key exact prefix, lowercase ASCII slug).

## Implementation Mode

After agreement: branch → `$dev` **`implement`**. Interrupt only on real ambiguity, missing access, risky guess. Minimal cohesive diffs; do not revert unrelated user changes.

## Validation And Handoff

Follow `$dev` Handoff (Assure, land, Delivery Ledger). Final handoff adds: branch name, commands run, PR URL if opened, Jira status after sync, residual risks.

## Jira status lifecycle

Half-automatic: transition without asking when unambiguous; ask once if transitions conflict.

| Event                             | Target status             | How                                       |
| --------------------------------- | ------------------------- | ----------------------------------------- |
| Ticket created                    | **Ready** (or equivalent) | `getTransitionsForJiraIssue` → transition |
| Implementation started (optional) | **In Progress**           | Only if user asked or workflow uses it    |
| **PR opened**                     | **Ready for Review**      | [Post-PR Jira sync](#post-pr-jira-sync)   |
| User asks Done / Won't Do         | As requested              | Never invent Done on merge unless asked   |

Review transition name order: `Ready for review` → `In Review` / `Code Review` → ask user with transition list.

Always `getTransitionsForJiraIssue` for current issue before transitioning.

## Post-PR Jira sync

Run when ticket has a new PR URL (same session as `pull-request` **`open`**, or user said open PR + move to review).

1. Confirm PR URL (`gh pr view --json url`).
2. `getTransitionsForJiraIssue` for ticket key.
3. Transition to **Ready for Review** per lifecycle table.
4. Comment with PR URL + branch if comment tools available (skip on failure — still transition).
5. Report: key, new status, PR URL; on failure list available transitions.

Do not require user to restate "Ready for Review" when they already asked to open the PR.

## Output Discipline

Concise, evidence-based updates. Label assumptions. Do not ask user to restate Jira details fetchable via MCP.
