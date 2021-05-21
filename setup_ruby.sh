#! /bin/sh
if [ "$CI" = 'true' ]; then
  sudo gem install bundler
fi
bundle install
