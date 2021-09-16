FROM cs50/cli:minimal
ARG DEBIAN_FRONTEND=noninteractive


# Default port (to match CS50 IDE)
EXPOSE 8080


# Unset user
USER root


# Install Ubuntu packages
RUN apt update && \
    apt install -y \
        libcurl4-openssl-dev `# Required by passenger-config` \
        libmysqlclient-dev `# For mysql` \
        mysql-client `# For mysql` \
        php-fpm \
        php-xdebug
RUN gem install \
        rack
RUN pip install \
        Django \
        Flask-JSGlue \
        raven[flask] \
        SQLAlchemy


# Install Passenger
# https://www.phusionpassenger.com/library/install/standalone/install/oss/bionic/
# https://stackoverflow.com/a/49462622
RUN apt install -y dirmngr gnupg && \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    apt install -y apt-transport-https ca-certificates && \
    echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main" > /etc/apt/sources.list.d/passenger.list && \
    apt update && \
    apt install -y passenger && \
    passenger-config build-native-support && \
    mkdir -p /opt/nginx/build-modules && \
    wget --directory-prefix /tmp https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz && \
    tar xzf /tmp/v0.33.tar.gz -C /opt/nginx/build-modules && \
    passenger-install-nginx-module --auto --extra-configure-flags="--add-module=/opt/nginx/build-modules/headers-more-nginx-module-0.33" --prefix=/opt/nginx && \
    rm -f /tmp/v0.33.tar.gz


# Install server's own config files
RUN mkdir --parent /opt/cs50/bin && \
    chmod a+rx /opt/cs50 /opt/cs50/bin
ENV PATH /opt/cs50/bin:"$PATH"
COPY ./bin/* /opt/cs50/bin/
RUN chmod a+rx /opt/cs50/bin/*
COPY ./etc/* /usr/local/etc/
RUN chmod a+r /usr/local/etc/*


# When child image is built from this one, copy its files into image
ONBUILD COPY . /var/www/
ONBUILD RUN chown -R www-data:www-data /var/www
WORKDIR /var/www


# Install packages, if any
ONBUILD RUN (test -f package.json && npm install) || true
ONBUILD RUN (test -f requirements.txt && pip install -r requirements.txt) || true


# Start server within WORKDIR
CMD ["passenger", "start"]
