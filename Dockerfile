FROM ubuntu:14.04.2
MAINTAINER David J. Malan <malan@harvard.edu>

# working directory
RUN rm -rf /srv/www/*
WORKDIR /srv/www

# TCP 80
EXPOSE 80

# https://github.com/monokrome/docker-wine/issues/3
ENV DEBIAN_FRONTEND noninteractive

# dev
RUN apt-get update && \
    apt-get install -y mysql-client telnet vim
COPY ./etc/basic.vim /root/.vimrc

# apache2
RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-php5

# php5
RUN apt-get update && \
    apt-get install -y php5-cli php5-curl php5-fpm php5-gmp php5-mcrypt php5-memcache php5-memcached php5-mysql && \
    php5enmod mcrypt 
#&& \
#    mkdir -p /usr/local/etc/php5/fpm/pool.d
#COPY ./etc/php5/fpm/conf.d/cs50.ini /etc/php5/fpm/conf.d/cs50.ini

# nginx
RUN apt-get update && \
    apt-get install -y nginx 
COPY ./etc/nginx/nginx.conf /etc/nginx/sites-enabled/default
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf

#COPY ./bin/nginx /usr/local/bin/

# composer
RUN apt-get update && \
    apt-get install -y curl git && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ONBUILD COPY composer.json composer.json
ONBUILD RUN composer --prefer-source install && rm -f composer.json composer.lock

# supervisor
RUN apt-get update && \
    apt-get install -y supervisor
COPY ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 
ONBUILD COPY . /srv/www/
COPY . /srv/www/

# start container
CMD ["/usr/bin/supervisord"]
