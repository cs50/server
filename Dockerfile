FROM cs50/cli

# port
# TODO: decide if should be 8000
EXPOSE 8080

# gunicorn
RUN apt-get update && \
    apt-get install -y gunicorn

# php, php-fpm
RUN apt-get update && \
    apt-get install -y php5-fpm php5-memcache php5-memcached php5-mysql php5-xdebug && \
    php5dismod xdebug && \
    php5enmod mcrypt
#RUN rm -f /etc/php5/fpm/php.ini
#COPY ./etc/php5/fpm/conf.d/php.ini /etc/php5/fpm/conf.d/php.ini
#COPY ./usr/local/sbin/php5-fpm /usr/local/sbin/php5-fpm
#RUN chmod a+x /usr/local/sbin/php5-fpm

# python
RUN pip install django flask virtualenv

# nginx
RUN apt-get update && \
    apt-get install -y nginx nginx-extras
#RUN rm -f /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
#COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
#COPY ./etc/nginx/sites-available/* /etc/nginx/sites-available/

# supervisor
RUN apt-get update && \
    apt-get install -y supervisor
#RUN rm -f /etc/supervisor/conf.d/*
#COPY ./etc/supervisor/supervisord.conf /etc/supervisor/

# app
#ONBUILD COPY . /srv/www/
#ONBUILD RUN chown -R www-data:www-data /srv/www
#ONBUILD RUN composer self-update && ((composer --prefer-source -q install && rm -f composer.json composer.lock) || true)


# /opt/cs50/server50
COPY ./opt/cs50/server50 /opt/cs50/server50
RUN chmod a+x /opt/cs50/server50/bin/*
RUN mkdir -p /opt/bin
RUN ln -s /opt/cs50/server50/bin/server50 /opt/bin/

# /etc/opt/cs50/server50
RUN mkdir -p /etc/opt/cs50/server50
RUN ln -s /opt/cs50/server50/etc/* /etc/opt/cs50/server50/

# /var/opt/cs50/server50
RUN mkdir -p /var/opt/cs50/server50

# /etc/motd
COPY ./etc/motd /etc/

#COPY . /home/ubuntu/workspace
#COPY . /root

# 
RUN rm -rf /srv/www
RUN mkdir -p /srv/www
WORKDIR /srv/www

#RUN chown -R www-data:www-data /srv/www
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
#CMD ["/usr/local/bin/server50"]
