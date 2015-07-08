#!/bin/sh
echo Installing rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --rails

echo Reloading rvm
rvm reload

echo Installing gems
GEMS="awesome_print beautify-ruby bundle byebug foreman heroku mailcatcher rspec rubocop rubucop sass scss-lint slim_lint"
gem install "$GEMS"
