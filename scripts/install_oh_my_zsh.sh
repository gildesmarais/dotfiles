#!/bin/sh
# Installing .oh-my-zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

mkdir -p ~/versioned/github

git clone git@github.com:jeremyFreeAgent/oh-my-zsh-powerline-theme.git ~/versioned/github/oh-my-zsh-powerline-theme
ln -s ~/versioned/github/oh-my-zsh-powerline-theme/powerline.zsh-theme ~/.oh-my-zsh/themes/powerline.zsh-theme
