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

echo "- Passenger loads its prebuilt Ruby native support for the image's Ruby, as an app would (so apps need not compile it on first spawn)"
# Same bootstrap as Passenger's rack-loader, run as the app user with the compile/download fallbacks disabled, so
# this passes only if the .so the Dockerfile installed into sitearchdir is actually found and loadable
run --user www-data --env PASSENGER_COMPILE_NATIVE_SUPPORT_BINARY=0 --env PASSENGER_DOWNLOAD_NATIVE_SUPPORT_BINARY=0 "$IMAGE" \
    ruby -e 'require "#{`passenger-config about ruby-libdir`.strip}/phusion_passenger"; PhusionPassenger.locate_directories; PhusionPassenger.require_passenger_lib "native_support"; exit(defined?(PhusionPassenger::NativeSupport) ? 0 : 1)'

# serve_and_expect EXAMPLE PATH EXPECTED: runs `passenger start` (the image's CMD) with examples/EXAMPLE mounted read-only
# at /var/www, as a downstream image's app would be, and waits for GET PATH to return a body matching the regex EXPECTED.
# A container that exits early fails right away, with its logs, rather than after the full timeout.
EXAMPLES="$(cd "$(dirname "$0")/.." && pwd)/examples"
serve_and_expect() {
    local example="$1" path="$2" expected="$3" name="smoke-$$-$1" port body=
    trap 'docker rm --force "$name" > /dev/null 2>&1 || true' EXIT
    docker run --detach --name "$name" --publish 127.0.0.1::8080 --volume "$EXAMPLES/$example":/var/www:ro "$IMAGE" > /dev/null
    port=$(docker port "$name" 8080 2> /dev/null | head -n 1 | sed 's/.*://' || true)
    for _ in $(seq 1 90); do
        [ -n "$port" ] && [ "$(docker inspect --format '{{.State.Running}}' "$name")" = true ] || break
        body=$(curl --silent --max-time 5 "http://127.0.0.1:$port$path" || true)
        grep -qE "$expected" <<< "$body" && break
        sleep 1
    done
    if ! grep -qE "$expected" <<< "$body"; then
        echo "  expected a response matching '$expected' from $example at $path, got: ${body:0:200}" >&2
        docker logs "$name" 2>&1 | tail -n 20 >&2
        exit 1
    fi
    docker rm --force "$name" > /dev/null
    trap - EXIT
}

echo "- passenger start serves a Flask app end-to-end (nginx, Passenger, Python)"
serve_and_expect flask / '^hello, world$'

echo "- passenger start serves a PHP app end-to-end (nginx, PHP-FPM via the wrapper's socket), with the wrapper's PHP version"
v=$(run "$IMAGE" sed -n 's/^PHP_VERSION=//p' /opt/cs50/bin/passenger)
serve_and_expect php / "PHP Version ${v//./\\.}\\."

echo "- passenger start serves a Rack app from a read-only app root (Passenger must not compile native support into it)"
serve_and_expect rack / '^hello, world$'

echo "OK"
