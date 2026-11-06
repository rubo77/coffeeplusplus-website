#!/bin/bash
# Start the local Coffee++ website + phpBB forum mirror in docker.
# Website: http://localhost:8624 — MariaDB: localhost:3395 — foreground.

set -e
cd "$(dirname "$0")" && cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

[ -f dev/.env ] || { echo "dev/.env missing - copy dev/.env.example and adjust" >&2; exit 1; }
set -a; . dev/.env; set +a

echo "Website:  http://localhost:8624"
echo "Forum:    http://localhost:8624/phpBB3/"
echo "MariaDB:  localhost:3395  (db $DB_NAME, user $DB_USER)"
echo

command -v docker >/dev/null 2>&1 || {
    echo "docker is not installed. Install once with:" >&2
    echo "  apt install docker.io docker-compose-v2" >&2
    exit 1
}

# start the daemon if needed (pkexec shows a polkit dialog for auth)
if ! docker info >/dev/null 2>&1; then
    if ! systemctl is-active --quiet docker 2>/dev/null; then
        echo "docker daemon is not running - starting it ..."
        pkexec systemctl start docker || {
            echo "could not start the docker daemon" >&2; exit 1; }
    fi
    if ! docker info >/dev/null 2>&1; then
        echo "daemon is up but access to /var/run/docker.sock is denied" >&2
        echo "  once: pkexec usermod -aG docker $USER  (then log in again)" >&2
        echo "  or:   pkexec bash $0" >&2
        exit 1
    fi
fi

[ -d "$FORUM_DIR" ] || { echo "FORUM_DIR '$FORUM_DIR' does not exist" >&2; exit 1; }
[ -f "$FORUM_SQL_DUMP" ] || { echo "FORUM_SQL_DUMP '$FORUM_SQL_DUMP' does not exist" >&2; exit 1; }

# free the ports from a stale stack or leftover listeners
docker compose -f dev/docker-compose.yml down 2>/dev/null || true
for p in 8624 3395; do
    lsof -ti ":$p" 2>/dev/null | xargs -r kill 2>/dev/null || true
done

docker compose -f dev/docker-compose.yml up -d && echo "running:" && echo "  http://localhost:8624" && echo "  http://localhost:8624/phpBB3/"