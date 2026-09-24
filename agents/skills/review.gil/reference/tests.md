# Tests

Lens for changed tests/specs: over-mocking, hidden regressions, contract gaps, weak assertions, dishonest fixtures, flaky seams, inflated flight height.

## Method

1. Read the implementation diff before judging its tests; never assess mocking in isolation.
2. Classify flight height (default check):
   - **Pure unit (base):** one decision, calculation, VO invariant, or parse transform; <10ms, in-memory, parallel, no orchestrator/UI harness.
   - **Component (middle):** multi-collaborator coordination with in-memory fakes / temp dirs; never top-level god orchestrators or full UI hosts.
   - **Integration (top):** real wiring — persistence, HTTP, jobs, CLI, serialization, disk/FFI/drivers, framework glue.
   - **UI smoke (peak):** thin end-to-end journey.
   - **Regression / characterization:** locks a bug trigger or pre-refactor behavior.
3. Coverage shape for risky behavior: happy, error/fallback, nil/empty/malformed, authz/validation boundary, transport boundary, state before/after.
4. Useful isolation removes nondeterminism/expense while keeping the contract; harmful mocking reimplements production, drives private callbacks, or asserts sequencing over outcomes. Mock only slow, nondeterministic, hard-to-trigger, or external boundaries (payments, third-party APIs, clocks, randomness, infra clients).
5. Tie findings to a production defect or bug risk; suggest architecture only when it lowers flight height, clarifies contracts, removes duplicated behavior, or improves mutation/regression detection — never to reduce mocking stylistically.

Probe: What bug does this catch? What bug in this diff still passes? Would it pass with the key production branch deleted? Is the seam the narrowest public one?

## Flag

- Flight-height inflation: god orchestrator or UI host to test pure math/VO transforms (→ domain math trapped in views/prefs structs).
- `sleep`/polling loops instead of explicit async contracts (→ uncoordinated background init, missing completion hooks).
- Stores hardcoding system-dir singletons (no temp-dir isolation).
- Kitchen-sink suites mixing parse + component + disk + UI without tier split.
- Private-surface reach, manually invoked captured callbacks/hooks, stubs reimplementing collaborator logic (budgeting, retries, parsing, mapping, state transitions).
- Called-with expectations without asserting visible outcome; broad global stubs where a narrow fake fits.
- Happy-path-only specs when the diff changed error, fallback, or security handling.
- Snapshot/golden tests locking shape, not semantics; many coarse assertions, none discriminating the likely bug.
- Fixtures creating impossible states or bypassing validation; frozen time/random/order/concurrency that drops the real contract.
- Lifecycle/race fixes never replaying the broken storage or unhydrated-cache state.
- Dual-runtime encode asserted on one side only → shared fixture vectors both runtimes check.
- Per-feature unwrap/parse copies where one shared envelope characterization exists or should.
- Mirrored suites: classify first — **spec-only twin** (lib already single-owner → shared examples/table-drive) vs **dual-ownership twin** (same algorithm in two production homes → extract shared kernel, then collapse specs). Never invent a second lib fold to tidy specs.
- Micro-units chasing branch-% when floors already pass and misses are defensive arms → fixture-driven product edges.
- Same scenario at three levels (unit + session + facade) without a discriminating difference → one authoritative layer + one smoke.
- Screen tests stubbing product hooks (`useX` returning arranged state, often `as any`) → real hook tree, fake HTTP/injectable leaves only.
- Dual transport fakes for one URL (interceptor + `fetch` spy) → register the absolute URL once.
- Hook suites re-walking a screen journey → hooks only for fake timers (debounce/retry); outcomes on one integration render + thin browser smoke.
- Browser-only assertions (`dialog` open, `inert`, autofocus, geometry) in a DOM shim → browser runner; status/headers/copy stay in jsdom.
- Middle Vitest tier named "contract" when OpenAPI owns that word → unit/integration/e2e.
- Surfaces the project bans from golden-path tests, or helper/mapper changes without colocated tests where enforced (per `AGENTS.md`; never invent names).

## Prefer / recommend

- Pyramid: pure VOs at base, component fakes, narrow real-I/O integration; fewer higher-flight behavioral outcomes over collaborator choreography.
- When setup is painful, refactor the production seam: extract trapped view math into VOs; inject root dirs, clocks, clients, fetchers, random, queues, parsers; move policy/branching behind narrow collaborators testable with small fakes.
- Assert returns, persisted state, emitted output, serialized payloads, domain errors; regression tests encode the trigger; adapters/serializers proven against the real contract at least once.

## Output

Severity-ordered, folded into the `finish` report. Per finding: file:line, what the test does, why it hides a bug / inflates flight height, stronger shape or seam fix. None found → say so plus residual gaps.
