# Todo Raycast Extension

Commands for interacting with the local `todo` CLI through Raycast.

## Available Commands

- **Todo List (`todo`)** — Shows open todos from the past few weeks (mirrors `todo motd`).
- **Add Todo** — Prompts for a single line and runs `todo add`.
- **Quick Todo** — `no-view` command with an inline argument. Type `todo buy milk` (or `todo 'buy milk #errands'`) directly in Raycast to add instantly.

## Requirements

- The `todo` script from this repository must be available on your `PATH`.
- Any configuration (note directory, git sync, etc.) should be handled via the CLI itself.
- Raycast often runs in a minimal environment. If `todo` is not found, set `TODO_RAYCAST_BIN` (e.g. `~/.dotfiles/scripts/todo/todo`) in the command configuration or export it globally. You can also override `TODO_RAYCAST_SHELL`/`TODO_RAYCAST_USE_SHELL` if you prefer a different login shell behavior.
- Ensure any `TODO_*` env vars (e.g. `TODO_NOTE_DIR`, `TODO_AUTO_GIT_SYNC`) are available to Raycast. The simplest approach is exporting them in a login shell file like `~/.zprofile` so they’re inherited when the Raycast command launches.

## Development

```bash
cd todo/raycast
npm install
npm run dev
```

The commands shell out to the `todo` binary, so Raycast (and the `ray` CLI) must inherit a shell environment where `todo` resolves.
