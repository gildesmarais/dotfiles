# dotfiles

This repository contains config files to set up my systems and keep them in sync.

## Getting started

- Install [homebrew](https://brew.sh/)
- `brew install rcm topgrade`
- `git clone git@github.com:gildesmarais/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && rcup -v`
- `topgrade`
- ```sh
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

## ZSH Setup

1. `git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"`
2. `mkdir -p ~/.zprezto-contrib`
3. open a fresh `zsh` shell
