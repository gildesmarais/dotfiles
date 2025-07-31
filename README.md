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

## macOS System Configuration

Run the following script to apply system-wide defaults:

```sh
./scripts/macos-defaults
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
