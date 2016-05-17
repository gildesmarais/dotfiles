#!/bin/bash
set -e
BASEDIR=$(dirname "$0")

sh "$BASEDIR/install_oh_my_zsh.sh"

if [ "$(uname)" == "Darwin" ]; then
  sh "$BASEDIR/macosx_defaults.sh"
  bash "$BASEDIR/install_macosx_homebrew.sh"
fi

if [ "$(uname)" == "Linux" ]; then
  sh "$BASEDIR/linux_setup.sh"
fi

sh "$BASEDIR/install_npm_packages.sh"
sh "$BASEDIR/install_oh_my_zsh.sh"
sh "$BASEDIR/install_ruby_with_rvm.sh"


curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p ~/versioned/github
git clone git@github.com:powerline/fonts.git ~/versioned/github/fonts
