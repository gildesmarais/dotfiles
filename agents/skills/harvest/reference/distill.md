# Distill

## Mantra standard

Format: Preventive Mantra (`SKILL.md`) — 1–2 sentences. Reject incident writeups, stack traces, debug stories, vague platitudes.

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
2. Global arch / review: generalize (strip product nouns, paths, schemas, language APIs) → tag one primary branch/lens → net-zero sparse-promote into the matching `reference/*.md` Checklist or Anti-patterns only when judgment changes and nothing covers it → drop the rest. Cap ~10 candidates per event.
3. Other scopes: read the target fresh. Covered, near-clone, or too narrow → drop; else append to `## Checklist` or `## Anti-patterns`.
4. Cap: ≤3 promoted mantras per session unless the user asks for more.
5. Target at budget → promote only by replacing or deleting a covered or obsolete line in the same edit; run `skill lint`.
6. Global store edit → `skill doctor`, then `rcup` (drift → `skill backfill <name>` → `rcup`).
