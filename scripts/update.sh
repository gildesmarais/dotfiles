#!/bin/sh
BASEDIR=$(dirname "$0")

cd ~/.dotfiles && git pull

if [ "$(uname)" == "Darwin" ]; then
  sh "$BASEDIR/update_macosx.sh"
fi

if [ "$(uname)" == "Linux" ]; then
  sh "$BASEDIR/update_linux.sh"
fi
