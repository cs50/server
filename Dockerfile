FROM cs50/cli
USER root
ARG DEBIAN_FRONTEND=noninteractive

# Default port (to match CS50 IDE)
EXPOSE 8080

# Packages 
RUN apt-get update && \
    apt-get install -y \
        libcurl4-openssl-dev `# required by passenger-config` \
        libmysqlclient-dev \
        libpcre3-dev `# required by passenger-config` \
        php-fpm \
        php-memcached \
        php-mysql \
        php-xdebug
RUN pip3 install \
        Django \
        Flask-JSGlue \
        raven[flask] \
        SQLAlchemy

# Install Passenger
# https://www.phusionpassenger.com/library/install/standalone/install/oss/bionic/
# https://stackoverflow.com/a/49462622
RUN apt-get install -y dirmngr gnupg && \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    apt-get install -y apt-transport-https ca-certificates && \
    echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main" > /etc/apt/sources.list.d/passenger.list && \
    apt-get update && \
    apt-get install -y passenger && \
    mkdir -p /opt/nginx/build-modules && \
    wget --directory-prefix /tmp https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz && \
    tar xzf /tmp/v0.33.tar.gz -C /opt/nginx/build-modules && \
    passenger-install-nginx-module --auto --extra-configure-flags="--add-module=/opt/nginx/build-modules/headers-more-nginx-module-0.33" --prefix=/opt/nginx && \
    rm -f /tmp/v0.33.tar.gz

# Install server's own config files
RUN mkdir -p /opt/cs50/bin && \
    chmod a+rx /opt/cs50 /opt/cs50/bin
ENV PATH /opt/cs50/bin:"$PATH"
COPY ./bin/* /opt/cs50/bin/
RUN chmod a+rx /opt/cs50/bin/*
COPY ./etc/* /usr/local/etc/
RUN chmod a+r /usr/local/etc/*
RUN echo "This is CS50 Server." > /etc/motd

# When child image is built from this one, copy its files into image
ONBUILD COPY . /var/www/
ONBUILD RUN chown -R www-data:www-data /var/www
WORKDIR /var/www

# Start server within WORKDIR
CMD ["passenger", "start"]
