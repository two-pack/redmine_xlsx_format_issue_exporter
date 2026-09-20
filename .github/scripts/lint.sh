#!/bin/bash
set -euo pipefail

gem install rubocop -v 1.91.0 --no-document
rubocop --format github
