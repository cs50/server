FROM ubuntu:14.04.2

# TCP 80
EXPOSE 80

# https://github.com/monokrome/docker-wine/issues/3
ENV DEBIAN_FRONTEND noninteractive

# nginx, php5
RUN apt-get update && \
    apt-get install -y nginx php5-cli php5-curl php5-fpm php5-gmp php5-memcache php5-memcached php5-mysql

# php5-mcrypt
RUN apt-get update && \
    apt-get install -y php5-mcrypt && \
    php5enmod mcrypt 

# composer
RUN apt-get update && \
    apt-get install -y curl git && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# dev
RUN apt-get update && \
    apt-get install -y mysql-client telnet vim

# dev
COPY ./etc/basic.vim /root/.vimrc

# nginx, php5-fpm
COPY ./etc/nginx/nginx.conf /etc/nginx/sites-enabled/default
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./etc/php5/fpm/conf.d/cs50.ini /etc/php5/fpm/conf.d/cs50.ini

# working directory
RUN rm -rf /usr/share/nginx/*
WORKDIR /usr/share/nginx

# start container
CMD ./start.sh
