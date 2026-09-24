# Dev plan pipeline

`$dev plan` turns admitted intent into repository-native phases. It writes no application code.

## Phase 0: ingress

1. Resolve the slug.
2. `.agents/compile/<slug>.yaml` exists → its `intent_spec` invariants, `blast_radius.allowed_domains`, and breaking-change posture are authoritative; skip redundant intent interviews. Absent → gather the same constraints once here.
3. Halt on an invalid DTO, a repo contradiction, or a plan that cannot stay inside `allowed_domains`; return the contradiction to the intent owner. Never silently widen scope.
4. `circuit_breaker.approved` = explicit destructive-reset consent. Set `true` only when the prompt or authoritative parent context grants execution consent up front (`--yes`, autonomous orchestrator mode, explicit user approval); otherwise `false`. Never infer it from a generic implementation request.

The Intent DTO holds no task graph, mutation whitelist, command, status, or retry policy.

## Planning sequence

1. Product stance: prior admission, or explicit `/product-owner` for admission in plan mode.
2. Intent ingress and contradiction check.
3. Shared prep and classification (`surgical` | `design` | `review-hand-off`).
4. Runtime routing from touched-file evidence.
5. Architecture pass when `design` is earned.
6. Technical discovery — root/nested `AGENTS.md`, `Makefile` / task runners, manifests + lockfiles, source layout and call sites, test dirs + CI, Conventional Commit history for scope names — then derive atomic sequential phases, exact `target_files` / `read_context`, one `verification_gate`, one commit message each.
7. Conditional risks, observability, and pre-ship checks where signaled — embed [`review.gil/reference/plan-checklists.md`](../../review.gil/reference/plan-checklists.md).
8. Emit the carrier and halt for execution approval.

Never invent a command: copy the narrowest proving gate from repo evidence. No trustworthy gate → halt and name the missing repo contract.

## Output carrier

Write `.agents/plan/<slug>.md` in exactly this format (no parallel YAML task schema or status tracker):

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

- Phase numbers unique and contiguous; execution order = document order.
- `target_files` / `read_context`: exact repo-relative file paths — no globs, directories, prose, or overlap between the two lists.
- Each phase: ≥1 `target_files` entry, exactly one command, exactly one commit message.
- A path may recur in later phases' `target_files` only with a stated reason.
- Commands are exact strings runnable independently by the orchestrator.
- No mutable status, attempt counters, worker transcripts, or retry state. Git commits are execution progress.

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

Approved execution → `orchestrator run`; workers enter via `$dev implement`; the DAG-level `review.gil findings` pass is orchestrator-owned.
