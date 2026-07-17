#!/usr/bin/env bash

set -euo pipefail

cd /ai-interview

mkdir -p tmp/pids tmp/cache tmp/sockets log
rm -f tmp/pids/server.pid

bundle check >/dev/null 2>&1 || bundle install

until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" >/dev/null 2>&1; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails runner script/bootstrap_local.rb

exec bundle exec puma -C config/puma.rb
