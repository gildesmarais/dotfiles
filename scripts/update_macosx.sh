#!/bin/sh
sudo softwareupdate -i -a
brew update && brew upgrade; brew cleanup
npm -g update
gem update
