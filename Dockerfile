FROM cs50/cli

# environment
ENV FLASK_APP application.py

# default port (to match CS50 IDE)
EXPOSE 8080

# packages 
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libcurl4-openssl-dev `# required by passenger-config` \
        libpcre3-dev `# required by passenger-config` \
        php-fpm \
        php-memcached \
        php-mysql \
        php-xdebug
RUN pip3 install Django Flask Flask-JSGlue Flask-Session raven[flask] SQLAlchemy virtualenv

# install Passenger via gem, per https://www.phusionpassenger.com/library/install/standalone/install/oss/rubygems_norvm/,
# rather than apt-get, per https://www.phusionpassenger.com/library/install/standalone/install/oss/trusty/,
# else a version of nginx (compiled without ngx_http_fastcgi_module) gets installed from Passenger's repo, which yields:
# unknown directive "fastcgi_param" in nginx.conf
RUN gem install passenger

# download any necessary files immediately, which would otherwise be downloading during the first run
RUN passenger-config install-standalone-runtime && \
    passenger-config build-native-support

# install server's own config files
COPY ./bin/* /usr/local/bin/
RUN chmod a+rx /usr/local/bin/*
COPY ./etc/* /usr/local/etc/
RUN chmod a+r /usr/local/etc/*
RUN echo "This is CS50 Server." > /etc/motd

# when child image is built from this one, copy its files into /srv/www
ONBUILD COPY . /srv/www

# start server within /srv/www
WORKDIR /srv/www
CMD unset PYTHONDONTWRITEBYTECODE && passenger start
