FROM cs50/cli

# port
EXPOSE 8080

# TODO: decide whether to move to cli50
# python, gunicorn
RUN apt-get update && \
    pip3 install django flask virtualenv

# php-fpm
RUN apt-get update && \
    apt-get install -y php5-fpm php5-memcache php5-memcached php5-mysql php5-xdebug && \
    php5dismod xdebug && \
    php5enmod mcrypt

# passenger
# https://github.com/phusion/passenger/issues/1394
RUN gem install rack -v=1.6.4 && \
    gem install passenger && \
    passenger-config build-native-support && \
    passenger-config install-standalone-runtime --auto && \
    passenger-config validate-install --auto
#COPY ./etc/apt/sources.list.d/passenger.list /etc/apt/sources.list.d/
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
#    apt-get install -y apt-transport-https ca-certificates && \
#    apt-get update && \
#    apt-get install -y passenger && \
#    passenger-config validate-install

# /etc/motd
COPY ./etc/motd /etc/

ENV PASSENGER_NGINX_CONFIG_TEMPLATE "/srv/www/nginx.conf.erb"

#COPY . /home/ubuntu/workspace
#COPY . /root

#RUN chown -R www-data:www-data /srv/www
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
#CMD ["/usr/local/bin/server50"]
