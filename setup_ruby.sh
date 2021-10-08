#! /bin/sh
echo Setting up Ruby
if [ "$CI" = 'true' ]; then
  echo Detected the CI environment, installing bundler with sudo
  sudo gem install bundler
fi
echo Installing bundler as user
gem install --user-install bundler
echo Running bundle install
bundle install
