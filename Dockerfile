# Base image tag; ubuntu-26.04 while testing the new runtime, set back to latest when cs50/cli's ubuntu-26.04 branch is merged
ARG CLI_TAG=ubuntu-26.04
FROM cs50/cli:${CLI_TAG}
ARG DEBIAN_FRONTEND=noninteractive

# Default port
EXPOSE 443

# Unset user
USER root

# PHP version shipped by the base image's Ubuntu release (26.04 ships PHP 8.5 only)
ARG PHP_VERSION=8.5

# Minimum acceptable php8.5-fpm package version. Bumping this both busts the
# layer cache for the apt install below and makes the build fail if the
# archive (or a stale cache) would ship an older, vulnerable PHP.
# 8.5.4-0ubuntu1.5 fixes CVE-2026-109618 and CVE-2026-109619 (php2shell), USN-8948-1
ARG PHP_FPM_MIN_VERSION=8.5.4-0ubuntu1.5

# Install packages
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        libcurl4-openssl-dev `# Required by passenger-config` \
        libmysqlclient-dev `# For mysql` \
        mysql-client `# For mysql` \
        php-fpm \
        php-xdebug \
        pkg-config `# For mysqlclient` && \
    { dpkg --compare-versions "$(dpkg-query --showformat='${Version}' --show php${PHP_VERSION}-fpm)" ge "$PHP_FPM_MIN_VERSION" || \
        { echo "php${PHP_VERSION}-fpm $(dpkg-query --showformat='${Version}' --show php${PHP_VERSION}-fpm) is older than required $PHP_FPM_MIN_VERSION" >&2; exit 1; }; } && \
    gem install \
        rack && \
    pip3 install \
        Django \
        Flask \
        Flask-Migrate \
        Flask-Session \
        mysqlclient \
        python-dateutil \
        "sentry-sdk[flask]" \
        SQLAlchemy

# Install Passenger
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        gnupg && \
    curl https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key-2025.txt | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/phusion.gpg >/dev/null && \
    echo deb https://oss-binaries.phusionpassenger.com/apt/passenger $(. /etc/os-release && echo "$VERSION_CODENAME") main > /etc/apt/sources.list.d/passenger.list && \
    apt update && \
    apt install --install-recommends --no-install-suggests --yes \
        passenger && \
    mkdir --parents /opt/nginx/build-modules && \
    wget --directory-prefix /tmp https://github.com/openresty/headers-more-nginx-module/archive/v0.40.tar.gz && \
    tar xzf /tmp/v0.40.tar.gz -C /opt/nginx/build-modules && \
    passenger-install-nginx-module --auto --extra-configure-flags="--add-module=/opt/nginx/build-modules/headers-more-nginx-module-0.40" --prefix=/opt/nginx && \
    rm --force /tmp/v0.40.tar.gz

# Build Passenger's Ruby native support for the image's Ruby and install it system-wide; the package ships it only for
# Ubuntu's ruby, so otherwise each app compiles it into its own directory on first spawn (which fails if that's read-only)
RUN ruby /usr/bin/passenger-config build-native-support && \
    install -D --mode 644 /root/.passenger/native_support/*/*/passenger_native_support.so \
        "$(ruby -e 'print RbConfig::CONFIG["sitearchdir"]')/passenger_native_support.so" && \
    rm --force --recursive /root/.passenger

# Generate a self-signed SSL certificate for testing purposes
RUN mkdir --parents /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"

# Copy files to image
COPY ./etc /etc
COPY ./opt /opt
RUN chmod a+rx /opt/cs50/bin/*
# Must be ENV, not /etc/profile.d: exec-form CMD runs no login shell, and cli.sh skips root, so `passenger` would otherwise resolve to /usr/bin/passenger, bypassing the wrapper
ENV PATH=/opt/cs50/bin:"$PATH"

# When child image is built from this one, copy its files into image
ONBUILD COPY . /var/www/
ONBUILD RUN chown -R www-data:www-data /var/www
WORKDIR /var/www

# Install packages, if any
ONBUILD RUN test ! -f Gemfile || bundle install
ONBUILD RUN test ! -f package.json || npm install
ONBUILD RUN test ! -f requirements.txt || pip3 install -r requirements.txt

# Start server within WORKDIR
CMD ["passenger", "start"]
