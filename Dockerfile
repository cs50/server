FROM cs50/cli

# default port (a la Cloud9)
EXPOSE 8080

# install packages
# https://www.phusionpassenger.com/library/walkthroughs/deploy/python/ownserver/nginx/oss/trusty/install_passenger.html
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates && \
    sh -c "echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        nginx-extras \
        nodejs \
        passenger \
        php5-mcrypt \
        php5-memcached \
        php5-mysql \
        php5-xdebug

# override MOTD
RUN echo "This is CS50 Server." > /etc/motd

# install app
ONBUILD COPY . /srv/www

# start server
WORKDIR /srv/www
CMD ["passenger", "start"]
