# Debt

Debt that can't be fixed in the current scope goes to `<project>/.agents/debt-ledger.md` (create `.agents/` if missing), where `product-owner` admits it under the Health Capacity Budget ([`../../CONTEXT.md`](../../CONTEXT.md)).

## Entry schema

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

## Category → remediation route

| Category   | Signal                                                              | Route                                                |
| ---------- | ------------------------------------------------------------------- | ---------------------------------------------------- |
| `boundary` | Leaky seams, circular imports, god objects, multi-table queries     | `architecture deep-modules` or `refactor-boundaries` |
| `types`    | Primitive obsession, stringly-typed IDs, unsafe JSON bags           | `architecture refactor-types`                        |
| `perf`     | Unmeasured hot paths, N+1, runaway allocations                      | `architecture performance`                           |
| `legacy`   | Superseded models, deprecated APIs, dead compat shims               | `review.gil quality` (legacy lens)                   |
| `test`     | Flaky tests, missing integration seams, implementation-detail tests | `review.gil quality` (tests lens)                    |

## Lifecycle

0. **Re-check inherited findings against HEAD** (re-run the gate or re-read the file) before logging — logging an already-resolved finding manufactures fake debt.
1. Append with status `open`.
2. `product-owner` admits high-friction items as Build Now under the Health Capacity Budget.
3. Delivered + Assure passed → `resolved` with commit SHA. `Resolves: DEBT-<NUMBER>` in a commit is the only marker. Whoever lands that commit sets the row to `resolved` with the commit hash, in one `chore(debt): resolve DEBT-<NUMBER>` commit (orchestrator: right after the phase commit; `pull-request open`: before the push). Missing or ambiguous row → stop. Never ask for a manual ledger edit.
