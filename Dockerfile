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

# Install Passenger 6
# https://www.phusionpassenger.com/library/install/standalone/install/oss/bionic/
RUN apt-get install -y dirmngr gnupg && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main" > /etc/apt/sources.list.d/passenger.list && \
    apt-get update && \
    apt-get install -y passenger

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
