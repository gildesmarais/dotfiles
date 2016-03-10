#!/bin/sh
BASEDIR=$(dirname "$0")

cd ~/.dotfiles && git pull

# only continue on MacOSX
if [ "$(uname)" == "Darwin" ]; then
  sh "$BASEDIR/update_macosx.sh"
fi

# only continue on MacOSX
if [ "$(uname)" == "Linux" ]; then
  sh "$BASEDIR/update_linux.sh"
fi
