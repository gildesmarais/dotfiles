# `todo` - Command-Line Note and Task Manager

`todo` is a powerful and fast command-line utility designed for developers and power users to manage daily notes and to-do lists directly from their terminal. It integrates seamlessly into your existing shell workflow, providing quick access to task management without context switching to a graphical UI.

## Features

- **Quick Task Management:** Add, list, edit, and filter tasks with simple commands.
- **Daily Notes:** Easily manage daily markdown notes with YAML front matter.
- **Fuzzy Search:** Interactive fuzzy search (`fzf`) for efficient task and note navigation.
- **Markdown Rendering:** Beautiful terminal rendering of notes (`glow`).
- **Git Integration:** Optional auto-commit feature for note changes.

## Installation

**Install Dependencies (if not already present):**
`todo` relies on the following tools:

- `yq` (for YAML front matter parsing)
- `fzf` (for interactive fuzzy search)
- `glow` (optional, for markdown rendering)
- `git` (optional, for auto-commit)

You can install them using your system's package manager (e.g., `brew` on macOS, `apt` on Debian/Ubuntu, `pacman` on Arch Linux).
Example (macOS with Homebrew):

```bash
brew install yq fzf glow git
```

## Usage

The `todo` script is invoked with `todo <command> [arguments]`.

### Available Commands:

- **`todo add <task>`**
  Adds a new to-do item to your daily note.
  Example: `todo add "Fix bug in authentication module"`

- **`todo edit [query]`**
  Opens your daily note in your preferred editor (`$EDITOR`). If a query is provided, it attempts to jump to the line containing the query.
  Example: `todo edit`
  Example: `todo edit "authentication module"`

- **`todo filter <query>`**
  Filters and displays tasks from your notes based on a query using `fzf`.
  Example: `todo filter "bug"`

- **`todo list`**
  Displays your current daily note, rendered with `glow` (if installed).
  Example: `todo list`

- **`todo meta <subcommand> [arguments]`**
  Manages YAML front matter in your daily note.
  - **`todo meta list`**
    Lists all front matter key-value pairs for the current daily note.
    Example: `todo meta list`
  - **`todo meta set <key> <value>`**
    Sets a front matter key to a specified value. If the key is `tags`, the value can be a comma-separated string (e.g., "tag1,tag2").
    Example: `todo meta set status "in progress"`
    Example: `todo meta set tags "dev,urgent"`

- **`todo motd`**
  Displays the Message of the Day, typically showing your tasks for the current day. This is often sourced in your shell's startup file.
  Example: `todo motd`

- **`todo note [query]`**
  Similar to `edit`, opens your daily note. This command is an alias for `edit`.
  Example: `todo note`
