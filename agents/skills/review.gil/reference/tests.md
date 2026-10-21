# Tests

Lens for changed tests/specs: over-mocking, hidden regressions, contract gaps, weak assertions, dishonest fixtures, flaky seams, inflated flight height.

## Method

1. Read the implementation diff before judging its tests; never assess mocking in isolation.
2. Classify flight height (default check): **Pure unit** (one decision/VO/parse; <10ms, in-memory) · **Component** (multi-collaborator with in-memory fakes; never top-level god orchestrators) · **Integration** (real wiring — persistence, HTTP, jobs, CLI, disk/FFI) · **UI smoke** (thin e2e journey) · **Regression / characterization** (locks a bug trigger or pre-refactor behavior).
3. Coverage shape for risky behavior: happy, error/fallback, nil/empty/malformed, authz/validation boundary, transport boundary, state before/after.
4. Useful isolation removes nondeterminism/expense while keeping the contract; harmful mocking reimplements production, drives private callbacks, or asserts sequencing over outcomes. Mock only slow, nondeterministic, hard-to-trigger, or external boundaries.
5. Tie findings to a production defect or bug risk; suggest architecture only when it lowers flight height, clarifies contracts, removes duplicated behavior, or improves mutation/regression detection.

Probe: What bug does this catch? What bug in this diff still passes? Would it pass with the key production branch deleted? Is the seam the narrowest public one?

## Flag

- Flight-height inflation: god orchestrator or UI host to test pure math/VO transforms.
- `sleep`/polling loops instead of explicit async contracts.
- Stores hardcoding system-dir singletons (no temp-dir isolation).
- Kitchen-sink suites mixing parse + component + disk + UI without tier split.
- Private-surface reach, manually invoked captured callbacks/hooks, stubs reimplementing collaborator logic.
- Called-with expectations without asserting visible outcome; broad global stubs where a narrow fake fits.
- Happy-path-only specs when the diff changed error, fallback, or security handling.
- Snapshot/golden tests locking shape, not semantics; many coarse assertions, none discriminating the likely bug.
- Fixtures creating impossible states or bypassing validation; frozen time/random/order/concurrency that drops the real contract.
- Lifecycle/race fixes never replaying the broken storage or unhydrated-cache state.
- Dual-runtime encode asserted on one side only → shared fixture vectors both runtimes check.
- Per-feature unwrap/parse copies where one shared envelope characterization exists or should.
- Mirrored suites: classify **spec-only twin** vs **dual-ownership twin** before editing (probe detail → `ruby-dev`); never invent a second lib fold to tidy specs.
- Micro-units chasing branch-% when floors already pass → fixture-driven product edges.
- Same scenario at three levels without a discriminating difference → one authoritative layer + one smoke.
- Screen tests stubbing product hooks → real hook tree, fake HTTP/injectable leaves only.
- Dual transport fakes for one URL → register the absolute URL once.
- Hook suites re-walking a screen journey → hooks only for fake timers; outcomes on one integration render + thin browser smoke.
- Browser-only assertions in a DOM shim → browser runner; status/headers/copy stay in jsdom.
- Middle Vitest tier named "contract" when OpenAPI owns that word → unit/integration/e2e.
- Surfaces the project bans from golden-path tests, or helper/mapper changes without colocated tests where enforced (per `AGENTS.md`).

## Prefer / recommend

- Pyramid: pure VOs at base, component fakes, narrow real-I/O integration; fewer higher-flight behavioral outcomes over collaborator choreography.
- Painful setup → refactor the production seam (extract trapped view math; inject root dirs, clocks, clients, fetchers, random, queues, parsers).
- Assert returns, persisted state, emitted output, serialized payloads, domain errors; adapters/serializers proven against the real contract at least once.

## Output

Severity-ordered, folded into the `finish` report. Per finding: file:line, what the test does, why it hides a bug / inflates flight height, stronger shape or seam fix. None found → say so plus residual gaps.
