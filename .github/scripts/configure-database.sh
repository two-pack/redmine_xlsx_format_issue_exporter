#!/bin/bash
set -euo pipefail

printf 'test:\n  adapter: sqlite3\n  database: db/test.sqlite3\n' > config/database.yml
