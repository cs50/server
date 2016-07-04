FROM cs50/cli

# port
# TODO: decide if should be 5050
EXPOSE 80

# php
RUN apt-get update && \
    apt-get install -y php5-fpm php5-memcache php5-memcached php5-mysql php5-xdebug && \
    php5dismod xdebug && \
    php5enmod mcrypt

# php-fpm
RUN rm -f /etc/php5/fpm/php.ini
COPY ./etc/php5/fpm/conf.d/php.ini /etc/php5/fpm/conf.d/php.ini
COPY ./usr/local/sbin/php5-fpm /usr/local/sbin/php5-fpm
RUN chmod a+x /usr/local/sbin/php5-fpm

# apache2
RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-php5
RUN rm -f /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/* /etc/php5/apache2/php.ini
COPY ./etc/apache2/conf-available/apache2.conf /etc/apache2/conf-available/apache2.conf
RUN a2enconf apache2 && a2enmod rewrite
COPY ./usr/local/sbin/apache2 /usr/local/sbin/apache2
RUN chmod a+x /usr/local/sbin/apache2

# nginx
RUN apt-get update && \
    apt-get install -y nginx nginx-extras
RUN rm -f /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./etc/nginx/sites-available/* /etc/nginx/sites-available/
COPY ./usr/local/sbin/nginx /usr/local/sbin/nginx
RUN chmod a+x /usr/local/sbin/nginx

# supervisor
RUN apt-get update && \
    apt-get install -y supervisor
COPY ./etc/supervisor/conf.d/* /etc/supervisor/conf.d/

# app
#ONBUILD COPY . /srv/www/
#ONBUILD RUN chown -R www-data:www-data /srv/www
#ONBUILD RUN composer self-update && ((composer --prefer-source -q install && rm -f composer.json composer.lock) || true)

# 
COPY ./etc/motd /etc/
#COPY . /home/ubuntu/workspace
COPY . /root

COPY ./usr/local/bin/server50 /usr/local/bin/server50
RUN chmod a+x /usr/local/bin/server50

#RUN chown -R www-data:www-data /srv/www
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
#CMD ["/usr/local/bin/server50"]
