#!/bin/sh
set -eu

legacy_db="/app/data/rss_reader.db"
rssnook_db="/app/data/rssnook.db"
default_url="sqlite+aiosqlite:////app/data/rssnook.db"

# Preserve existing installations when upgrading from the former project name.
if [ "${DATABASE_URL:-$default_url}" = "$default_url" ] && [ ! -e "$rssnook_db" ] && [ -e "$legacy_db" ]; then
  mv "$legacy_db" "$rssnook_db"
fi

chown -R appuser:appuser /app/data
exec gosu appuser "$@"
