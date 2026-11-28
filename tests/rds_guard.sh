#!/bin/bash
# Validate cs50_rds_guard end-to-end against two MySQL servers (an "old primary" that is made
# read-only, and the writer), plus the process-wide opt-out and interpreter startup overhead.
#
#   tests/rds_guard.sh [IMAGE]   (default: cs50/server)
#
# The module is bind-mounted into the image's site-packages so the test exercises the repo's
# working copy without rebuilding the image.

set -euo pipefail
cd "$(dirname "$0")/.."

IMAGE="${1:-cs50/server}"
NET="rds-guard-$$"
PASSWORD="crimson"
MYSQL_IMAGE="${MYSQL_IMAGE:-mysql:8.4}"

cleanup() { docker rm --force "$NET-blue" "$NET-green" >/dev/null 2>&1 || true; docker network rm "$NET" >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker network create "$NET" >/dev/null
for color in blue green; do
    docker run --detach --name "$NET-$color" --network "$NET" --hostname "$color" \
        --env MYSQL_ROOT_PASSWORD="$PASSWORD" --env MYSQL_DATABASE=t "$MYSQL_IMAGE" >/dev/null
done
echo "Waiting for MySQL..."
for color in blue green; do
    until docker exec "$NET-$color" mysqladmin --user=root --password="$PASSWORD" --silent ping >/dev/null 2>&1; do sleep 1; done
done

SITE="$(docker run --rm --entrypoint python3 "$IMAGE" -c 'import site; print(site.getsitepackages()[0])')"
MOUNTS=(--volume "$PWD/opt/cs50/lib/python/cs50_rds_guard.py:$SITE/cs50_rds_guard.py:ro"
        --volume "$PWD/opt/cs50/lib/python/cs50_rds_guard.pth:$SITE/cs50_rds_guard.pth:ro"
        --volume "$PWD/tests/rds_guard_test.py:/tmp/rds_guard_test.py:ro")

echo; echo "== behaviour =="
docker run --rm --network "$NET" "${MOUNTS[@]}" \
    --env MYSQL_PASSWORD="$PASSWORD" --env MYSQL_BLUE="$NET-blue" --env MYSQL_GREEN="$NET-green" \
    --entrypoint python3 "$IMAGE" /tmp/rds_guard_test.py

echo; echo "== process-wide opt-out (CS50_ALLOW_READ_ONLY_DB=1) =="
docker run --rm "${MOUNTS[@]}" --env CS50_ALLOW_READ_ONLY_DB=1 --entrypoint python3 "$IMAGE" -c '
import sqlalchemy, cs50_rds_guard, sys
assert not cs50_rds_guard._registered, "guard should not register when opted out"
assert not any(type(f).__name__ == "_SQLAlchemyImportHook" for f in sys.meta_path), "no import hook when opted out"
print("PASS  opt-out leaves SQLAlchemy untouched")'

echo; echo "== no SQLAlchemy import => no SQLAlchemy loaded, negligible startup cost =="
docker run --rm "${MOUNTS[@]}" --entrypoint python3 "$IMAGE" -c '
import sys, cs50_rds_guard
assert "sqlalchemy" not in sys.modules, "guard must not import SQLAlchemy eagerly"
assert any(type(f).__name__ == "_SQLAlchemyImportHook" for f in sys.meta_path), "lazy hook should be armed"
print("PASS  sqlalchemy not imported; lazy hook armed")'
docker run --rm --entrypoint bash "$IMAGE" -c 'for i in 1 2 3; do s=$(date +%s%N); python3 -c pass; echo "  without guard: $(( ($(date +%s%N)-s)/1000000 )) ms"; done'
docker run --rm "${MOUNTS[@]}" --entrypoint bash "$IMAGE" -c 'for i in 1 2 3; do s=$(date +%s%N); python3 -c pass; echo "  with guard:    $(( ($(date +%s%N)-s)/1000000 )) ms"; done'
