#!/bin/bash
set -euo pipefail

bundle exec rails db:create db:migrate redmine:plugins:migrate
nproc
google-chrome --version || true
chromedriver --version || true
bin/rails test "plugins/$PLUGIN/test"
