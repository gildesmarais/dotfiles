#!/bin/sh
set -e
# TODO: check if node and npm is installed

nvm install --lts
brew install yarn --without-node

NPM_PACKAGES="csscomb csslint git-contributors grunt grunt-cli htmlhint jshint pmi spoof tmi uglify-js uncss"

npm install -g $NPM_PACKAGES
