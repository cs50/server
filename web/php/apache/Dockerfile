FROM ubuntu:14.04

# working directory
RUN rm -rf /srv/www/*
WORKDIR /srv/www

# port
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
    apt-get install -y php5-cli php5-curl php5-gmp php5-intl php5-mcrypt php5-memcache php5-memcached php5-mysql php5-xdebug && \
    php5dismod xdebug && \
    php5enmod mcrypt

# apache2
RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-php5
RUN rm -f /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/* /etc/php5/apache2/php.ini
COPY ./etc/apache2/conf-available/apache2.conf /etc/apache2/conf-available/apache2.conf
RUN a2enconf apache2 && a2enmod rewrite
COPY ./usr/local/sbin/apache2 /usr/local/sbin/apache2
RUN chmod a+x /usr/local/sbin/apache2
RUN mkdir -p /srv/www/public

# composer
RUN apt-get update && \
    apt-get install -y curl git && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# supervisor
RUN apt-get update && \
    apt-get install -y supervisor
COPY ./etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# app
ONBUILD COPY . /srv/www/
ONBUILD RUN chown -R www-data:www-data /srv/www
ONBUILD RUN composer self-update && ((composer --prefer-source -q install && rm -f composer.json composer.lock) || true)

# start container
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
