FROM cs50/cli:amd64
ARG DEBIAN_FRONTEND=noninteractive


# Default port (to match CS50 IDE)
EXPOSE 8080


# Unset user
USER root


# Install packages
RUN apt update && \
    apt install --no-install-recommends --yes \
        libcurl4-openssl-dev `# Required by passenger-config` \
        libmysqlclient-dev `# For mysql` \
        mysql-client `# For mysql` \
        php-fpm \
        php-xdebug
RUN gem install \
        rack
RUN pip3 install \
        Django \
        Flask \
        Flask-Migrate \
        Flask-Session \
        mysqlclient \
        raven[flask] \
        SQLAlchemy


# Install Passenger
# https://www.phusionpassenger.com/library/install/standalone/install/oss/bionic/
# https://stackoverflow.com/a/49462622
RUN apt install --no-install-recommends --yes dirmngr gnupg && \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    apt install --no-install-recommends --yes apt-transport-https ca-certificates && \
    echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main" > /etc/apt/sources.list.d/passenger.list && \
    apt update && \
    apt install --install-recommends --yes passenger && \
    passenger-config build-native-support && \
    mkdir -p /opt/nginx/build-modules && \
    wget --directory-prefix /tmp https://github.com/openresty/headers-more-nginx-module/archive/v0.34.tar.gz && \
    tar xzf /tmp/v0.34.tar.gz -C /opt/nginx/build-modules && \
    passenger-install-nginx-module --auto --extra-configure-flags="--add-module=/opt/nginx/build-modules/headers-more-nginx-module-0.34" --prefix=/opt/nginx && \
    rm -f /tmp/v0.34.tar.gz


# Copy files to image
COPY ./etc /etc
COPY ./opt /opt
RUN chmod a+rx /opt/cs50/bin/*
ENV PATH /opt/cs50/bin:"$PATH"


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
