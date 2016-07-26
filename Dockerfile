FROM cs50/cli

# port
EXPOSE 8080

# nginx
RUN apt-get update && \
    apt-get install -y nginx nginx-extras

# python, gunicorn
RUN apt-get update && \
    apt-get install -y pip3 && \
    pip3 install django flask gunicorn virtualenv

# php, php-fpm
RUN apt-get update && \
    apt-get install -y php5-fpm php5-memcache php5-memcached php5-mysql php5-xdebug && \
    php5dismod xdebug && \
    php5enmod mcrypt

# supervisor
RUN apt-get update && \
    apt-get install -y supervisor

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
RUN mkdir -p /etc/opt/cs50
RUN ln -s /opt/cs50/server50/etc /etc/opt/cs50/server50

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
