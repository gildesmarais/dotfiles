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

## macOS homebrew

After symlinking the Brewfile, install the specified applications with:

```sh
brew bundle install --global
```

## macOS Screenshot

1. Open Screenshot App, Options, Location -> Other Location
2. `defaults write com.apple.screencapture disable-shadow -bool true`
3. Drag "Location" to Dock, open as Fan

## macOS Configure sudo to auth with TouchID

```sh
sudo vim /etc/pam.d/sudo
```

Add as first line:

```ini
auth       sufficient     pam_tid.so
```

## ZSH Setup

1. `git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"`
2. `mkdir -p ~/.zprezto-contrib`
3. open a fresh `zsh` shell

## VSCode

1. Enable key repeat on hold: `defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false`

## macOS: use another default text editor

```sh
brew install duti yq
curl "https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml" \
  | yq -r "to_entries | (map(.value.extensions) | flatten) - [null] | unique | .[]" \
  | xargs -L 1 -I "{}" duti -s com.microsoft.VSCode {} all
```

Find other editors by `lsappinfo | grep 'bundleID="' | cut -d'"' -f2 | sort`.

Source: <https://alexpeattie.com/blog/associate-source-code-files-with-editor-in-macos-using-duti/>
