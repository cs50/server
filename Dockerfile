FROM cs50/cli
ARG DEBIAN_FRONTEND=noninteractive

# Default port
EXPOSE 443

# Unset user
USER root

# Minimum acceptable php8.3-fpm package version. Bumping this both busts the
# layer cache for the apt install below and makes the build fail if the
# archive (or a stale cache) would ship an older, vulnerable PHP.
# 8.3.6-0ubuntu0.24.04.13 fixes CVE-2026-109618 and CVE-2026-109619 (php2shell), USN-8948-1
ARG PHP_FPM_MIN_VERSION=8.3.6-0ubuntu0.24.04.13

# Install packages
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        libcurl4-openssl-dev `# Required by passenger-config` \
        libmysqlclient-dev `# For mysql` \
        mysql-client `# For mysql` \
        php-fpm \
        php-xdebug \
        pkg-config `# For mysqlclient` && \
    dpkg --compare-versions "$(dpkg-query --showformat='${Version}' --show php8.3-fpm)" ge "$PHP_FPM_MIN_VERSION" || \
        { echo "php8.3-fpm $(dpkg-query --showformat='${Version}' --show php8.3-fpm) is older than required $PHP_FPM_MIN_VERSION" >&2; exit 1; } && \
    gem install \
        rack && \
    pip3 install \
        Django \
        Flask \
        Flask-Migrate \
        Flask-Session \
        mysqlclient \
        python-dateutil \
        raven[flask] \
        SQLAlchemy

# Install Passenger
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        gnupg && \
    curl https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key-2025.txt | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/phusion.gpg >/dev/null && \
    echo deb https://oss-binaries.phusionpassenger.com/apt/passenger noble main > /etc/apt/sources.list.d/passenger.list && \
    apt update && \
    apt install --install-recommends --no-install-suggests --yes \
        passenger && \
    passenger-config build-native-support && \
    mkdir --parents /opt/nginx/build-modules && \
    wget --directory-prefix /tmp https://github.com/openresty/headers-more-nginx-module/archive/v0.39.tar.gz && \
    tar xzf /tmp/v0.39.tar.gz -C /opt/nginx/build-modules && \
    passenger-install-nginx-module --auto --extra-configure-flags="--add-module=/opt/nginx/build-modules/headers-more-nginx-module-0.39" --prefix=/opt/nginx && \
    rm --force /tmp/v0.39.tar.gz

# Generate a self-signed SSL certificate for testing purposes
RUN mkdir --parents /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"

# Copy files to image
COPY ./etc /etc
COPY ./opt /opt
RUN chmod a+rx /opt/cs50/bin/*
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
