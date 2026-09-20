#!/bin/bash
set -euo pipefail

job=${1:?usage: docker-job.sh <lint|test> [Redmine ref]}
redmine=${2:-}
status=0

case $job in
  lint)
    cd /work
    bash .github/scripts/lint.sh || status=$?
    ;;
  test)
    export RAILS_ENV=test
    export PLUGIN=redmine_xlsx_format_issue_exporter
    git clone --quiet --depth 1 --branch "${redmine:?a Redmine ref is required}" \
      https://github.com/redmine/redmine.git /w/redmine
    mkdir -p "/w/redmine/plugins/$PLUGIN"
    cp -R /work/. "/w/redmine/plugins/$PLUGIN"
    cd /w/redmine
    bash "plugins/$PLUGIN/.github/scripts/configure-database.sh"
    bundle install --jobs 4
    bash "plugins/$PLUGIN/.github/scripts/test.sh" || status=$?
    if [ "$status" -ne 0 ] && [ -d tmp/capybara ]; then
      cp -R tmp/capybara/. /out
      chmod -R a+rwX /out
    fi
    ;;
  *)
    echo "unknown job: $job" >&2
    status=1
    ;;
esac

exit "$status"
