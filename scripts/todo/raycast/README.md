# Todo Raycast Extension

Commands for interacting with the local `todo` CLI through Raycast.

## Command

- **`todo`** — Typing `todo` opens the filtered list (mirrors `todo list --json --lookback-days 28`). Use the dropdown in the search bar (or the "Set Lookback Window" action) to switch between 7/14/28/56-day ranges. Press `↩` to mark done, `⌘O` to open in `$EDITOR`. Typing `todo add Buy milk #errands` adds the task instantly before the list renders.

## Requirements

- The `todo` script from this repository must be available on your `PATH`.
- Any configuration (note directory, git sync, etc.) should be handled via the CLI itself.
- Raycast often runs in a minimal environment. If `todo` is not found, set `TODO_RAYCAST_BIN` (e.g. `~/.dotfiles/scripts/todo/todo`) in the command configuration or export it globally. You can also override `TODO_RAYCAST_SHELL`/`TODO_RAYCAST_USE_SHELL` if you prefer a different login shell behavior.
- Ensure any `TODO_*` env vars (e.g. `TODO_NOTE_DIR`, `TODO_AUTO_GIT_SYNC`) are available to Raycast. The simplest approach is exporting them in a login shell file like `~/.zprofile` so they’re inherited when the Raycast command launches.
- Optionally set `TODO_RAYCAST_LOOKBACK_DAYS` to change the default 28-day window shown in the list. Your configured value automatically appears in the dropdown options.
- The extension sets `TODO_RAYCAST_CONTEXT=true` and `TODO_PREFER_GUI_OPEN=true` when invoking the CLI so that `todo open` prefers GUI launchers even when `$EDITOR` points to a terminal editor.

## Development

```bash
cd todo/raycast
npm install
npm run dev
```

The commands shell out to the `todo` binary, so Raycast (and the `ray` CLI) must inherit a shell environment where `todo` resolves.
