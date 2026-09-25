# OmniFocus writes the MCP cannot do

Run from the shell (`all` permissions). OmniFocus must be running. One script per mutation; read back the fields you changed.

```applescript
osascript <<'EOF'
tell application "OmniFocus"
  evaluate javascript "
(() => {
  const log = []
  // mutations
  return log.join('\n')
})()
"
end tell
EOF
```

Inside the heredoc, a JS newline escape is `\\n`.

## Lookup

`flattenedTags` / `flattenedProjects` / `flattenedFolders` are array-like. Prefer `byIdentifier` over scanning those arrays. `byName` may return one object or an array — require length 1 or match `id.primaryKey`.

```javascript
const task = Task.byIdentifier(id); // id is the primaryKey string
const project = Project.byIdentifier(id);
const tag = Tag.byIdentifier(id);
const folder = Folder.byIdentifier(id);
```

`tag.remainingTasks.length` is the emptiness check. `tag.status` string contains `Active`, `OnHold`, or `Dropped`.

## Tags

- Drop (reversible, remaining 0): `tag.status = Tag.Status.Dropped`. Never set `hidden` — not the drop API.
- Delete (already dropped, remaining 0, children first): `deleteObject(tag)`.
- Remove from a task with `task.removeTag(tag)` (tag object, not name); then drop the tag if nothing remaining carries it.

## Folders and projects

```javascript
const folder = new Folder("Name");
moveSections([project], folder.ending);
moveSections([folderA, folderB], library.beginning); // sidebar order
project.name = "New name";
project.status = Project.Status.OnHold; // Active | OnHold | Done | Dropped
```

`Folder.Status` is only `Active` or `Dropped`. `library` is the root section list.

## Task fields (MCP timeout fallback)

Same fields the MCP patch would have sent — nothing wider.

```javascript
task.deferDate = new Date(2026, 11, 18, 8, 0, 0); // month is 0-based
task.removeTag(tag);
```
