# Story slice (`story-slice`)

1. **Prerequisite:** cite the `gate` Build Now or approved founder override. Never slice rejected or uncited scope.
2. **Strip contraband:** secondary SSOTs, parallel DB tables, unneeded settings surfaces.
3. **Triad per slice:** persona + documented golden path; invariants & non-goals (what it will not touch); Given/When/Then AC on observable state / filesystem truth.
4. **UX & performance mandates:** click/keystroke budgets, hot-path latency SLAs, deterministic conflict handling (e.g. clean reload vs non-destructive banner) — **cited from product docs only**. Docs silent → write `unknown` and name the missing artifact. Never default to example numbers: figures like `<5ms` editing / `<50ms` headless writes illustrate the strictness expected *when a repo documents them*; they are not defaults.
5. **Quality Gate Matrix:** pair every story with its automated test target and verification benchmark before `$dev` `plan`.

## Story Card (one per slice)

```
**Title**:
**Persona & context**:
**Golden path served**: (cite, or unknown)
**Invariants bound**:
**Non-goals**:
**Acceptance**:
- Given …
- When …
- Then …
**Edge cases**:
**Interaction budget**: (cite, or unknown / qualitative)
**Latency SLA**: (cite, or unknown)
**Conflict handling**: (cite documented rule, or unknown)
**Test target / verification**:
```
