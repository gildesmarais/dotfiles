---
name: omnifocus
description: >-
  Operate the user's OmniFocus database through the omnifocus-operator MCP. Use
  when the user mentions OmniFocus, GTD, inbox processing, tags, projects,
  folders, defer dates, or perspectives.
---

# OmniFocus

Namespace `user-omnifocus-operator`. Discover schemas before calling. Dates are local. Tag names are case-insensitive; collisions error — pass IDs.

## Load

| Need                                                                              | Read                                                   |
| --------------------------------------------------------------------------------- | ------------------------------------------------------ |
| List, count, or answer from existing records                                      | nothing else                                           |
| Create, drop, delete, or reorder tags or folders; or `edit_tasks` times out twice | [`reference/applescript.md`](reference/applescript.md) |

## Laws

1. **Read first.** `list_projects` and `list_tags` before any create or edit. Build the name, ID, and parent map from that response.
2. **Patch.** `edit_tasks` changes tags and location only through `actions.tags.add`, `actions.tags.remove`, and `actions.move`. Omit means no change. `null` clears. A top-level field is a full replacement of that field — use it only for that field (`deferDate`, `name`).
3. **No silent destruction.** Never drop or delete a task without an explicit single-purpose yes in this chat. Drop a tag only when `remainingTasks` is 0. Delete a tag only when it is already dropped and still empty.
4. **Defer, don't due.** Overload and "not this week" set `deferDate`. `dueDate` is a real external deadline only.
5. **Unmapped inbox stays inbox.** Below 80% project confidence, leave the task in the Inbox. Add `Needs Clarification` only if that tag already exists; do not create it.

## Gaps

MCP writes tasks only (`add_tasks`, `edit_tasks`). Tags, folders, and perspectives are not writable there. Folders have no On Hold status — put On Hold on the project.

`list_*` defaults to 50 rows. Pass `limit: null` when the count matters. Do not call `get_all` unless a filtered list cannot answer.

`edit_tasks` times out → retry the same patch once, then apply the same fields via the reference. Do not widen the patch.
