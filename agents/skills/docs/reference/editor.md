# Docs — `editor`

Rewrite for action: a new reader can act without guessing. Recommend a new doc only when a standard, high-value doc is missing and the user asked for documentation work — say why it should exist.

## Evidence ladder

1. code and tests
2. configuration and scripts
3. generated artifacts
4. adjacent documentation (only to avoid contradiction or duplication)

## Rules

- Define the doc's job: who reads it and what they can do afterward. Keep only content that serves that job; don't expand scope to nearby information.
- Verify commands, paths, flags, config keys, defaults, outputs, and links against the repo. Describe selection, fallback, and precedence exactly as implemented; confirm defaults, guarantees, uniqueness, and precedence claims are enforced.
- Make cwd, env vars, inputs, and invocation mode explicit when they affect execution. Examples match the repo, are mutually consistent, and are self-contained or state their dependencies.
- Multi-step shell examples: use `&&`, `;`, and `\` continuations deliberately, with trailing `\` aligned into a vertical rail.
- **Write forward**: what it is, when to use it, how to run it, what success looks like. Positive instructions over "do not / never / avoid" stacks that assume the past system. Remove history, origin stories, era/migration framing, "expected failure" teaching, vague motivation, speculative plans, dead flows (except a one-line present prune/cleanup fact), and duplicate explanations. Keep a past name only when it changes a present decision (e.g. alias → current name lookup).
- Keep caveats that change usage, as present constraints. Don't rewrite away nuance that affects correctness.

## Structure

Default order, cutting what doesn't serve the job: what this is → when/why → prerequisites → quick start or exact procedure → expected result → next step or deeper reference.

- **README**: first success in minutes; copy-paste startup steps.
- **Change/feature docs**: anchor in implementation — what changed, who it affects, how to enable, actual selection/fallback/precedence, constraints/migration/rollout impact, link to current source of truth.
- **Contributor/operator docs**: repeatability — setup, exact commands, verification points, important failure modes, troubleshooting refs. Runbooks keep rollback notes, decision-critical edge cases, and failure handling even at the cost of brevity.
