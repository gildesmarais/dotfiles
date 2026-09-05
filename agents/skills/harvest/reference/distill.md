# Distill Reference

Turn session signals (user corrections, retry loops, review findings, unexpected pitfalls) into distilled preventive mantras.

## The Mantra Standard

Every distilled lesson must be written as an **imperative preventive mantra**:

- **Checklist item:** `"When X, always Y to prevent Z."`
- **Anti-pattern:** `"Avoid X; use Y instead because Z."`
- **Length:** 1–2 concise sentences maximum.
- **Tone:** An instruction an expert engineer recalls before repeating the mistake.
- **Reject:** Raw incident writeups, stack traces, step-by-step debug stories, or vague platitudes ("test edge cases").

## Generalization & Scope Filter

Before placing an item, determine scope:

| Scope | Condition | Transformation | Destination |
| :--- | :--- | :--- | :--- |
| **Project-Local** | Specific to this repo, custom script, internal API, or build tool | Keep exact paths, flags, file names, and domain invariants | `<project>/AGENTS.md` or `<project>/.agents/rules/*.md` |
| **Global Architecture** | Seam leakage, dual ownership, type modeling, measured perf | Strip all repo nouns; express as language-free architectural law | `~/.dotfiles/agents/skills/architecture/reference/<branch>.md` |
| **Global Review** | Detection heuristic, security trap, test gap, dead compat | Express as inspection check / review lens finding | `~/.dotfiles/agents/skills/review.gil/reference/<lens>.md` |
| **Global Language** | Language idiom, compiler quirk, gem/crate/package behavior | Express as runtime-specific syntax/perf checklist item | `~/.dotfiles/agents/skills/<lang>-dev/reference.md` |
| **Global Workflow** | Git, PR sizing, CI triage, branch hygiene | Express as SDLC checklist item | `~/.dotfiles/agents/skills/<skill>/reference/...` |

## Ingress Procedure

1. **Synthesize:** Draft the candidate mantra from the session signal.
2. **Read Fresh:** View the target reference file to inspect current checklist/anti-patterns.
3. **Deduplicate:** Search for existing coverage.
   - If already covered or a near-clone: **DROP**.
   - If too narrow/trivial: **DROP**.
   - If genuine new wisdom: append to the appropriate `## Checklist` or `## Anti-patterns` section.
4. **Cap:** At most 3 new mantras per session unless user explicitly asks for more.
5. **Sync Store:** If editing global store files in `~/.dotfiles/agents/skills/`, run:
   ```sh
   skill doctor
   rcup
   ```
