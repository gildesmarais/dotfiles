# Debt Reference

Log and maintain architectural friction, structural rot, and technical debt in `.agents/debt-ledger.md`.

## Purpose

When a session uncovers technical debt, leaky boundaries, unmeasured hot paths, or dead compatibility shims that cannot be fixed within the current task's scope, do not bury them in ephemeral chat. Log them into `.agents/debt-ledger.md` so they are visible to `Intent` (`orchestrator` / `triage`) and proactively admitted by `product-owner` under the **Health Capacity Budget**.

## Ledger Location

- File: `<project>/.agents/debt-ledger.md` (project root)
- If `.agents/` directory does not exist in the project, create it.

## Debt Entry Schema

Each item logged in `.agents/debt-ledger.md` follows this standard shape:

```markdown
### [DEBT-<NUMBER>] <Short Imperative Title>

- **Category:** `boundary` | `types` | `perf` | `legacy` | `test`
- **Friction:** Concise description of the friction, leak, or smell encountered.
- **Affected Files:**
  - `path/to/module.ext`
- **Remediation Route:** matching craft branch (e.g. `architecture deep-modules`, `architecture refactor-types`, `review.gil quality`)
- **Golden Path Impact:** How this debt slows down developer velocity, adds runtime latency, or increases defect risk.
- **Status:** `open` | `admitted` | `resolved`
```

## Categories

| Category | Typical Signal | Remediation Route |
| :--- | :--- | :--- |
| `boundary` | Leaky module seams, circular imports, god objects, multi-table queries | `architecture deep-modules` or `refactor-boundaries` |
| `types` | Primitive obsession, stringly-typed IDs, unsafe JSON bags | `architecture refactor-types` |
| `perf` | Unmeasured hot paths, N+1 queries, runaway allocations | `architecture performance` |
| `legacy` | Superseded models, deprecated APIs, dead compatibility shims | `review.gil quality` (legacy lens) |
| `test` | Flaky tests, missing integration seams, testing implementation details | `review.gil quality` (tests lens) |

## Governance Ingress

1. **Emit:** Append new items to `.agents/debt-ledger.md` with status `open`.
2. **Prioritize:** `product-owner` consults this file when reviewing roadmap capacity.
3. **Admit:** Under the **Health Capacity Budget** (default: ~20% capacity or 1 debt tranche per 3–4 feature tranches), `product-owner` admits high-friction items as `Build Now`.
4. **Resolve:** When an admitted tranche is delivered by `$dev` and passes Assure, update status to `resolved` with commit SHA.
