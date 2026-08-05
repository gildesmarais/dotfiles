# dotfiles

Config files to set up my macOS systems and keep them in sync — Homebrew, editor configs, guided defaults, workflow scripts, and [Agent Skills](#agent-skills) for Codex and Cursor.

Maintained by [Gil Desmarais](https://gil.desmarais.de) (Berlin). Profile, projects, and links: [gildesmarais/gildesmarais](https://github.com/gildesmarais/gildesmarais).

## Getting started

- Install [homebrew](https://brew.sh/)
- `brew install rcm topgrade`
- `git clone git@github.com:gildesmarais/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && rcup -v`
- `topgrade`
- `cd ~/.dotfiles && brew bundle`
- Setup vim:

  ```sh
  mkdir -p ~/.vim/backups
  mkdir -p ~/.vim/swaps
  mkdir -p ~/.vim/undo
  ```

### Quick-start tools

| Script                           | What it does                                                                                                                          | Prerequisites                                                         |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| `./scripts/macos-defaults-apply` | Guided wizard that applies my preferred macOS defaults and prompts for the manual tweaks listed below.                                | macOS, `sudo` access for protected settings.                          |
| `./scripts/wiki`                 | `fzf`-powered browser for the local wiki directory that opens files in your preferred editor.                                         | `fzf`, `git`, `rg`, optional `VISUAL`/`EDITOR` or `WIKI_*` overrides. |
| `./scripts/download-audio`       | Fetches remote audio (e.g., YouTube URLs) and normalises them via the `process-audio` pipeline for library-ready files.               | `aria2`, `ffmpeg`, `yt-dlp`; installs live in the Brewfile.           |
| `./scripts/skill`                | Manages the `~/.dotfiles/skills` store and symlinks first-party skills into `~/.agents/skills` (`list`, `sync`, `promote`, `rename`). | Ruby 2.6+, optional `git` for auto-detecting the project root.        |
| `./scripts/playground`           | Picks or creates playground projects for `pg`; interactive mode supports `Ctrl-O` to open the highlighted folder in Finder.           | `fzf`, `rg`; macOS `open` for Finder shortcut.                        |

## Agent Skills

Personal and custom [Agent Skills](https://agentskills.io/) live in [`skills/`](skills/). First-party installs are symlinks managed by `./scripts/skill`.

| Tool                               | Role                                                                       |
| ---------------------------------- | -------------------------------------------------------------------------- |
| [`./scripts/skill`](scripts/skill) | Store hygiene + `skill sync` into `~/.agents/skills`                       |
| Manual `npx skills`                | Optional third-party packs only (see [skills/README.md](skills/README.md)) |

### Workflow

1. **Experiment** in any repo under `.agents/skills/`.
2. **Promote** proven skills: `skill promote <name>` → moves into `~/.dotfiles/skills/` and links `~/.agents/skills/<name>`.
3. **Sync** after clone/pull (or when store names change): `skill sync` (also via `topgrade` after `rcup`).

### Store hygiene

```sh
skill list
skill sync
skill promote my-skill
skill rename ruby-dev ruby
```

`promote` moves a project skill from `.agents/skills/` into the store and links it. `rename` renames a stored skill and retargets its agent symlink. `sync` creates/replaces store-owned symlinks and prunes stale ones.

If `skill sync` refuses a path, remove the conflicting real directory under `~/.agents/skills` once, then re-run.

Use `skill --project /path/to/project ...` to target a project other than the current git root or working directory.

The store currently covers Ruby/Rails development, Rust (including Microsoft's pragmatic guidelines), PR and review workflows, documentation, and domain-specific tooling (e.g. music-information retrieval). Run `skill list` for the full set.

Full paths, authoring notes, and optional packs: [skills/README.md](skills/README.md).

Implementation lives in `skill/src`, with characterization tests in `skill/test`, and `scripts/skill` stays as the thin executable entrypoint.

## macOS System Configuration

Run the following script to apply system-wide defaults:

```sh
./scripts/macos-defaults-apply
```

For settings that cannot be scripted, follow these manual steps:

- **Apple Watch Unlock:** Enable via `System Settings` > `Touch ID & Password`.
- **Three Finger Swipe:** Verify in `System Settings` > `Trackpad` > `More Gestures`.
- **Pointer Outline Color:** Configure in `System Settings` > `Accessibility`.
- **Screenshot Location:** Open the Screenshot App, navigate to `Options`, and set your preferred save location.
- **Sudo with Touch ID:**
  1.  Open the sudoers file for editing: `sudo vim /etc/pam.d/sudo`
  2.  Add the following line at the top of the file:
      ```ini
      auth       sufficient     pam_tid.so
      ```

## macOS homebrew

After symlinking the Brewfile, install the specified applications with:

```sh
brew bundle install --global
```

This step pulls down the command-line helpers the shell expects to find:

- `lsd` for the `ls`/`ll` aliases defined in `zshrc`.
- `zsh-autosuggestions` to enable inline completions when the plugin is available.

## ZSH Setup

1. `git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"`
2. `mkdir -p ~/.zprezto-contrib`
3. open a fresh `zsh` shell

## VSCode

Key repeat on hold is enabled via the `macos-defaults` script.

## macOS: use another default text editor

```sh
brew install duti yq
curl "https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml" \
  | yq -r "to_entries | (map(.value.extensions) | flatten) - [null] | unique | .[]" \
  | xargs -L 1 -I "{}" duti -s com.microsoft.VSCode {} all
```

Find other editors by `lsappinfo | grep 'bundleID="' | cut -d'"' -f2 | sort`.

Source: <https://alexpeattie.com/blog/associate-source-code-files-with-editor-in-macos-using-duti/>
