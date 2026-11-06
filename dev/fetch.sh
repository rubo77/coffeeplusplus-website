#!/bin/bash
# fetch.sh — pulls a fresh mysqldump of the live phpBB database from the
# deploy host into $FORUM_SQL_DUMP so the local docker
# mirror can be (re)seeded. Read-only on the remote side: it only parses
# the live config.php for credentials and runs mysqldump|gzip.
#
# Run: bash dev/fetch.sh [-h]
set -e
cd "$(dirname "$0")/.."

usage() {
    cat <<'EOF'
Usage: bash dev/fetch.sh

Downloads the live phpBB database as a gzipped SQL dump to FORUM_SQL_DUMP
(used by docker-compose as the MariaDB seed on first boot).

Configuration (dev/.env, see dev/.env.example):
  DEPLOY_TARGET      ssh alias of the live host
  FORUM_DIR_REMOTE   phpBB directory on the live host (holds config.php)
  FORUM_SQL_DUMP     local target file for the dump (.sql.gz)

To re-seed the local mirror afterwards:
  docker compose -f dev/docker-compose.yml down -v && bash dev/run.sh
EOF
}
[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && { usage; exit 0; }

[ -f dev/.env ] && . ./dev/.env
: "${DEPLOY_TARGET:?set DEPLOY_TARGET in dev/.env}"
: "${FORUM_DIR_REMOTE:?set FORUM_DIR_REMOTE in dev/.env}"
: "${FORUM_SQL_DUMP:?set FORUM_SQL_DUMP in dev/.env}"

mkdir -p "$(dirname "$FORUM_SQL_DUMP")"
tmp="$FORUM_SQL_DUMP.part"

# credentials are parsed on the remote host from the live config.php and
# never enter the local shell; mysqldump output is gzipped remote-side
read -r -d '' PHP <<EOF || true
include '$FORUM_DIR_REMOTE/config.php';
passthru('mysqldump --single-transaction --quick -h '
    . escapeshellarg(\$dbhost) . ' -u ' . escapeshellarg(\$dbuser)
    . ' -p' . escapeshellarg(\$dbpasswd) . ' ' . escapeshellarg(\$dbname)
    . ' | gzip');
EOF

echo "==> dumping phpBB database on $DEPLOY_TARGET ..."
ssh "$DEPLOY_TARGET" "php -r $(printf %q "$PHP")" > "$tmp"

gzip -t "$tmp"
tables=$(zgrep -c 'CREATE TABLE' "$tmp" || true)
[ "$tables" -gt 0 ] || { echo "dump contains no tables - aborting" >&2; rm -f "$tmp"; exit 1; }
mv "$tmp" "$FORUM_SQL_DUMP"
echo "==> ok: $FORUM_SQL_DUMP ($(du -h "$FORUM_SQL_DUMP" | cut -f1), $tables tables)"
