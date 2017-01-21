FROM cs50/cli

# default port (a la Cloud9)
EXPOSE 8080

# install packages
#nginx-extras \
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libcurl4-openssl-dev \
        libpcre3-dev \
        nodejs \
        php5-fpm \
        php5-mcrypt \
        php5-memcached \
        php5-mysql \
        php5-xdebug
RUN gem install passenger # TODO: document why

# download any necessary files immediately, which would otherwise be downloading during the first run
RUN passenger-config install-standalone-runtime && \
    passenger-config build-native-support

# configure server
COPY ./sbin/* /usr/local/sbin/
RUN chmod a+rx /usr/local/sbin/*
COPY ./etc/* /usr/local/etc/
RUN chmod a+r /usr/local/etc/*
#RUN sed -E -i 's#\# (include /etc/nginx/passenger.conf;)#\1#' /etc/nginx/nginx.conf
RUN echo "This is CS50 Server." > /etc/motd

# install app
ONBUILD COPY . /var/www

# start server
WORKDIR /var/www
CMD ["passenger", "start"]
