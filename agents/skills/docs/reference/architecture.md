# Docs — `architecture`

Edit architecture documentation to reflect how the system actually behaves, not how it was intended to behave.

Treat runtime behavior, system boundaries, and enforced constraints as the source of truth.

Use for ADRs, technical design notes, architecture diagrams, system overviews, boundary docs, and integration-flow docs — including when code, docs, or review feedback suggest the current mental model may be stale or aspirational.

## Objective

Enable correct decisions and safe system changes. Write or revise architecture documents so a reader can:

- understand system boundaries
- reason about data and control flow
- identify constraints and invariants
- avoid breaking critical behavior

## Evidence ladder

Use the strongest practical evidence available, in this order:

1. live runtime behavior and observable system effects
2. executable entrypoints and boundary handlers such as request handlers, workers, jobs, and CLI commands
3. enforced interfaces such as schemas, API contracts, storage models, and event definitions
4. tests that exercise real integration paths
5. configuration, scripts, and generated artifacts
6. existing architecture documents

If live runtime verification is not practical, continue with the strongest remaining evidence and report the tier reached in the handoff.

## Core rules

- Verify architecture claims against actual system behavior.
- Prefer runtime behavior and enforced contracts over design intent.
- Remove outdated assumptions and aspirational descriptions.
- Keep constraints, invariants, and failure modes explicit.
- Preserve decision-relevant context and remove decorative explanation.

## Workflow

### 1. Define purpose

- Identify what decisions the document should support.
- Identify what behavior a reader must not break.

### 2. Locate the real sources

- Identify the target document or architecture claim under review.
- Find the runtime entrypoints and execution boundaries that define the behavior.
- Find the enforced interfaces such as APIs, schemas, queues, jobs, events, and storage boundaries.
- Find the most relevant tests, configuration, and supporting scripts.
- Read neighboring docs only to detect contradiction, not as primary evidence.

### 3. Build system understanding

- Trace the key flows through the system.
- Identify boundaries between components.
- Identify enforced contracts such as APIs, schemas, and interfaces.
- Identify constraints such as ordering, consistency, limits, and timeouts.
- Identify failure modes and fallback behavior.

### 4. Cut to decision-relevant content

Keep only content that helps a reader understand how the system works and reason about changes safely.

Remove or compress:

- historical context unless it explains a current constraint
- unused or removed components
- speculative or future architecture
- diagrams or descriptions that do not match current behavior
- vague system descriptions and duplicated explanations
- implementation details that do not affect decisions

### 5. Rewrite for clarity

Prefer this structure, using diagrams only when they match reality:

- system overview
- components and boundaries
- data flow and control flow
- constraints and invariants
- failure modes and fallback behavior

### 6. Validate

- Confirm flows match actual execution paths.
- Confirm constraints are enforced, not assumed.
- Confirm interfaces exist and match implementation.
- Confirm nothing contradicts runtime behavior.
- Confirm the document supports real decisions.

## What to keep

- enforced constraints and invariants
- actual system boundaries
- real data and control flows
- failure modes and recovery behavior
- decisions that still affect current behavior

## Drafting pattern

### System overview

- state briefly what the system does
- name the main components
- describe the high-level flow

### Components and boundaries

- state each component's responsibility
- identify the interfaces between components
- make ownership and separation explicit

### Data and control flow

- describe how data moves through the system
- distinguish synchronous and asynchronous behavior
- call out ordering and dependencies

### Constraints and invariants

- name limits such as timeouts, throughput, and size
- state consistency guarantees
- state required ordering or sequencing
- state assumptions that are enforced by the system

### Failure modes

- state what can fail
- describe how failures propagate
- describe fallback or recovery behavior
- state what breaks if a component is unavailable

## Stopping rule

- If the core flows and boundaries are verified, rewrite the verified sections and isolate unknowns explicitly.
- If the core flows cannot be verified, do not rewrite the main architecture narrative as if it were settled. Produce a constrained gap report and name the next sources to inspect.

## Boundaries

- Do not document architecture that is not implemented.
- Do not preserve outdated mental models.
- Do not expand scope beyond the document's purpose.
- Do not remove constraints that affect correctness.
- Do not simplify away important system behavior.

## Handoff additions

Beyond the shared handoff items, report:

- the verification tier reached for the main claims
- the key constraints and flows clarified
- the outdated assumptions removed

## Before finishing

Confirm:

- the document reflects actual system behavior
- system boundaries and flows are clear
- constraints and failure modes are explicit
- the document supports safe changes
