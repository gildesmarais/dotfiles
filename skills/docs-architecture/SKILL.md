---
name: docs-architecture
description: Analyze, verify, and refine architecture documentation against the implemented system. Use when Codex needs to align architecture docs, ADRs, technical design notes, diagrams, or system overviews with actual runtime behavior, enforced interfaces, real data flow, and current constraints; remove outdated or aspirational architecture; and make boundaries, invariants, and failure modes explicit before decisions or changes.
---

# Docs Architecture

Edit architecture documentation to reflect how the system actually behaves, not how it was intended to behave.

Treat runtime behavior, system boundaries, and enforced constraints as the source of truth. Assume existing architecture prose may be outdated until verified.

## When To Use

- Use for architecture-facing documents such as ADRs, technical design notes, architecture diagrams, system overviews, boundary docs, and integration-flow docs.
- Use when a task requires verifying actual architecture before making decisions or changes, even if the user did not explicitly ask for a doc rewrite.
- Use when code, docs, or review feedback suggest the current mental model may be stale or aspirational.

Prefer `docs-editor` when the task is mainly about public-facing or operational documentation such as README, contributor docs, feature docs, or runbooks and the main goal is clarity of usage rather than architectural accuracy.

Prefer `finish-review` when the user wants an end-of-branch production-readiness review rather than architecture-document verification.

## Objective

Enable correct decisions and safe system changes.

Write or revise architecture documents so a reader can:
- understand system boundaries
- reason about data and control flow
- identify constraints and invariants
- avoid breaking critical behavior

## Core Rules

- Verify architecture claims against actual system behavior.
- Prefer runtime behavior and enforced contracts over design intent.
- Remove outdated assumptions and aspirational descriptions.
- Keep constraints, invariants, and failure modes explicit.
- Preserve decision-relevant context and remove decorative explanation.
- Do not describe architecture that is not implemented or enforced.
- Keep terminology consistent with the system.

## Source Of Truth

Verify against the closest representation of real behavior in this order:

1. runtime behavior and observable system effects
2. interfaces and contracts such as APIs, schemas, and boundaries
3. data flow and integration points
4. code and tests
5. existing architecture documents

When sources conflict, prefer what is enforced at runtime.

## Triage

Classify the document before editing:

- `accurate`: tighten and clarify
- `partial`: add missing constraints and flows
- `misleading`: rewrite from verified behavior
- `obsolete`: remove or recommend removal

Match effort to the classification.

## Workflow

### 1. Define Purpose

- Identify what decisions the document should support.
- Identify what behavior a reader must not break.

### 2. Locate The Real Sources

- Identify the target document or architecture claim under review.
- Find the runtime entrypoints and execution boundaries that define the behavior.
- Find the enforced interfaces such as APIs, schemas, queues, jobs, events, and storage boundaries.
- Find the most relevant tests, configuration, and supporting scripts.
- Read neighboring docs only to detect contradiction, not as primary evidence.

### 3. Build System Understanding

- Trace the key flows through the system.
- Identify boundaries between components.
- Identify enforced contracts such as APIs, schemas, and interfaces.
- Identify constraints such as ordering, consistency, limits, and timeouts.
- Identify failure modes and fallback behavior.

### 4. Cut To Decision-Relevant Content

Keep only content that helps a reader understand how the system works and reason about changes safely.

Remove or compress:
- historical context unless it explains a current constraint
- unused or removed components
- speculative or future architecture
- diagrams or descriptions that do not match current behavior

### 5. Rewrite For Clarity

Prefer this structure:
- system overview
- components and boundaries
- data flow and control flow
- constraints and invariants
- failure modes and fallback behavior

Use short sections, explicit labels, and diagrams only when they match reality.

### 6. Validate

- Confirm flows match actual execution paths.
- Confirm constraints are enforced, not assumed.
- Confirm interfaces exist and match implementation.
- Confirm nothing contradicts runtime behavior.
- Confirm the document supports real decisions.

## Verification Tiers

Use the strongest practical evidence available in this order:

1. live runtime behavior and observable system effects
2. executable entrypoints and boundary handlers such as request handlers, workers, jobs, and CLI commands
3. enforced interfaces such as schemas, API contracts, storage models, and event definitions
4. tests that exercise real integration paths
5. configuration, scripts, and generated artifacts
6. existing architecture documents

If live runtime verification is not practical, continue with the strongest remaining evidence and report the limitation in the handoff.

## What To Keep

- enforced constraints and invariants
- actual system boundaries
- real data and control flows
- failure modes and recovery behavior
- decisions that still affect current behavior

## What To Remove Or Compress

- intended or aspirational architecture
- outdated diagrams
- vague system descriptions
- duplicated explanations
- implementation details that do not affect decisions
- unverifiable claims

## Drafting Pattern

### System Overview

- state briefly what the system does
- name the main components
- describe the high-level flow

### Components And Boundaries

- state each component's responsibility
- identify the interfaces between components
- make ownership and separation explicit

### Data And Control Flow

- describe how data moves through the system
- distinguish synchronous and asynchronous behavior
- call out ordering and dependencies

### Constraints And Invariants

- name limits such as timeouts, throughput, and size
- state consistency guarantees
- state required ordering or sequencing
- state assumptions that are enforced by the system

### Failure Modes

- state what can fail
- describe how failures propagate
- describe fallback or recovery behavior
- state what breaks if a component is unavailable

## Uncertainty Handling

If behavior cannot be verified:

- do not describe it as fact
- isolate the gap during drafting
- report the gap in the handoff

Do not publish uncertain architecture as truth.

Use this stopping rule:

- If the core flows and boundaries are verified, rewrite the verified sections and isolate unknowns explicitly.
- If the core flows cannot be verified, do not rewrite the main architecture narrative as if it were settled. Instead, produce a constrained gap report and name the next sources to inspect.

## Boundaries

- Do not document architecture that is not implemented.
- Do not preserve outdated mental models.
- Do not expand scope beyond the document's purpose.
- Do not remove constraints that affect correctness.
- Do not simplify away important system behavior.

## Handoff

Report:

- the document and its purpose
- the triage classification
- the verified sources used
- the verification tier reached for the main claims
- the key constraints and flows clarified
- the outdated assumptions removed
- unresolved gaps in understanding

Before finishing, confirm:

- the document reflects actual system behavior
- system boundaries and flows are clear
- constraints and failure modes are explicit
- the document supports safe changes
