# Dev plan pipeline

`$dev plan` is the authoritative technical-discovery and implementation-plan carrier. It converts admitted intent into concrete repository-native phases. It writes no application code.

## Phase 0: ingress

1. Resolve the requested slug.
2. If `.agents/compile/<slug>.yaml` exists, read `intent_spec` and treat its invariants, `blast_radius.allowed_domains`, and breaking-change posture as authoritative. Skip redundant intent interviews.
3. Halt on an invalid DTO, a repository contradiction, or a technical plan that cannot remain inside `allowed_domains`. Return the contradiction to the intent owner; do not silently widen scope.
4. If no Intent DTO exists, gather the same intent constraints once within `$dev plan` before technical discovery.
5. `circuit_breaker.approved` records explicit destructive-reset consent. Never change false to true without direct user approval.

The Intent DTO is not an implementation plan. It contains no task graph, exact mutation whitelist, command, status, or retry policy.

## Technical discovery

Inspect repository-native evidence before defining phases:

- root and nested `AGENTS.md` files
- `Makefile` and documented task runners
- language and package manifests plus lockfiles
- source layout and in-tree call sites
- test directories, focused test conventions, and CI configuration
- existing Conventional Commit history when scope naming is unclear

Derive from that evidence:

- atomic, sequential implementation phases
- exact repository-relative `target_files`
- exact repository-relative read-only `read_context`
- one exact repo-native `verification_gate` command per phase
- one Conventional Commit message per phase

Never invent a command. Prefer repository entrypoints and the narrowest gate that proves the phase. If no trustworthy gate exists, halt and name the missing repository contract.

## Planning sequence

1. Product stance or prior admission
2. Intent ingress and contradiction check
3. Shared prep and classification (`surgical` | `design` | `review-hand-off`)
4. Runtime routing from discovered touched-file evidence
5. Architecture pass when `design` is earned
6. Repository inspection and phase derivation
7. Conditional risks, observability, and pre-ship checks where signaled
8. Emit the plan carrier and halt for execution approval

## Output carrier

Write `.agents/plan/<slug>.md`. Use this fixed Markdown DTO; do not introduce a parallel YAML task schema or status tracker:

```markdown
# Implementation Plan: <slug>

Intent: `.agents/compile/<slug>.yaml` | inline
Circuit breaker approved: false

<!-- phase:start -->

## Phase 01 — <imperative outcome>

target_files:

- `path/to/exact-file`

read_context:

- `path/to/read-only-file`

verification_gate: `<exact repo-native command>`
commit_message: `<type>(<scope>): <description>`
<!-- phase:end -->
```

Carrier laws:

- Phase numbers are unique, contiguous, and execution order is document order.
- `target_files` and `read_context` are exact paths; no globs, directories, prose, or overlap between mutation and read-only lists.
- Every phase has at least one `target_files` entry and exactly one command and commit message.
- A path may appear in multiple phase mutation lists only when the plan explains why later mutation is required.
- Commands are copied from repository-native evidence and remain exact strings for independent runner execution.
- The carrier has no mutable phase status, attempt counters, worker transcripts, or retry loop state. Git commits are execution progress.

## Ready checklist

- [ ] Intent constraints are authoritative and contradictions resolved
- [ ] Classification, runtime route, and architecture decisions stated where required
- [ ] Repository-native build and test entrypoints inspected
- [ ] Every phase has exact `target_files` and `read_context`
- [ ] Every `verification_gate` is discovered, exact, and independently runnable
- [ ] Every `commit_message` is Conventional Commit text
- [ ] Conditional risks, observability, and pre-ship checks are included or N/A with evidence
- [ ] Circuit-breaker consent is explicit
- [ ] Plan persisted at `.agents/plan/<slug>.md`
- [ ] No application code written before execution approval

Approved execution hands the plan to `orchestrator run`. Individual workers enter through `$dev implement`; DAG-level `review.gil findings` remains orchestrator-owned.
