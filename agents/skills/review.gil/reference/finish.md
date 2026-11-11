# Finish

Production-readiness baseline. Report only; read the code around each hunk.

## Acceptance

Fetch any issue or ticket referenced by prompt, branch, commits, or PR (tracker tool, MCP, CLI). Verify each DoD/AC against the diff and tests; unmet or unverified ones are findings and readiness blockers.

When the diff adds an input, return value, or derived flag, trace it through every caller and branch, failures included; any path ignoring, dropping, or not setting it is a finding.

## Output format (required)

Fold all lenses into one report. Always emit **Findings** and **Readiness**; add other sections only when non-empty or a Critical exists.

- **Findings** — Critical / Important / Nice-to-Have, each with impact and recommended action.
- **Readiness** — Yes / No / Conditional; top risks and immediate actions.
- Optional: **Non-Goals**, **Confidence & Uncertainty**, **Compliance & Risk Posture**.

## Incident / fix-diff postures

For `fix`, `Revert`, or production-incident diffs, fold into Findings (no extra lens):

1. Did the fix wander onto a second surface, or does a neighboring layer absorb a boundary failure? → `$dev` → `{lang}-dev` → `architecture`.
2. Does a path assume an invisible contract (shape, reload, cache identity, cutover), or treat disclosure/access as mere presence? → overlay, `security`, else `architecture`.
3. Do validate and execute see the same truth; is each guard owned once; does the published contract match runtime?
4. Dual public API or silent old-shape hydrate? → [`legacy.md`](legacy.md).
5. Startup/suspension races; transport types escaping their edge; checker silenced; durable bags used as live objects without rehydrate; wire enum normalized outside the boundary → `{lang}-dev`.
6. Repeated harden/follow-up commits hinting at a missing principle?
7. Skewed clocks (lagged client, pre-backfill pod, existing session): real breaks or undeletable compat, not missing names?


## Surfaces

Code diffs only; skip docs-only/trivial and say so; `quality` skips. Prefer a strongest-tier host review subagent (`security` only with that lens), else a second inline pass. Pass repo path, target (`branch changes` | `uncommitted changes`), non-default base, and instructions; it computes the diff. On failure, retry once with per-file descriptions, name the blocker, and continue inline. Never fix, publish, or relaunch from output.

