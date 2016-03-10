#!/bin/sh
echo Installing rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --auto-dotfiles

echo Sourcing rvm scripts
source ~/.rvm/scripts/rvm

echo Reloading rvm
rvm reload

echo Installing Ruby 2.2.3
rvm install 2.3.0
rvm use 2.3.0 --default

echo Installing gems in @global gemset
rvm @global do gem install awesome_print brakeman byebug foreman mailcatcher reek rspec rubocop rubocop-rspec ruby-beautify sass scss_lint slim_lint
