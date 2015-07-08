#!/bin/bash
BASEDIR=$(dirname "$0")

sh "$BASEDIR/install_oh_my_zsh.sh"

if [ "$(uname)" == "Darwin" ]; then
  sh "$BASEDIR/macosx_defaults.sh"
  bash "$BASEDIR/install_macosx_homebrew.sh"
fi
if [ "$(uname)" == "Linux" ]; then
  sh "$BASEDIR/setup_linux.sh"
fi

sh "$BASEDIR/install_npm_packages.sh"
sh "$BASEDIR/install_oh_my_zsh.sh"
sh "$BASEDIR/install_ruby_with_rvm.sh"
