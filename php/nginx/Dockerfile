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
COPY ./etc/vimrc /etc/vimrc
COPY ./etc/profile.d/cs50.sh /etc/profile.d/

# php5
RUN apt-get update && \
    apt-get install -y php5-cli php5-curl php5-fpm php5-gmp php5-intl php5-mcrypt php5-memcache php5-memcached php5-mysql php5-xdebug && \
    php5dismod xdebug
COPY ./etc/php5/fpm/conf.d/php.ini /etc/php5/fpm/conf.d/php.ini
COPY ./usr/local/sbin/php5-fpm /usr/local/sbin/php5-fpm
RUN chmod a+x /usr/local/sbin/php5-fpm
RUN mkdir -p /srv/www/public

# nginx
RUN apt-get update && \
    apt-get install -y nginx
RUN rm -f /etc/nginx/sites-enabled/*
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./usr/local/sbin/nginx /usr/local/sbin/nginx
RUN chmod a+x /usr/local/sbin/nginx

# composer
RUN apt-get update && \
    apt-get install -y curl git && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ONBUILD COPY ./composer.json composer.json
ONBUILD RUN composer --prefer-source install && rm -f composer.json composer.lock

# supervisor
RUN apt-get update && \
    apt-get install -y supervisor
COPY ./etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# app
ONBUILD COPY . /srv/www/
ONBUILD RUN chown -R www-data:www-data /srv/www

# start container
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
