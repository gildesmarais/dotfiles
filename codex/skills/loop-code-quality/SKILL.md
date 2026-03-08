---
name: loop-code-quality
description: "Review freshly implemented code for correctness, robustness, and architectural risks, then patch obvious issues. Use when a coding slice is complete and you need a focused quality loop: implement, run tests, run risk review, and fix findings."
---

# Loop Code Quality

Run this workflow after each implementation slice:

1. Implement the requested change.
2. Run relevant tests.
3. Run a focused risk review on the new code.
4. Patch obvious issues found by the review.

## Review Prompt

Review the code just produced in this iteration.

Report up to 5 meaningful findings focused only on:

- hidden assumptions
- brittle branching logic
- missing error handling
- unhandled edge cases
- architecture choices that may constrain future changes

Coverage requirements:

1. Include brittle logic or hidden assumptions that could break in production.
2. Include edge cases or failure paths that are not handled.
3. Include one architectural decision that may become problematic as the system evolves.

Ignore style, formatting, naming, and cosmetic refactors.
Focus only on correctness, robustness, and architectural soundness.
Be concise and specific.

## Output Format

For each finding include:

- Issue
- Risk
- Code reference
- Minimal fix (only if obvious)
