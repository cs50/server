FROM cs50/cli
ARG DEBIAN_FRONTEND=noninteractive

# Default port (to match CS50 IDE)
EXPOSE 443

# Unset user
USER root

# Unminimize system (for manpages)
RUN yes | unminimize

# Install packages
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        libcurl4-openssl-dev `# Required by passenger-config` \
        libmysqlclient-dev `# For mysql` \
        mysql-client `# For mysql` \
        php-fpm \
        php-xdebug \
        pkg-config `# For mysqlclient` && \
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
RUN apt install --no-install-recommends --no-install-suggests --yes \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        gnupg && \
    curl curl https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key.txt | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/phusion.gpg >/dev/null && \
    echo deb https://oss-binaries.phusionpassenger.com/apt/passenger noble main > /etc/apt/sources.list.d/passenger.list && \
    apt update && \
    apt install --install-recommends --no-install-suggests --yes \
        passenger && \
    passenger-config build-native-support && \
    mkdir --parents /opt/nginx/build-modules && \
    wget --directory-prefix /tmp https://github.com/openresty/headers-more-nginx-module/archive/v0.34.tar.gz && \
    tar xzf /tmp/v0.34.tar.gz -C /opt/nginx/build-modules && \
    passenger-install-nginx-module --auto --extra-configure-flags="--add-module=/opt/nginx/build-modules/headers-more-nginx-module-0.34" --prefix=/opt/nginx && \
    rm --force /tmp/v0.34.tar.gz

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
