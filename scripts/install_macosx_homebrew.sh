#!/bin/bash

if ! type 'brew' > /dev/null; then
  echo Installing homebrew
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  echo Installing homebrew-cask
  brew install caskroom/cask/brew-cask

  echo Tapping homebrew taps
  brew tap caskroom/fonts

  echo Installing required homebrew packages
  brew install homebrew/dupes/apple-gcc42 grc zsh
fi

echo Install optional homebrew packages
PACKAGES="archey colordiff curl faac ffmpeg git htop-osx httrack lame midnight-commander"
PACKAGES="$PACKAGES mp3gain nmap node postgis postgresql ranger shellcheck the_silver_searcher tmux watch wget"
PACKAGES="$PACKAGES youtube-dl z"
brew update
brew upgrade
brew cleanup
brew install "$PACKAGES"

echo Installing homebrew casks
CASK_PACKAGES="alfred appcleaner bartender caffeine disk-inventory-x dropbox firefox"
CASK_PACKAGES="$CASK_PACKAGES font-fira-sans font-fontawesome font-freesans font-inconsolata font-roboto font-source-code-pro font-ubuntu"
CASK_PACKAGES="$CASK_PACKAGES gitx gpgtools  imageoptim istat-menus iterm2 keepassx launchrocket pixelstick slack sourcetree spectacle"

brew cask install "$CASK_PACKAGES"
