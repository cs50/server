FROM ubuntu:14.04.2
MAINTAINER David J. Malan <malan@harvard.edu>

# TCP 80
EXPOSE 80

# https://github.com/monokrome/docker-wine/issues/3
ENV DEBIAN_FRONTEND noninteractive

# nginx
RUN apt-get update && \
    apt-get install -y nginx 

# php5
RUN apt-get update && \
    apt-get install -y php5-cli php5-curl php5-fpm php5-gmp php5-mcrypt php5-memcache php5-memcached php5-mysql && \
    php5enmod mcrypt 

# composer
RUN apt-get update && \
    apt-get install -y curl git && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# dev
RUN apt-get update && \
    apt-get install -y mysql-client telnet vim
COPY ./etc/basic.vim /root/.vimrc

# nginx, php5-fpm
COPY ./etc/nginx/nginx.conf /etc/nginx/sites-enabled/default
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./etc/php5/fpm/conf.d/cs50.ini /etc/php5/fpm/conf.d/cs50.ini

# working directory
RUN rm -rf /usr/share/nginx/*
WORKDIR /usr/share/nginx

# composer
ONBUILD COPY composer.json composer.json
ONBUILD RUN composer --prefer-source install && rm -f composer.json composer.lock
ONBUILD COPY . /usr/share/nginx/

# start container
#COPY ./start.sh start.sh
CMD ./start.sh
