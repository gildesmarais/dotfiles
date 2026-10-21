# Tests

Lens for changed tests/specs: over-mocking, hidden regressions, contract gaps, weak assertions, dishonest fixtures, flaky seams, inflated flight height.

## Method

1. Read the implementation diff before judging its tests.
2. Classify flight height: **Pure unit** · **Component** · **Integration** · **UI smoke** · **Regression / characterization**. Pyramid definition → `$dev` [`../dev/reference/surgical-laws.md`](../../dev/reference/surgical-laws.md).
3. Useful isolation removes nondeterminism/expense while keeping the contract; harmful mocking reimplements production or asserts sequencing over outcomes.
4. Tie findings to a production defect or bug risk.

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
- Mirrored suites: classify **spec-only twin** vs **dual-ownership twin** (probe → `ruby-dev`); never invent a second lib fold to tidy specs.
- Micro-units chasing branch-% when floors already pass → fixture-driven product edges.
- Same scenario at three levels without a discriminating difference → one authoritative layer + one smoke.
- Language-named Vitest/DOM/OpenAPI/hook-tree patterns → `typescript-dev` `reference.md`.
- Surfaces the project bans from golden-path tests, or helper/mapper changes without colocated tests where enforced (per `AGENTS.md`).

## Output

Severity-ordered, folded into the `finish` report. Per finding: file:line, what the test does, why it hides a bug / inflates flight height, stronger shape or seam fix. None found → say so plus residual gaps.
