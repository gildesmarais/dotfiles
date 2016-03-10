#!/bin/sh
sudo softwareupdate -i -a
brew update && brew upgrade; brew cleanup
npm update -g npm
npm -g update
gem update
pip install --upgrade pip && pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U
