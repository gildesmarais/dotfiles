# Distill

## Mantra standard

Format per [`../../CONTEXT.md`](../../CONTEXT.md) (Preventive Mantra): `"When X, always Y to prevent Z."` or `"Avoid X; use Y instead because Z."` — 1–2 sentences. Reject incident writeups, stack traces, debug stories, vague platitudes ("test edge cases").

Skill edits are clean cutovers: delete superseded aliases, old execution names, and compat wrappers immediately — never keep backward compat in skills.

## Scope filter

| Scope           | Condition                                                 | Transform                                  | Destination                                                    |
| --------------- | --------------------------------------------------------- | ------------------------------------------ | -------------------------------------------------------------- |
| Project-local   | This repo's scripts, internal API, build tool             | Keep exact paths, flags, names, invariants | `<project>/AGENTS.md` or `<project>/.agents/rules/*.md`        |
| Global arch     | Seam leakage, dual ownership, type modeling, perf         | Strip repo nouns; language-free law        | `~/.dotfiles/agents/skills/architecture/reference/<branch>.md` |
| Global review   | Detection heuristic, security trap, test gap, dead compat | Inspection check / lens finding            | `~/.dotfiles/agents/skills/review.gil/reference/<lens>.md`     |
| Global language | Idiom, compiler quirk, gem/crate/package behavior         | Runtime-specific checklist item            | `~/.dotfiles/agents/skills/<lang>-dev/reference.md`            |
| Global workflow | Git, PR sizing, CI triage, branch hygiene                 | SDLC checklist item                        | `~/.dotfiles/agents/skills/<skill>/reference/...`              |

## Procedure

1. Draft the mantra from the signal.
2. Read the target fresh. Global arch / review targets: follow `architecture/reference/growth.md` / `review.gil/reference/growth.md` Harvest (stage in that skill's `learning-log.md` → promote or drop).
3. Covered, near-clone, or too narrow → drop; else append to `## Checklist` or `## Anti-patterns`.
4. Cap: ≤3 new mantras per session unless the user asks for more.
5. Global store edit → `skill doctor`, then `rcup` (drift → `skill backfill <name>` → `rcup`).
