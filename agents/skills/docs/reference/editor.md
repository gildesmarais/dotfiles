# Docs — `editor`

Rewrite so a new reader can act without guessing. Recommend a new doc only when a standard, high-value doc is missing and the user asked for documentation work.

## Evidence ladder

1. code and tests
2. configuration and scripts
3. generated artifacts
4. adjacent documentation (only to avoid contradiction or duplication)

## Rules

- Define the doc's job (who reads it, what they can do afterward); keep only content that serves it.
- Verify commands, paths, flags, config keys, defaults, outputs, and links against the repo. Describe selection, fallback, and precedence exactly as implemented.
- State cwd, env vars, inputs, and invocation mode when they affect execution. Examples are self-contained or state their dependencies.
- Multi-step shell examples: use `&&`, `;`, and `\` continuations deliberately, with trailing `\` aligned into a vertical rail.
- **Write forward**: what it is, when to use it, how to run it, what success looks like. Remove history, origin stories, era/migration framing, "expected failure" teaching, vague motivation, speculative plans, and dead flows (except a one-line present prune/cleanup fact). Keep a past name only when it changes a present decision.

## Structure

Order: what → when/why → prerequisites → procedure → expected result → next step. Runbooks keep rollback notes and decision-critical edge cases.
