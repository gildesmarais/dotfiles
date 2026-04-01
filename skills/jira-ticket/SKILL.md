---
name: jira-ticket
description: "Investigate, scope, and implement a Jira ticket in this repository from a ticket URL or key such as ABC-123. Use when work starts from Jira, must use Atlassian MCP to gather issue details, may need Datadog MCP for linked observability evidence, must verify the current codebase before changing code, and should branch from a fresh default branch before autonomous implementation."
---

# Jira Ticket

## Overview

Use this skill to turn a Jira ticket into an implementation workflow for this repository.
Start from the ticket, gather evidence with Atlassian MCP, verify the codebase locally, route into the required repo skills, propose a concrete implementation plan, and after user agreement execute autonomously until blocked.

## Inputs

- Accept either a Jira URL or a Jira key such as `ABC-123`.
- Normalize the ticket key immediately and use it consistently in branch names, status updates, and handoff.

## Hard Requirements

- Use Atlassian MCP. Do not rely on copied ticket text alone when Jira is accessible.
- Verify you are in the correct repository before planning or editing code.
- Read the local code before making claims. Scan files and contracts; do not assume architecture from the ticket wording.
- If the ticket or linked Jira material contains Datadog links, use Datadog MCP to inspect the linked artifacts and include the findings in your assessment.
- Follow repository routing from `AGENTS.md`.

## Workflow

1. Normalize the ticket input.
2. Verify the repository and load repo-specific context.
3. Fetch and assess Jira details with Atlassian MCP.
4. Fetch Datadog evidence when the Jira issue references Datadog artifacts.
5. Read the code and determine the affected surface area.
6. Invoke the required implementation/review skills.
7. Present a concise implementation assessment and proposed branch name, then wait for user agreement.
8. After agreement, create a fresh branch from the default branch and implement autonomously.
9. Run quality gates, summarize validation evidence, and stop when the work is ready to push and open a PR.

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

## Datadog Evidence

- Inspect the Jira issue text, comments, remote links, and linked documentation for Datadog URLs or IDs.
- When Datadog evidence exists, use Datadog MCP to inspect the relevant object instead of treating the link as decoration.
- Prefer direct retrieval tools when the URL yields a concrete identifier:
  incident -> `get_datadog_incident`
  notebook -> `get_datadog_notebook`
  trace -> `get_datadog_trace`
- Use search tools for dashboards, monitors, logs, spans, services, or when only partial identifiers are available.
- Pull only the evidence needed to understand the bug, affected services, blast radius, and validation targets.
- Fold Datadog findings back into the implementation plan and test strategy.

## Code Reading Discipline

- Search the codebase for ticket terms, error messages, model names, endpoint paths, feature flags, and domain nouns from Jira and Datadog.
- Read the surrounding implementation, not just the first textual match.
- Verify existing contracts in controllers, services, policies, serializers, workers, routes, migrations, specs, and documentation when relevant.
- Identify tenant scoping, authorization, structured logging, and retry/idempotency behavior when they may be affected.

## Skill Routing

- Always invoke `$ruby-dev` for implementation discipline.
- Add `$ruby-on-rails-dev` when Rails or API layers are in scope.
- Add `$review-security-compliance` whenever the work matches the `AGENTS.md` security trigger matrix. Default to invoking it when authn/authz, tenancy, PII/PHI, exports, webhooks, raw SQL, external fetches, or sensitive Sidekiq behavior may change.
- Follow `AGENTS.md` precedence if guidance overlaps.
- If a referenced skill is unavailable in the current environment, say so explicitly and continue with the closest applicable local workflow instead of blocking.

## Planning Checkpoint

Before creating a branch or editing code, provide a concise checkpoint covering:

- `Ticket facts`: verified Jira facts that define scope.
- `Files read`: the code areas you actually inspected.
- `Skills required`: whether `$ruby-on-rails-dev` and `$review-security-compliance` are required, plus why.
- `Branch name`: the proposed branch name.
- `Implementation plan`: a short plan for the code change.
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
- Implement autonomously.
- Interrupt only when blocked by a real ambiguity, missing access, failing environment prerequisite, or a decision that would be risky to guess.
- Keep diffs minimal and cohesive.
- Do not revert unrelated user changes.
- Prefer targeted tests first, then broader validation as needed.

## Validation And Handoff

- Run the project’s relevant quality gates for the changed surface area.
- Report concrete validation evidence, not vague claims.
- State whether the required skills were invoked.
- Stop when the branch is ready to push and a PR can be opened.
- Final handoff should include:
  branch name, change summary, commands run, pass/fail status, residual risks, and whether the changes are ready to push and open a pull request.

## Output Discipline

- Keep status updates concise and evidence-based.
- When facts are uncertain, label them as assumptions.
- Do not ask the user to restate Jira details that can be fetched through Atlassian MCP.
