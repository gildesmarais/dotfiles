# Backlog groom (`groom`)

Make the board tell the truth: PO (value, Create bar) + Scrum Master (WIP, status, links). No code unless asked.

## Intake (max 2 questions; never re-ask)

1. **Depth:** `1` structure only (titles, parents, status, comments, epic roles; no new issues) | `2` (default) + evidenced Stories/Tasks | `3` + cleanup tickets the user named or code requires.
2. **Sequencing lock:** only when docs/board conflict; one sentence.

## Hard rules

- Local backlog docs are inputs; the board wins after the lock.
- **Create bar (depth ≥ 2):** cited code evidence or a named gap on a ticket; else Amend AC / Rehome / On Hold / Research Further.
- Remove → Hide (On Hold) → Consolidate (rehome/amend) → Automate → Add (create).
- Done foundation stays Done (never reopen as MVP). Close per `SKILL.md` Status lifecycle.
- Empty future epics stay parked until evidence or an explicit Create ask.
- Ticket text: short Context / Outcome / AC.
- Status names, link types, Ready transitions, Epic parent field: discover via tracker MCP / repo wrapper / `AGENTS.md`; never hardcode. Inspect a working reference card and the link schema before judging link direction.
- Create adding user-facing scope → `gate` (or user confirm) first.

## Pipeline

1. **Inventory** (tracker MCP): target epic(s) + open children (exclude Done / Won't Do / Duplicate unless diagnosing misparents), related delivery/Integration epics, named Done foundation labels, local docs claiming sequencing (cite paths); depth ≥ 2: code search for named gaps only.
2. **Target shape:** portfolio umbrella (initiative home, not a Ready dump) → active delivery epic(s) → later Integration/capability epics (soft order in prose; `Blocks` only if blocking).
3. **Disposition table:** `| Key | Keep / Rehome / On Hold / Amend AC / Create (rare) / Skip | Why (one line) |` — Skip Done misparents unless they pollute live queries.
4. **Create evidence gate:** each Create cites path + fact or ticket + gap; else drop it.
5. **Execute (approved):** retitle, rewrite, reparent, transition, closing comments, hard-order links, Creates.
6. **Verify:** re-query; no Ready orphans on the umbrella (unless project pattern); held work in hold/next status; Creates have parent + intended status; no open unparented stories or stories under Done Epics; open Epics meet the `create` epic rule and are not overdue; linked technical RFCs link both ways.

Links: hard order → the project's dependency link (often `Blocks`), one chain per active epic.

## Output before mutate

Depth + sequencing lock; target shape; disposition table; Create evidence; Forced Challenge (strongest case this groom over- or under-files; why it fails). Wait for approval unless already approved.

After mutate: keys changed, Create keys, verify notes, handoff.

## Completion criteria

- `1`: target shape stated; dispositions applied; verify pass.
- `2`: depth 1 + every Create cited and verified under parent; AC amends done.
- `3`: depth 2 + named cleanup tickets filed or deferred.
