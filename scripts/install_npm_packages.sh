#!/bin/sh
# TODO: check if node and npm is installed

NPM_PACKAGES="bower csscomb csslint git-contributors grunt grunt-cli htmlhint jshint npm npm-check-updates pmi spoof tmi uglify-js uncss"

npm install -g $NPM_PACKAGES
