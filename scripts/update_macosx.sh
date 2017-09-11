#!/bin/sh
set -e

function command_exists {
  type "$1" >/dev/null 2>&1;
}

sudo softwareupdate -i -a

brew update && brew upgrade; brew cleanup

if command_exists mas; then
  mas upgrade
fi

if command_exists npm; then
  npm update -g npm
  npm -g update
fi

if command_exists yarn; then
  yarn global upgrade
fi

if command_exists rvm; then
  rvm @global do gem update
fi

if command_exists pip; then
  sudo pip install --upgrade pip && pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U
fi
