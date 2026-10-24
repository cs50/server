#!/bin/bash
# Smoke-tests a built cs50/server image. Usage: tests/smoke.sh [IMAGE]
# Each check has a timeout so that a regression that hangs fails loudly.

set -o errexit -o nounset -o pipefail

IMAGE="${1:-cs50/server}"
run() { timeout 60 docker run --rm "$@"; }

echo "Checking $IMAGE"

echo "- passenger resolves to the CS50 wrapper without a login shell (as exec-form CMD and downstream CMD overrides run it)"
test "$(run "$IMAGE" bash -c 'type -P passenger')" = /opt/cs50/bin/passenger

echo "- passenger resolves to the CS50 wrapper in a login shell too (as make run does)"
test "$(run "$IMAGE" bash --login -c 'type -P passenger')" = /opt/cs50/bin/passenger

echo "- the wrapper is executable and calls the real binary by absolute path"
run "$IMAGE" bash -c 'test -x /opt/cs50/bin/passenger && grep -q "^/usr/bin/passenger " /opt/cs50/bin/passenger'

echo "- the wrapper's PHP_VERSION matches the installed PHP-FPM and the nginx template (catches a base-image PHP bump)"
run "$IMAGE" bash -c 'v=$(sed -n "s/^PHP_VERSION=//p" /opt/cs50/bin/passenger); test -n "$v" && test -x /etc/init.d/php$v-fpm && test -f /etc/php/$v/fpm/pool.d/www.conf && test -f /usr/lib/php/$v/php.ini-production && grep -q "php$v-fpm.sock" /opt/cs50/etc/nginx.conf.erb'

echo "- Passenger's Ruby native support is prebuilt for the image's Ruby (so apps need not compile it on first spawn)"
run "$IMAGE" bash -c 'test -f "$(ruby -e "print RbConfig::CONFIG[\"sitearchdir\"]")/passenger_native_support.so"'

echo "- passenger start serves a Flask app end-to-end (nginx, Passenger, Python)"
cid=$(docker run --detach --rm --publish 127.0.0.1::8080 --volume "$(cd "$(dirname "$0")/.." && pwd)/examples/flask":/var/www:ro "$IMAGE")
trap 'docker stop "$cid" > /dev/null 2>&1 || true' EXIT
port=$(docker port "$cid" 8080 | head -n 1 | sed 's/.*://')
for _ in $(seq 1 90); do
    body=$(curl --silent --max-time 5 "http://127.0.0.1:$port/" || true)
    [ "$body" = "hello, world" ] && break
    sleep 1
done
test "$body" = "hello, world" || { echo "unexpected response: $body" >&2; docker logs "$cid" 2>&1 | tail -n 20 >&2; exit 1; }
docker stop "$cid" > /dev/null
trap - EXIT

echo "OK"
