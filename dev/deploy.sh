#!/bin/bash
# Deploy the Coffee++ website files from this repo to the live docroot
# via rsync/ssh. All host/path/user config comes from dev/.env
# (gitignored), see dev/.env.example.
#
# The docroot is live: rsync runs WITHOUT --delete so files that exist
# only on the target (runtime files, separately deployed content) are
# never removed. Remove obsolete files manually.
#
# Options:
#   -h, --help     show this help and exit
#   -n, --dry-run  print the rsync itemize output without changing anything
#   --db           also export the phpBB database from the local docker
#                  container, upload it to the live host and REPLACE the
#                  live database with it (dump contains DROP TABLE, no
#                  confirmation - the live DB is fully overwritten)
#
# Required in dev/.env:
#   DEPLOY_TARGET    ssh alias of the deploy host
#   DEPLOY_PATH      docroot path on the target host
#   DEPLOY_OWNER     owner applied via rsync --chown (empty = keep ssh user)
#   DB_DUMP_REMOTE   remote path for the uploaded dump (with --db)

set -e

cd "$(dirname "$0")" && cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

show_help() {
    sed -n '2,18p' "$0"
    exit 0
}

DRY_RUN=0
WITH_DB=0
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)    show_help ;;
        -n|--dry-run) DRY_RUN=1 ;;
        --db)         WITH_DB=1 ;;
        *) echo "Unknown option: $1" >&2; show_help ;;
    esac
    shift
done

if [ -f dev/.env ]; then
    set -a; . dev/.env; set +a
fi

: "${DEPLOY_TARGET:?set DEPLOY_TARGET in dev/.env}"
: "${DEPLOY_PATH:?set DEPLOY_PATH in dev/.env}"
: "${DEPLOY_OWNER:=}"
: "${DB_DUMP_REMOTE:?set DB_DUMP_REMOTE in dev/.env}"

# repo-internal files that must never end up in the docroot
EXCLUDES="
.git
.gitignore
.tags
*.swp
*~
AGENTS.md
phpBB3
dev/.env
dev/prompts_log.md
dev/playwright/node_modules
dev/playwright/test-results
"

RSYNC_EXCLUDES=""
for e in $EXCLUDES; do RSYNC_EXCLUDES="$RSYNC_EXCLUDES --exclude=$e"; done

CHOWN_ARG=""
[ -n "$DEPLOY_OWNER" ] && CHOWN_ARG="--chown=$DEPLOY_OWNER"

if [ "$DRY_RUN" -eq 1 ]; then
    echo "Dry run: would deploy to ${DEPLOY_TARGET}:${DEPLOY_PATH} (owner $DEPLOY_OWNER):"
    rsync -avzn --itemize-changes --exclude=dev/.env.example $CHOWN_ARG $RSYNC_EXCLUDES ./ "${DEPLOY_TARGET}:${DEPLOY_PATH}/"
    [ "$WITH_DB" -eq 1 ] && echo "Dry run: would also dump dev-db-1:${DB_NAME:?set DB_NAME in dev/.env} and upload it to ${DEPLOY_TARGET}:${DB_DUMP_REMOTE}"
    exit 0
fi

echo "Ensuring docroot exists on ${DEPLOY_TARGET} ..."
ssh "$DEPLOY_TARGET" "mkdir -p '$DEPLOY_PATH'"

echo "Deploying Coffee++ site to ${DEPLOY_TARGET}:${DEPLOY_PATH} ..."
rsync -avz --itemize-changes --exclude=dev/.env.example $CHOWN_ARG $RSYNC_EXCLUDES ./ "${DEPLOY_TARGET}:${DEPLOY_PATH}/"
echo "Done. Note: files removed in the repo are NOT deleted on the target."

if [ "$WITH_DB" -eq 1 ]; then
    LOCAL_DUMP="$(dirname "${FORUM_SQL_DUMP:?set FORUM_SQL_DUMP in dev/.env}")/${DB_NAME:-phpbb}-docker.sql.gz"
    echo "Exporting local phpBB database from dev-db-1 ..."
    docker exec dev-db-1 sh -c \
        'mariadb-dump --single-transaction --quick --add-drop-table -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" | gzip' \
        > "$LOCAL_DUMP"
    gzip -t "$LOCAL_DUMP"
    echo "Uploading to ${DEPLOY_TARGET}:${DB_DUMP_REMOTE} ..."
    rsync -avz "$LOCAL_DUMP" "${DEPLOY_TARGET}:${DB_DUMP_REMOTE}"
    echo "Replacing the live database (DROP TABLE + import) ..."
    ssh "$DEPLOY_TARGET" "php -r 'include \"$DEPLOY_PATH/phpBB3/config.php\";
        passthru(\"zcat $DB_DUMP_REMOTE | mysql -h \".\$dbhost.\" -u \".\$dbuser.\" -p\".\$dbpasswd.\" \".\$dbname);'"
    echo "Done. Live database replaced with the local export."
fi