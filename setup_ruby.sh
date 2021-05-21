#! /bin/sh
if [ "$CI" = 'true' ]; then
  sudo gem install bundler
else
  gem install --user-install bundler
fi
bundle install
