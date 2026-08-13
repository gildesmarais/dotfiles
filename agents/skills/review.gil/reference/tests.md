# Tests

Review changed test files and spec diffs for over-mocking, hidden regressions, contract gaps, assertion weakness, fixture dishonesty, flaky test seams, and brittle architecture.

After scope prep in `SKILL.md`, continue here.

## Workflow

1. Identify the changed test files and the production files they exercise.
2. Read the implementation diffs before judging the tests. Do not assess mocking in isolation from the behavior under test.
3. Classify the role of each test before critiquing it:
   - Characterization test: preserves existing behavior while code is being understood or refactored.
   - Unit test: isolates one decision or transformation but should still assert observable behavior.
   - Boundary or integration test: proves wiring across persistence, HTTP, jobs, CLI, serialization, adapters, or framework glue.
   - Regression test: proves a previously observed bug cannot recur.
4. Check whether each changed test still exercises the public contract, or whether it mostly asserts internal call choreography.
5. Run a coverage-shape pass for risky behavior:
   - Happy path.
   - Error or fallback path.
   - `nil`, empty, malformed, or missing input.
   - Security, authorization, or validation boundary.
   - Cross-component or transport boundary.
   - State transition before and after the action.
6. Distinguish useful isolation from harmful mocking:
   - Useful isolation removes nondeterminism or expensive integration while preserving the contract.
   - Harmful mocking reproduces production behavior inside the test, manually drives private callbacks, or asserts internal sequencing more than outcomes.
7. Prefer findings that connect a weak test seam to a concrete bug risk in the current code.
8. Suggest architectural changes only when they would make tests more behavior-focused, more discriminating, or less duplicative.

## What To Flag

- Specs that reach private surface to assert behavior — missing public collaborator / wrong seam.
- Tests that manually invoke captured callbacks, private hooks, or internal helper interactions instead of driving the public API.
- Stubs that reimplement real collaborator behavior such as budgeting, retries, parsing, mapping, or state transitions.
- Expectations that assert a method was called without asserting the resulting externally visible behavior.
- New specs that only cover the happy path while implementation changed error handling, fallback logic, or security checks.
- Global stubs on broad services when a narrower fake or injected collaborator would preserve more behavior.
- Snapshot or golden tests that lock in output shape but do not prove semantics.
- Assertion dilution: many coarse assertions, no discriminating assertion that would fail on the likely bug.
- Fixtures or factories that create impossible states, bypass validation, or hide real setup constraints.
- Tests made unrealistically deterministic by freezing time, randomness, ordering, or concurrency without preserving the real contract.
- Tests that became tightly coupled to sequencing or exact implementation structure, making refactors noisy without increasing confidence.
- Lifecycle/race regressions that only assert the happy path and never replay the broken storage or unhydrated cache state.
- Dual-runtime encode decisions asserted on one side only — prefer shared fixture vectors both runtimes check.
- Per-feature unwrap/parse copies when a shared envelope characterization already exists (or should).
- Mirrored suite sections that look like “duplication debt”: classify before acting — **spec-only twin** (lib already single-owner → shared examples / table-drive / thin extra layers) vs **dual-ownership twin** (same algorithm in two production homes → extract a shared kernel, then collapse specs). Collapsing specs alone leaves drift risk.
- Chasing branch-% or near-floor line misses with micro-units when coverage floors already pass and misses are defensive/coercion arms — prefer fixture-driven product edges and flight-level cleanup.
- The same scenario asserted at three flight levels (unit + session + facade) without a discriminating difference — keep one authoritative layer plus one higher smoke.
- Mounting surfaces the project bans from golden-path tests (read `AGENTS.md`; do not invent names here).
- Helper/mapper production changes without colocated tests when the project enforces that pairing.

## What To Prefer

- One or two strong end-to-end examples through the public entrypoint for each risky behavior change.
- Small fakes that model collaborator boundaries better than mocks full of `have_received` assertions.
- Assertions on returned values, persisted state, emitted output, serialized payloads, or raised domain errors.
- Tests that cover both the intended path and the most plausible regression path introduced by the change.
- Regression examples that clearly encode the bug trigger, not just the final output.
- Boundary tests that prove adapters and serializers match the real contract at least once.
- One shared parse/envelope characterization over duplicated per-feature unwrap assertions.
- When mirrored specs appear, audit production first: if dual ownership, fix the lib; if already DRY, collapse the suite — never invent a second lib fold to make the specs look neat.
- Prefer fewer, higher-flight behavioral outcomes over denser collaborator choreography when both cover the same product path.

## When Mocking Is Correct

Mock boundaries that are slow, nondeterministic, hard to trigger, or owned by external systems, such as payment providers, third-party APIs, clocks, random generators, and infrastructure clients.

Do not mock the behavior the application owns unless the test still proves the observable contract through a narrow seam.

## Review Prompts

Ask these questions while reviewing:

- What bug would this test catch?
- What bug introduced in this diff would still pass?
- What production behavior is being recreated inside the spec?
- Is this asserting the result, or only the choreography?
- Is the chosen seam the narrowest public seam available?
- Would a small fake preserve more behavior than this mock setup?

## Review Output

Report findings first, ordered by severity.
When contributing to a generic review, use Critical / Important / Nice-to-Have and fold findings into the single `finish` report.

For each finding, include:

- File and line reference.
- What the test is doing.
- Why that hides a bug or weakens confidence.
- What stronger test shape or architectural seam would improve it.

If no important defects are found, say so explicitly and mention any residual testing gaps.

## Architectural Guidance

Recommend refactors like these when they materially improve test precision:

- Extract policy, validation, parsing, or decision logic into a collaborator that can be exercised with a small fake instead of callback capture.
- Inject fetchers, clocks, clients, random sources, queues, or parsers so tests avoid global service stubs.
- Replace broad doubles with value objects or in-memory fakes where the contract is simple and owned locally.
- Push pure mapping or branching logic into functions that can be tested without transport or framework setup.
- Add contract tests for adapters that are otherwise heavily mocked.
- Move branching logic behind a narrow interface so specs can assert domain behavior instead of transport details.

Do not recommend architecture changes just to reduce mocking stylistically. Tie each suggestion to clearer contracts, fewer duplicated test behaviors, better mutation resistance, or better regression detection.

## Heuristics

- If a test would still pass after deleting the important production branch, it is probably too mocked.
- If the spec duplicates the same algorithm or state transition as production, it is probably asserting the implementation twice.
- If a mock expectation can be replaced with an assertion on the returned result, prefer the result.
- If the test needs many collaborator expectations to prove one outcome, the seam is probably wrong.
- If the fixture state could never happen in production, the test is probably teaching the wrong lesson.
- If a snapshot failure would be hard to interpret, the assertion is probably too coarse.
