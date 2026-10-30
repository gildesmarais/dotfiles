# Story slice (`story-slice`)

1. **Prerequisite:** cite the `gate` Build Now or approved founder override; never slice rejected or uncited scope.
2. **Strip contraband:** secondary SSOTs, parallel DB tables, unneeded settings surfaces.
3. **Triad per slice:** persona + documented golden path; invariants & non-goals (what it will not touch); Given/When/Then AC on observable state / filesystem truth.
4. **UX & performance mandates:** click/keystroke budgets, latency SLAs, conflict handling — cite from `product.md` only; silent → `unknown`.
5. Pair every story with its automated test target and verification benchmark before `$dev` `plan`.

## Story Card (one per slice)

```text
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
