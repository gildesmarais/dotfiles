---
name: review-tests
description: Review changed test files and spec diffs for over-mocking, hidden regressions, contract gaps, assertion weakness, fixture dishonesty, flaky test seams, and brittle architecture. Use when Codex is asked to review specs, tests, or test-related changes in Ruby, JavaScript, or similar codebases, especially when the user suspects mocks are covering bugs, wants stronger regression detection, or wants architectural advice to make tests more precise.
---

# Review Tests

## Overview

Review tests with a code-review mindset, but focus on whether the tests prove the behavior that matters. Prefer findings about mocked-away regressions, weak assertions, dishonest fixtures, missing behavior coverage, and seams that make the code hard to test precisely.

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

## What To Prefer

- One or two strong end-to-end examples through the public entrypoint for each risky behavior change.
- Small fakes that model collaborator boundaries better than mocks full of `have_received` assertions.
- Assertions on returned values, persisted state, emitted output, serialized payloads, or raised domain errors.
- Tests that cover both the intended path and the most plausible regression path introduced by the change.
- Regression examples that clearly encode the bug trigger, not just the final output.
- Boundary tests that prove adapters and serializers match the real contract at least once.

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
