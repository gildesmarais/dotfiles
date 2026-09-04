# Backlog groom (`groom`)

Make the board tell the truth. Wear PO (value, Create bar) and Scrum Master (WIP, status, links) in one pass. Do **not** invent delivery tickets. Do **not** implement code unless the user explicitly asked.

Load this file only when the branch is **`groom`**.

## Triggers

Groom backlog / epic cleanup / reparent orphans / close foundation leftovers / “what’s next after X” / Ready dump under the wrong epic / sync board after a sequencing decision.

Not groom: “should we build X?” → **`gate`**. Ranking Ready items only → **`prioritize`** (stub until authored). Slice one feature into Stories with no board hygiene → **`story-slice`** (stub). Single-ticket create/implement → `jira-ticket`.

## Intake (max 1–2 questions)

If the user already locked answers, do not re-ask.

1. **Depth**
   - `1` — structure only (titles, parents, status, comments, epic roles). No new issues.
   - `2` — structure + Stories/Tasks only when **evidenced** (code path or existing ticket gap). Default when unspecified.
   - `3` — depth 2 plus explicit cleanup tickets (tech debt / test landing) the user named or code clearly requires.
2. **Sequencing lock** — only when docs/board conflict (e.g. channel-A-first vs channel-B-first). One sentence; then proceed.

## Hard rules

- **Invent nothing.** No speculative catalog dumps from local research docs. Local backlog docs are **inputs to reconcile**, not source of truth over the board.
- **Create bar (depth ≥ 2):** Create only with cited **code evidence** _or_ a named gap already on an existing ticket. Else Amend AC / Rehome / On Hold / Research Further — never invent keys.
- **Simplification on tickets:** Remove → Hide (On Hold) → Consolidate (rehome/amend) → Automate → Add (create). Prefer leftmost.
- **Done foundation stays Done.** Do not reopen closed foundation work as MVP. Comment that it is closed; leave Done.
- **Empty future epics stay empty** until evidence or an explicit Create ask. Park with a holding status; do not invent children.
- **Short human ticket text.** Context / Outcome / AC. No epic essays as Story descriptions.
- **Project quirks are overlays.** Status names, link-type names, Ready transitions, Epic parent field → discover via tracker MCP / local product-owner wrapper / `AGENTS.md`. Do not hardcode one product’s Jira into this file.
- **Gate Create that expands product surface.** If a new Story would add user-facing scope, run **`gate`** (or stop for user confirm) before Create.

## Roles in one pass

| Moment                            | Wear                                      |
| --------------------------------- | ----------------------------------------- |
| Depth / sequencing locks          | PO                                        |
| Disposition Keep / Hold / Create  | PO (value) + SM (WIP)                     |
| Blocks / status / Ready orphans   | SM                                        |
| “Should this Story exist at all?” | PO **`gate`** when Create expands surface |

## Pipeline

Run in order. Present a disposition plan before mutating unless the user already approved a concrete plan.

### 1. Inventory

Pull from the issue tracker (prefer Atlassian MCP or the project’s tracker MCP when available):

- Target epic(s) and open children (exclude Done / Won’t Do / Duplicate unless needed for misparent diagnosis)
- Related delivery / Integration epics in the same initiative
- Done foundation / starter labels the user named
- Local backlog / product-context docs that claim sequencing (cite paths)
- For depth ≥ 2: light code search **only** for gaps named in the ask or already visible on tickets — not a full feature catalog

### 2. Target shape

State the intended hierarchy in a few lines (or a small mermaid):

- **Portfolio umbrella** — initiative home; not a dump of Ready sprint candidates
- **Active delivery epic(s)** — current ship focus
- **Later Integration / capability epics** — soft then-order in prose; hard **Blocks** only where order is truly blocking

### 3. Disposition table

Every open leftover gets one row:

| Key | Disposition                                               | Why (one line) |
| --- | --------------------------------------------------------- | -------------- |
| …   | Keep / Rehome / On Hold / Amend AC / Create (rare) / Skip | …              |

**Skip** Done misparents unless they pollute queries the team actually uses.

### 4. Evidence gate for Create

Before any Create row stays in the plan:

- Cite path + brief fact, **or** cite existing ticket + gap
- If neither → drop Create; use Amend / Hold / Research Further

### 5. Execute (when approved)

Mutate tracker issues: retitle, rewrite short descriptions, reparent, transition status, add closing comments, link Blocks where hard order matters, Create only approved evidenced rows.

Optional: sync a **local** backlog doc the repo already uses so it matches the board (web-first vs native-first, dispositions). Do not invent a new doc scheme.

### 6. Verify

Re-query children, parents, Blocks chain, and statuses. Confirm:

- No Ready orphans parked on the portfolio umbrella (unless the project explicitly uses that pattern)
- Holding work uses the project’s hold/next status — not Ready
- Create issues have parent + intended Ready/backlog status
- Parent / resolution quirks from the tracker (e.g. parent drop, stale resolution) are fixed or called out

## Linking and status guidance

- **Hard order** → dependency link the project actually has (often named `Blocks`). Discover link types; do not guess.
- **Soft order** → epic description prose (“then …”). Avoid over-linking; false WIP hurts flow.
- Prefer one clear blocker chain on the active epic’s Stories when sequence is strict (1→2→3).
- After Create: transition out of unhelpful defaults (e.g. On Hold) to the project’s backlog-ready status unless the user asked to leave it held.

## Output before mutate

Emit briefly:

1. Depth + sequencing lock (if any)
2. Target shape
3. Disposition table
4. Create evidence (or “none”)
5. Forced Challenge: one sentence — strongest case that this groom over-files or under-files, and why it fails

Wait for approval unless the user already attached an approved plan.

## Output after mutate

Keys changed, Create keys (if any), verify notes, handoff.

## Handoff

```text
product-owner groom
  structure clean + active epic Ready
    → jira-ticket / $dev for Story implement
  Create that expands surface without gate
    → product-owner gate first
  ranking only among Ready items
    → prioritize (stub) or stop
  slicing one feature, no hygiene
    → story-slice (stub) or ad-hoc Stories via jira-ticket
```

Do not start implementation during groom unless the user asked.

## Completion criteria

| Depth | Done when                                                                   |
| ----- | --------------------------------------------------------------------------- |
| `1`   | Target shape stated; dispositions applied; verify pass; no new issues       |
| `2`   | Depth 1 + every Create cited; Creates verified under parent; AC amends done |
| `3`   | Depth 2 + named cleanup tickets filed or explicitly deferred                |

## Anti-patterns

| Anti-pattern                                | Do instead                              |
| ------------------------------------------- | --------------------------------------- |
| Reopen Done foundation as MVP               | Comment closed; leave Done              |
| File entire research P-## / theme catalog   | Amend / one evidenced Story             |
| Invent children for empty Integration epics | Leave On Hold / Next                    |
| Epic essay as Story AC                      | Short Context / Outcome / AC            |
| Soft sequence as many Blocks links          | Prose then-order; Blocks only when hard |
| Project-local skill for one epic            | This org branch + thin local overlay    |
| Treat local MVP markdown as board SoT       | Reconcile; board wins after lock        |
