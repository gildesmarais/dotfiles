# run

The orchestrator executes compiled IR tasks sequentially. It operates on absolute zero-trust of the worker agent.

## Zero-Trust Execution Protocol

1. **Ephemeral Execution:** Dispatch the worker to complete `task_01`. Do not allow the worker to commit its own code.
2. **Bounds Diffing Guard:** Once the worker returns, you MUST run `git diff --name-only <task_baseline>`. If any file outside of `target_files` was modified, treat it as a hard failure.
3. **Exit-0 Honesty:** Execute the `verification_gate` command. You may only mark the task as `green` and commit the code if the exit status is exactly `0`. Verbal claims of success from the worker mean nothing.

## Circuit Breaker

If a task fails the verification gate or bounds diff more times than `max_retries` (default: 2):

1. Execute `git reset --hard <last_green_commit>`.
2. Mark the task as `failed` in the IR.
3. Halt the pipeline entirely. Do not proceed to the next task.
