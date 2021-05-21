#! /bin/sh
if [ "$CI" = 'true' ]; then
  sudo gem install --user-install bundler
fi
bundle install
