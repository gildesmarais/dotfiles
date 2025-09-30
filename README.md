# dotfiles

This repository contains config files to set up my systems and keep them in sync.

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

| Script                           | What it does                                                                                                            | Prerequisites                                                         |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| `./scripts/macos-defaults-apply` | Guided wizard that applies my preferred macOS defaults and prompts for the manual tweaks listed below.                  | macOS, `sudo` access for protected settings.                          |
| `./scripts/wiki`                 | `fzf`-powered browser for the local wiki directory that opens files in your preferred editor.                           | `fzf`, `git`, `rg`, optional `VISUAL`/`EDITOR` or `WIKI_*` overrides. |
| `./scripts/download-audio`       | Fetches remote audio (e.g., YouTube URLs) and normalises them via the `process-audio` pipeline for library-ready files. | `aria2`, `ffmpeg`, `yt-dlp`; installs live in the Brewfile.           |

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
