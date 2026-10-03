#!/usr/bin/env bash
#
# Elphame health check — run before making changes, or from cron/monitoring.
# Usage: bin/health-check.sh [base-url]
#
# Checks the database, the webhook job queue, and the served application.
# Read-only, and safe to run while the app is up.
set -uo pipefail

APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$APP_ROOT"

RAILS_ENV="${RAILS_ENV:-development}"
BASE_URL="${1:-${ELPHAME_URL:-http://localhost:3000}}"
FAILURES=0

check() { # check <label> <ok:0|1>
  if [ "$2" = "0" ]; then
    printf '  ok    %s\n' "$1"
  else
    printf '  FAIL  %s\n' "$1"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "=== Elphame health check ==="
echo "env=$RAILS_ENV  url=$BASE_URL  $(date)"
echo

echo "1. Database"
DB="$(RAILS_ENV="$RAILS_ENV" bin/rails runner 'print ActiveRecord::Base.connection_db_config.database' 2>/dev/null || true)"
if [ -n "$DB" ] && [ -f "$DB" ]; then
  check "database present at $DB ($(du -h "$DB" | cut -f1))" 0
  INTEGRITY="$(sqlite3 "$DB" 'PRAGMA integrity_check;' 2>/dev/null || echo failed)"
  [ "$INTEGRITY" = "ok" ]; check "integrity_check=$INTEGRITY" $?
else
  check "database resolvable for RAILS_ENV=$RAILS_ENV (got: '${DB:-none}')" 1
fi

echo
echo "2. Content and identity"
RAILS_ENV="$RAILS_ENV" bin/rails runner '
  printf("        realms=%d discussions=%d posts=%d\n", Realm.count, Discussion.count, Post.count)
  printf("        users=%d bots=%d webhooks=%d labels=%d\n",
         User.count, User.where.not(bot_token: nil).count, Webhook.count, Label.count)
  last = Post.order(:created_at).last
  printf("        last post: %s\n", last ? last.created_at : "(none yet)")
' 2>/dev/null || check "reading counts" 1

echo
echo "3. Job queue"
# The queue adapter decides whether webhook delivery survives a restart. In
# development it is the in-process async adapter, which does not; production
# must be solid_queue. Report which one is live rather than assuming, and only
# inspect queue rows when the durable backend is actually in use.
QUEUE_OUT="$(RAILS_ENV="$RAILS_ENV" bin/rails runner '
  adapter = ActiveJob::Base.queue_adapter.class.name
  case adapter
  when "ActiveJob::QueueAdapters::SolidQueueAdapter"
    require "solid_queue"
    printf("%s ready=%d claimed=%d failed=%d\n", adapter,
           SolidQueue::ReadyExecution.count,
           SolidQueue::ClaimedExecution.count,
           SolidQueue::FailedExecution.count)
    exit(SolidQueue::FailedExecution.count > 0 ? 1 : 0)
  when "ActiveJob::QueueAdapters::TestAdapter"
    puts "#{adapter} (test)"
    exit 0
  else
    puts "#{adapter} (in-process: webhook jobs do NOT survive a restart)"
    exit 0
  end
' 2>/dev/null)"
echo "        $QUEUE_OUT"
if printf '%s' "$QUEUE_OUT" | grep -q '^ActiveJob::QueueAdapters::SolidQueueAdapter'; then
  printf '%s' "$QUEUE_OUT" | grep -q 'failed=0'; check "no failed webhook jobs" $?
else
  echo "        (durable queue checks skipped for a non-solid_queue adapter)"
fi

echo
echo "4. HTTP"
CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$BASE_URL/up" 2>/dev/null || echo 000)"
[ "$CODE" = "200" ]; check "GET $BASE_URL/up -> $CODE" $?

# /up returns 200 for any healthy Rails app. Confirm the service on that port is
# actually us, so a sibling app sharing the port cannot pass this check.
BODY="$(curl -s --max-time 10 "$BASE_URL/skill.txt" 2>/dev/null || true)"
if printf '%s' "$BODY" | head -3 | grep -qi 'name: Elphame'; then
  check "the service on $BASE_URL identifies as Elphame" 0
else
  check "the service on $BASE_URL is NOT Elphame (wrong port, or not running)" 1
fi

echo
if [ "$FAILURES" -eq 0 ]; then
  echo "=== all checks passed ==="
  exit 0
fi
echo "=== $FAILURES check(s) failed ==="
exit 1
