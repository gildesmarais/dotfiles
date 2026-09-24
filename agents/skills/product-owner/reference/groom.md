# Backlog groom (`groom`)

Make the board tell the truth: PO (value, Create bar) + Scrum Master (WIP, status, links) in one pass. Never invent delivery tickets; no code unless explicitly asked.

Triggers: groom backlog, epic cleanup, reparent orphans, close foundation leftovers, "what's next after X", Ready dump under the wrong epic, board sync after a sequencing decision.

Not groom: "should we build X?" → `gate`; ranking Ready items → `prioritize` (stub); slicing one feature with no board hygiene → `story-slice`; single-ticket create/implement → `jira-ticket`.

## Intake (max 1–2 questions; never re-ask locked answers)

1. **Depth:** `1` structure only (titles, parents, status, comments, epic roles; no new issues) | `2` (default) + Stories/Tasks only when evidenced | `3` + cleanup tickets the user named or code clearly requires.
2. **Sequencing lock:** only when docs/board conflict; one sentence, then proceed.

## Hard rules

- Local backlog docs are inputs to reconcile; the board wins after the lock. No speculative catalog dumps.
- **Create bar (depth ≥ 2):** cited code evidence or a named gap on an existing ticket; else Amend AC / Rehome / On Hold / Research Further.
- Remove → Hide (On Hold) → Consolidate (rehome/amend) → Automate → Add (create).
- Done foundation stays Done (comment it's closed; never reopen as MVP).
- Empty future epics stay empty (park in a holding status) until evidence or an explicit Create ask.
- Ticket text: short Context / Outcome / AC; no epic essays.
- Status names, link types, Ready transitions, Epic parent field: discover via tracker MCP / repo-local wrapper / `AGENTS.md`; never hardcode.
- Create that adds user-facing scope → `gate` (or user confirm) first.

## Pipeline

Present a disposition plan before mutating unless a concrete plan is already approved.

1. **Inventory** (prefer Atlassian or project tracker MCP): target epic(s) + open children (exclude Done / Won't Do / Duplicate unless diagnosing misparents), related delivery/Integration epics, named Done foundation labels, local docs claiming sequencing (cite paths); depth ≥ 2: code search only for gaps named in the ask or on tickets.
2. **Target shape:** portfolio umbrella (initiative home, not a Ready dump) → active delivery epic(s) → later Integration/capability epics (soft then-order in prose; `Blocks` only where truly blocking).
3. **Disposition table:** `| Key | Keep / Rehome / On Hold / Amend AC / Create (rare) / Skip | Why (one line) |` — Skip Done misparents unless they pollute queries in use.
4. **Create evidence gate:** each Create cites path + fact or ticket + gap; else drop it.
5. **Execute (approved):** retitle, rewrite, reparent, transition, closing comments, hard-order links, approved Creates. Optionally sync an existing local backlog doc.
6. **Verify:** re-query; no Ready orphans on the umbrella (unless that's the project pattern); held work in hold/next status, not Ready; Creates have parent + intended status (move out of unhelpful defaults like On Hold unless asked); tracker parent/resolution quirks fixed or called out.

Links: hard order → the project's discovered dependency link (often `Blocks`), one clear chain on the active epic; soft order → epic prose. Over-linking creates false WIP.

## Output before mutate

1. Depth + sequencing lock 2. Target shape 3. Disposition table 4. Create evidence (or "none") 5. Forced Challenge: strongest case this groom over- or under-files, and why it fails. Wait for approval unless a plan was attached.

After mutate: keys changed, Create keys, verify notes, handoff.

## Handoff

```text
product-owner groom
  structure clean + active epic Ready → jira-ticket / $dev for Story implement
  Create that expands surface without gate → product-owner gate first
  ranking only among Ready items → prioritize (stub) or stop
  slicing one feature, no hygiene → story-slice
```

## Completion criteria

- `1`: target shape stated; dispositions applied; verify pass; no new issues.
- `2`: depth 1 + every Create cited and verified under parent; AC amends done.
- `3`: depth 2 + named cleanup tickets filed or explicitly deferred.
