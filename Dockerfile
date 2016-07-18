FROM cs50/cli

# port
# TODO: decide if should be 8000
EXPOSE 80

# gunicorn
RUN apt-get update && \
    apt-get install -y gunicorn

# php, php-fpm
RUN apt-get update && \
    apt-get install -y php5-fpm php5-memcache php5-memcached php5-mysql php5-xdebug && \
    php5dismod xdebug && \
    php5enmod mcrypt
RUN rm -f /etc/php5/fpm/php.ini
COPY ./etc/php5/fpm/conf.d/php.ini /etc/php5/fpm/conf.d/php.ini
COPY ./usr/local/sbin/php5-fpm /usr/local/sbin/php5-fpm
RUN chmod a+x /usr/local/sbin/php5-fpm

# python
RUN pip install django flask virtualenv

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
