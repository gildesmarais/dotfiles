# Run branch

Dispatch the persisted IR task-by-task. Each worker is a fresh sub-agent that loads **`$dev` `implement`**. This skill orchestrates order, gates, status, and circuit breaking — it does **not** mutate application code itself.

## Preconditions

Halt (do not dispatch) unless all hold:

1. **IR file exists** — path from user or `.agents/compile/<slug>.yaml`.
2. **User approved** — `circuit_breaker.user_approved: true` in the IR file (consent for reset to last green task commit). If the user just approved in-conversation but the flag is still `false`, set it to `true` in the IR first (see `compile.md` Emit step 4), then proceed.
3. **Clean worktree** — `git status` shows no uncommitted changes. Dirty tree → halt and ask the user to commit, stash, or discard _their_ work first. Never reset over unrelated dirty state.
4. **Not on silent main** — if HEAD is the default branch, follow `$dev` phase-commit law (ask early whether to commit here or defer); do not silently commit on main/master.

Record `baseline_commit` = current `HEAD` at dispatch start (last green before any task, or the latest task commit after greens).

## Resume

1. Read the IR file.
2. Build the sequential order: topological sort by `depends_on` (empty deps first; reject cycles).
3. Skip tasks with `status: green`.
4. If a task is `failed`, halt until the user fixes the IR / tree and re-invokes `run` (or explicitly asks to retry that task — reset its `status` to `pending` in the IR only on that ask; attempts restart at 0 automatically since they are session-local).
5. Dispatch the next `pending` task only.

## Per-task loop

For each next `pending` task:

### 1. Snapshot

- `task_baseline` = current `HEAD` (clean).
- Track `attempts` in orchestrator memory only — not persisted in the IR (start at 0; cap = `max_retries`, default 2).

### 2. Spawn worker

Fresh sub-agent / clean context (`invoke_subagent` in subagent-capable environments, or fresh task turn). Prompt shape (adapt paths):

```text
Load and follow the `$dev` skill, branch `implement`.

You are executing exactly one prompt-compiler task. Do not expand scope.

Invariants (must hold):
- <list from IR>

Task:
- id: <id>
- name: <name>
- Mutate ONLY these files (whitelist): <target_files>
- Read-only context (may open, must not edit): <read_context>
- Do not touch any other paths.

When done, leave the worktree with your edits unstaged or staged — the orchestrator
re-runs the verification gate and commits. Do not git commit yourself unless the
orchestrator prompt says otherwise. Prefer Conventional Commit message text in your
handoff for the orchestrator to use.

Single-task worker: skip `$dev` post-delivery Assure — the orchestrator owns gates;
DAG-level Assure runs once at full completion.

Validation hint (orchestrator will re-run): <verification_gate>
```

`$dev` owns classify, `architecture` shift-left when design, language adapters, API truth, and validation honesty inside the worker. **Do not trust the worker's "green" claim.**

### 3. Orchestrator hard gate (zero worker trust)

After the worker returns, **this orchestrator** (parent agent):

1. **Bounds diff** — `git diff --name-only <task_baseline>` (and untracked files under the whitelist). Every changed path must be in `target_files`. Any extra path → **failed attempt**: restore tree to `task_baseline` (`git checkout -- .` / clean untracked only within the failed attempt — prefer `git reset --hard <task_baseline>` **only** because the user already approved the circuit-breaker policy and the tree was clean of non-compiler work), increment attempts, retry or break.
2. **Re-run `verification_gate`** — execute the exact command from the IR; observe exit status. Non-zero → failed attempt; same restore; retry or break.
3. Never commit on a worker's verbal claim alone.

### 4. Pass → commit → mark green

On gate + bounds pass:

1. Author ≥1 Conventional Commit covering only this task (cite store [`CONTEXT.md`](../../CONTEXT.md) format). Body: task id + intent.
2. Set task `status: green` in the IR file; clear failure notes.
3. Update `last_green_commit` = new `HEAD`.
4. Proceed to the next `pending` task (same session) or stop and report progress if the user asked for one-task-at-a-time.

### 5. Fail → retry → circuit breaker

On failed attempt:

- If `attempts < max_retries`: restore to `task_baseline`, spawn a new worker with the gate/bounds error attached, retry.
- If `attempts >= max_retries`: **circuit break**:
  1. `git reset --hard <last_green_commit>` (or `baseline_commit` if no task has gone green yet).
  2. Set task `status: failed`; note the last gate/bounds error in the IR or emit summary.
  3. **Halt** — no further tasks until the user re-invokes `run` after fixing the IR or approach.

Never continue the DAG after a circuit break. Never reset to anything other than `last_green_commit` / `baseline_commit`.

## Parallelism

**Sequential only.** `depends_on` is honest DAG data for ordering; do not dispatch independent tasks in parallel worktrees until the store harvests that pattern from repeated pain.

## Full DAG completion

When every task is `green`:

1. Confirm invariants still hold (re-run any suite-level gates named in invariants if they are commands; otherwise state residual risk).
2. **Post-delivery Assure** — prefer spawning a new agent that runs `review.gil` **`findings`** (+ warranted lenses; **`security`** when Shared prep security cues matched). Fallback: fresh in-session `review.gil` pass. Report delivery only after that pass returns.
3. If the user asked to land and readiness is Yes/Conditional → continue with `pull-request` **`open`**.

## Anti-patterns

- Mutating application files in the orchestrator turn.
- Trusting worker exit claims without re-running the gate.
- Committing when bounds diff shows non-whitelisted paths.
- `git reset --hard` without prior user approval of the circuit-breaker policy, or while the tree had unrelated dirty files.
- Skipping Assure after a full green DAG.
- Asking the worker to load skills other than `$dev` (+ what `$dev` routes) for the implementation turn.
