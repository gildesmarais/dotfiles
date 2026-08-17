---
name: jira-ticket
description: >-
  Investigate, scope, implement, or create a Jira ticket with Atlassian MCP;
  sync status (e.g. Ready for Review after PR open); use observability MCP when
  the issue links APM/errors/logs. Use for Jira URLs/keys, follow-up ticket
  creation under an epic, and post-PR Jira handoff.
---

# Jira Ticket

## Overview

Use this skill to turn a Jira ticket into an implementation workflow for this repository—
or to **create** a well-scoped follow-up ticket from session evidence.

Start from the ticket (or create ask), gather evidence with Atlassian MCP, verify the
codebase locally, route into the required repo skills, propose a concrete implementation
plan via `$dev` **`plan`**, and after user agreement execute autonomously until blocked—
then post-delivery Assure before reporting done. When a PR is opened for the ticket,
**half-automatically** move the issue to review (see [Jira status lifecycle](#jira-status-lifecycle)).

## Inputs

- Accept either a Jira URL or a Jira key such as `ABC-123`.
- Normalize the ticket key immediately and use it consistently in branch names, status updates, and handoff.
- **Create:** when the user asks to file a ticket (often under an epic), use Atlassian MCP
  `createJiraIssue` — do not invent keys. Prefer Story/Task/Bug to match the ask; set
  epic via `parent` and/or project Epic Link field; link related work with the project’s
  real link type name (e.g. `Related to`, not `Relates` unless that type exists).

## Hard Requirements

- Use Atlassian MCP. Do not rely on copied ticket text alone when Jira is accessible.
- Verify you are in the correct repository before planning or editing code.
- Read the local code before making claims. Scan files and contracts; do not assume architecture from the ticket wording.
- If the ticket or linked material cites APM / traces, error tracking, or logging links/IDs, use the matching observability MCP when available; fold findings into the assessment.
- Follow repository routing from `AGENTS.md`.

## Workflow

1. Normalize the ticket input (or create the issue first if the ask is “file a ticket”).
2. Verify the repository and load repo-specific context.
3. Fetch and assess Jira details with Atlassian MCP.
4. Fetch observability evidence when the Jira issue references APM / errors / logs artifacts (vendor map below when Datadog links match).
5. Read the code and determine the affected surface area.
6. If scope is non-trivial user-facing product work, run `product-owner` `gate` before planning impl; stop on Build Later / Research Further / Reject.
7. Load `$dev` **`plan`** (and required runtime/review skills) for the Planning Checkpoint when phases/commits matter.
8. Present a concise implementation assessment and proposed branch name, then wait for user agreement.
9. After agreement, create a fresh branch from the default branch and implement autonomously via `$dev` **`implement`**.
10. Run post-delivery Assure (`review.gil` — spawn preferred), quality gates, summarize validation evidence.
11. When the user asks to open a PR (or this flow continues into `pull-request` **`open`**), open the PR, then run [Post-PR Jira sync](#post-pr-jira-sync). Stop when the branch is ready to push/open a PR if the user has not asked to land yet.

## Repository Verification

- Confirm the current workspace matches the intended codebase before doing substantive work.
- Check for repository signals such as `AGENTS.md`, Rails app structure, and the expected stack.
- Treat `AGENTS.md` in the current repository as authoritative for routing, precedence, guardrails, and default branch.
- If the ticket clearly belongs to another repository, stop and say so.

## Jira Investigation

- Use Atlassian MCP to fetch the Jira issue directly from the normalized key or URL.
- Gather at least: summary, description, status, type, priority, labels, assignee, parent/epic if relevant, linked issues, comments, attachments or linked Confluence material if they materially affect scope.
- Distinguish facts from inference. If acceptance criteria are missing, derive the smallest defensible implementation scope from the evidence and mark the assumption explicitly.
- If the ticket references a Confluence page, use Atlassian MCP to read the page rather than relying on title-only search snippets.

## Create ticket (when asked)

- Draft summary + description from **code-backed evidence** (paths, keys, blast radius, AC), not vague intent.
- Prefer parenting under the epic the user named (`parent` / Epic Link).
- After create: verify parent/epic; if the issue lands in an unhelpful default (e.g. **On Hold**), transition to **Ready** (or the project’s backlog-ready status) unless the user asked to leave it held.
- Link predecessors with `getIssueLinkTypes` → correct type name (Caspar: often `Related to`).
- Do **not** start implement unless the user also asked to implement.

## Observability evidence

- If linked APM / errors / logs appear, use the MCP that matches the link host/product when present. Do not invent a vendor encyclopedia; discover tools on the matching server when those links appear.
- Inspect the Jira issue text, comments, remote links, and linked documentation for observability URLs or IDs.
- **When Datadog links appear** (host/product match), use Datadog MCP to inspect the linked artifacts instead of treating the link as decoration. Prefer direct retrieval tools when the URL yields a concrete identifier:
  - incident → `get_datadog_incident`
  - notebook → `get_datadog_notebook`
  - trace → `get_datadog_trace`
  - **error-tracking issue** (UUID in `/error-tracking/issue/<uuid>`) → error-tracking tools when the toolset is enabled; **fallback** if unavailable: `search_datadog_spans` / logs with `@issue.id:<uuid>` or `@error.message:…` over a window covering first-seen → now
- Use search tools for dashboards, monitors, logs, spans, services, or when only partial identifiers are available.
- Pull only the evidence needed to understand the bug, affected services, blast radius, and validation targets.
- Fold observability findings back into the implementation plan and test strategy.

## Code Reading Discipline

- Search the codebase for ticket terms, error messages, model names, endpoint paths, feature flags, and domain nouns from Jira and observability evidence.
- Read the surrounding implementation, not just the first textual match.
- Verify existing contracts in controllers, services, policies, serializers, workers, routes, migrations, specs, and documentation when relevant.
- Identify tenant scoping, authorization, structured logging, and retry/idempotency behavior when they may be affected.

## Skill Routing

- **Product gate:** Before non-trivial user-facing scope (new feature, UI/API surface, parity ask, UAT-driven expansion), load `product-owner` branch `gate`. Continue implementation only on **Build Now**. Skip the Product gate for pure bug fix, refactor, or infra with no user-facing concept or step change. Never let `architecture` / `dev` / `*-dev` / `review.gil` answer “should we build X?”
- Load `$dev` for implementation discipline; it routes the runtime (`ruby-dev`, `rust-dev`, …) and overlays (`ruby-on-rails-dev`, `swiftui-dev`, …) from the change surface. Planning Checkpoint uses `$dev` **`plan`**; post-agreement coding uses `$dev` **`implement`**.
- Add the `review.gil` skill with explicit security focus whenever the work matches the `AGENTS.md` security trigger matrix (or `$dev` security cue). Default to invoking it when authn/authz, tenancy, PII/PHI, exports, webhooks, raw SQL, external fetches, or sensitive Sidekiq behavior may change.
- **Land / PR:** use `pull-request` **`open`** (do not reimplement PR narrative here). After a PR URL exists, run [Post-PR Jira sync](#post-pr-jira-sync).
- Follow `AGENTS.md` precedence if guidance overlaps.
- If a referenced skill is unavailable in the current environment, say so explicitly and continue with the closest applicable local workflow instead of blocking.

## Planning Checkpoint

Before creating a branch or editing code, emit the plan via / load `$dev` **`plan`** (especially when phases/commits matter), then provide a concise checkpoint covering:

- `Ticket facts`: verified Jira facts that define scope.
- `Files read`: the code areas you actually inspected.
- `Skills required`: whether `product-owner` gate ran (or was skipped and why), which `$dev` runtime (+ overlay) is required, whether security-focused `review.gil` is required, plus why.
- `Branch name`: the proposed branch name.
- `Implementation plan`: the `$dev` **`plan`** output — ordered phases each ending validate→commit (cite CONTEXT), classification, residual risk.
- `Assumptions`: key assumptions or open questions.

Wait for explicit user agreement at this point.

## Branch Creation

- Start from a fresh default branch as defined by `AGENTS.md` or the repository's configured git default branch.
- Refresh the default branch before branching when possible.
- Name the branch as:
  `TICKET-ID-short-kebab-summary`
- The branch must start with the Jira key exactly, for example:
  `ABC-123-undefined-method-values-for-an-instance-of-array`
- Slugify the summary: lowercase, ASCII, hyphen-separated, trim filler words where helpful, and keep it readable.

## Implementation Mode

After the user agrees:

- Create the branch from the fresh default branch.
- Implement autonomously via `$dev` **`implement`**.
- Interrupt only when blocked by a real ambiguity, missing access, failing environment prerequisite, or a decision that would be risky to guess.
- Keep diffs minimal and cohesive.
- Do not revert unrelated user changes (leave unrelated dirty/untracked files alone).
- Prefer targeted tests first, then broader validation as needed.

## Validation And Handoff

- Run the project’s relevant quality gates for the changed surface area.
- **Post-delivery Assure:** before reporting delivery, prefer spawning a **new agent** that runs `review.gil` (default: **`findings`** (+ warranted lenses); include **`security`** when the security cue / matrix matched). Invoke **`quality`** when in scope (explicit merge-prep / boy-scout, or clear fixable P0/P1 already authorized — never infer from bare “review”). **Fallback:** if Task/subagent is unavailable, run `review.gil` as a fresh in-session pass (reload skill; do not reuse implementer judgment as the sole review). Report delivery only after that pass returns. If user asked to land and readiness is Yes/Conditional → continue with `pull-request` **`open`**, then [Post-PR Jira sync](#post-pr-jira-sync).
- Report concrete validation evidence, not vague claims.
- State whether the required skills were invoked.
- Stop when the branch is ready to push and a PR can be opened (unless the user already asked to open).
- Final handoff should include:
  branch name, change summary, commands run, pass/fail status, Assure outcome, residual risks, PR URL if opened, Jira status after sync, and whether further land steps remain.

## Jira status lifecycle

Half-automatic: **do the transition without asking** when the mapping is unambiguous; **ask once** only if no matching transition exists or several conflict.

| Event                             | Target status (prefer by name)    | How                                                                                               |
| --------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------- |
| Ticket created for backlog work   | **Ready** (or project equivalent) | `getTransitionsForJiraIssue` → transition; skip if already Ready / In Progress / Ready for Review |
| Implementation started (optional) | **In Progress**                   | Only if user asked or workflow already uses it; do not force                                      |
| **PR opened** for this ticket     | **Ready for Review**              | See [Post-PR Jira sync](#post-pr-jira-sync)                                                       |
| User asks Done / Won't Do / etc.  | As requested                      | Never invent Done on merge unless asked                                                           |

Resolution order for review transition names (case-insensitive match on transition **name** or target status **name**):

1. `Ready for review` / `Ready for Review`
2. `In Review` / `Code Review`
3. Ask the user with the available transition list

Always call `getTransitionsForJiraIssue` for the **current** issue before transitioning; IDs are project-specific.

## Post-PR Jira sync

Run whenever this skill’s ticket has a newly created PR URL (same session as `pull-request` **`open`**, or user said “open PR and move ticket to review”).

1. Confirm PR URL (e.g. `gh pr view --json url`).
2. `getTransitionsForJiraIssue` for the normalized ticket key.
3. Transition to **Ready for Review** per [Jira status lifecycle](#jira-status-lifecycle).
4. If comment tools are available, add a short Jira comment with the PR URL (and branch name). Skip commenting if MCP lacks a safe comment tool or it fails—still complete the transition.
5. Report: ticket key, new status, PR URL. If transition failed, say so and list available transitions; do not silently skip.

Do **not** require the user to restate “move to Ready for Review” when they already asked to open the PR for a jira-ticket flow; treat review sync as part of landing.

## Output Discipline

- Keep status updates concise and evidence-based.
- When facts are uncertain, label them as assumptions.
- Do not ask the user to restate Jira details that can be fetched through Atlassian MCP.
