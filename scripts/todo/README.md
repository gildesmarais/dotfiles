# Todo Script

A modular, command-line todo management system that integrates with daily notes.

## Features

- Add todos to daily notes
- List todos by scope (today, week, all)
- Mark todos as done with fuzzy selection
- Message of the day (MOTD) for shell startup
- Compact multi-day listings
- Auto-git-sync for seamless cross-machine workflow

## Commands

- `add [items]` - Adds one or more tasks to the daily note
- `list [scope]` - Displays tasks. Scope can be 'today' (default), 'week', or 'all'
- `motd` - Displays the last four weeks of open todos for shell startup
- `done` - Fuzzy-pick open tasks (from all notes) and mark them done
- `help` - Show help message

## Auto-Git-Sync

The todo script can automatically sync with git after adding todos, enabling seamless cross-machine workflow.

### Setup

1. **Enable auto-sync** in your shell config (`.zshrc`, `.bashrc`, etc.):
   ```bash
   export TODO_AUTO_GIT_SYNC=true
   ```

2. **Ensure your notes directory is a git repository**:
   ```bash
   cd ~/Documents/notes  # or your TODO_NOTE_DIR
   git init
   git remote add origin <your-notes-repo-url>
   ```

3. **Configure git for clean pulls** (optional):
   ```bash
   git config pull.ff only
   ```

### How It Works

When `TODO_AUTO_GIT_SYNC=true`:
1. After adding a todo, the script automatically:
   - Pulls latest changes from remote
   - Adds the modified note file
   - Commits with message "Add todo: [item]"
   - Pushes to remote

2. Uses merge strategy for conflict-free, interrupt-free operation
3. Only acts on the modified note file
4. Provides verbose output when `-v` flag is used

### Benefits

- **Interrupt-free**: No git conflicts or prompts
- **Always fresh**: Pulls latest changes before adding todos
- **Automatic**: No need to remember git commands
- **Cross-machine**: Todos sync automatically across devices
- **Configurable**: Can be enabled/disabled per environment

## Configuration

Set these environment variables to customize behavior:

- `TODO_NOTE_DIR` - Directory for daily notes (default: `$HOME/Documents/notes/daily`)
- `TODO_USE_GLOW` - Use glow for markdown rendering (default: auto-detect)
- `TODO_AUTO_GIT_SYNC` - Enable automatic git sync (default: false)
- `TODO_AUTO_COMMIT` - Auto-commit the note after running `todo note` (default: false)
- `TODO_MOTD_LOOKBACK_DAYS` - Number of days to scan for MOTD (default: 28)

## Testing

You can run a lightweight regression check (no git operations) with:

```bash
bash todo/test/smoke.sh
```

It creates a temporary notes directory and exercises `add`, `list week`, and `motd`.

## Examples

```bash
# Add a todo (auto-syncs if enabled)
todo add "Buy groceries #errands"

# List today's open tasks
todo list

# List all open tasks for the week
todo list week -o

# Mark a task as done
todo done
```
