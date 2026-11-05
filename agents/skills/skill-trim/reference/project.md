# Project

Scope: project store (`.agents/skills/**`, `.claude/skills/**`) and the `AGENTS.md` / `CONTEXT.md` it cites. Never the global store; no new files; no git unless asked.

1. **Keep-test.** Keep a line only if a model would decide wrong without it (project noun, script trigger, DTO field, env var, path, handoff direction, halt/ask condition, repo ban), or it is one pointer to that rule's owner. Delete the rest: general virtue, rationale essays, tables restating prose, unlikely "Not: X", history/aliases, self-evident examples.
2. **Surfaces, in order:** catalog (description = what + trigger terms; negative routes → body); router (`SKILL.md` = router headers only, procedures → `reference/<branch>.md`); branch (compress references, never absorb router text).
3. **Duplicates.** Keep a rule in its owner (vocabulary `CONTEXT.md`, conventions `AGENTS.md`, axioms); replace copies with a pointer.

Done: `skill --project . lint --measure --since <baseline>` exits 0; words down on every touched surface vs baseline; meaning of routing, triggers, DTO fields, paths, and handoffs unchanged.
