# Docs — `editor`

Rewrite so a new reader can act without guessing. Recommend a new doc only when a high-value standard doc is missing and the user asked.

## Evidence ladder

1. code and tests
2. configuration and scripts
3. generated artifacts
4. adjacent documentation (only to avoid contradiction or duplication)

## Rules

- Define the doc's job (reader, what they can do afterward); keep only content that serves it.
- Verify commands, paths, flags, config keys, defaults, outputs, and links against the repo. Describe selection, fallback, and precedence exactly as implemented.
- State cwd, env vars, inputs, and invocation mode when they affect execution; examples are self-contained.
- Multi-step shell examples: chain with `&&`, `;`, or `\`; align trailing `\` into a vertical rail.
- **Write forward**: remove history, migration framing, "expected failure" teaching, speculative plans, and dead flows (except a one-line prune/cleanup fact). Keep a past name only when it changes a present decision.
- **Wiki via MCP:** list a folder with CQL `ancestor = <id>` (folder IDs 404 on page-descendant APIs); pass `updateConfluencePage` the full content inline, never a file path; re-read to verify.

## Structure

Order: what → when/why → prerequisites → procedure → expected result → next step. Runbooks keep rollback notes and decision-critical edge cases.
