#!/usr/bin/env bash

set -euo pipefail

cd /ai-interview

bundle check >/dev/null 2>&1 || bundle install

until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" >/dev/null 2>&1; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

exec bundle exec sidekiq -r ./config/environment.rb -C config/sidekiq.yml
