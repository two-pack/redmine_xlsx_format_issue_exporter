#!/bin/bash
set -euo pipefail

usage='usage: docker.sh <lint|test> --ruby <version> [--redmine <ref>]'
job=${1:?$usage}
shift
ruby=
redmine=
while [ $# -gt 0 ]; do
  case $1 in
    --ruby) ruby=${2:?$usage}; shift 2 ;;
    --ruby=*) ruby=${1#*=}; shift ;;
    --redmine) redmine=${2:?$usage}; shift 2 ;;
    --redmine=*) redmine=${1#*=}; shift ;;
    *) echo "$usage" >&2; exit 1 ;;
  esac
done
: "${ruby:?$usage}"
if [ "$job" = test ]; then
  : "${redmine:?a Redmine ref is required for the test job}"
fi
if [[ $redmine =~ ^[0-9]+\.[0-9]+$ ]]; then
  redmine=$redmine-stable
fi

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

image=ruby:$ruby
if [ "$job" = test ]; then
  image=redmine-xlsx-ci:ruby-$ruby
  docker build --tag "$image" --build-arg "RUBY_VERSION=$ruby" .github/docker
fi

source_dir=$(mktemp -d)
artifacts=$(mktemp -d)
trap 'rm -rf "$source_dir"' EXIT
git ls-files -z --cached --others --exclude-standard | tar --null --ignore-failed-read -T - -cf - | tar -xf - -C "$source_dir"

status=0
docker run --rm --init --cpus 4 \
  -v "$source_dir:/work:ro" -v "$artifacts:/out" \
  "$image" bash /work/.github/scripts/docker-job.sh "$job" "$redmine" || status=$?

if [ -n "$(ls -A "$artifacts")" ]; then
  echo "Failure artifacts: $artifacts"
else
  rmdir "$artifacts"
fi
exit "$status"
