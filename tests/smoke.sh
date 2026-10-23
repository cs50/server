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

echo "OK"
