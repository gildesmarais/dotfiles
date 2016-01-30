#!/bin/bash

if ! type 'brew' > /dev/null; then
  echo Installing homebrew
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  echo Installing required homebrew packages
  brew install homebrew/dupes/apple-gcc42 grc zsh rcm
fi

echo Linking dotfiles with rcup
rcup

echo Install optional homebrew packages
PACKAGES="archey colordiff curl faac ffmpeg git gpg-agent htop-osx httrack lame midnight-commander"
PACKAGES="$PACKAGES mp3gain nmap node ranger shellcheck the_silver_searcher tmux watch wget"
PACKAGES="$PACKAGES youtube-dl z zsh"
brew update
brew upgrade
brew cleanup
brew install $PACKAGES

echo Linking sublime text 3 config
rm -r "~/Library/Application Support/Sublime Text 3"
ln -s ~/Dropbox/Apps/Sublime-Text-3 "~/Library/Application Support/Sublime Text 3"
