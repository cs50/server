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
        php5-fpm \
        php5-memcached \
        php5-mysql \
        php5-xdebug
RUN pip3 install Django Flask Flask-JSGlue Flask-Session SQLAlchemy virtualenv

# install Passenger via gem, per https://www.phusionpassenger.com/library/install/standalone/install/oss/rubygems_norvm/,
# rather than apt-get, per https://www.phusionpassenger.com/library/install/standalone/install/oss/trusty/,
# else a version of nginx (compiled without ngx_http_fastcgi_module) gets installed from Passenger's repo, which yields:
# unknown directive "fastcgi_param" in nginx.conf
RUN gem install passenger

# download any necessary files immediately, which would otherwise be downloading during the first run
RUN passenger-config install-standalone-runtime && \
    passenger-config build-native-support

# configure server, using /usr/local/sbin instead of /usr/local/bin 
# since gem installs passenger in /usr/local/bin and we want our version
# to take precedence (and our usage is system-level anyway)
COPY ./sbin/* /usr/local/sbin/
RUN chmod a+rx /usr/local/sbin/*
COPY ./etc/* /usr/local/etc/
RUN chmod a+r /usr/local/etc/*
RUN echo "This is CS50 Server." > /etc/motd

# when child image is built from this one, copy its files into /var/www
ONBUILD COPY . /var/www

# start server within /var/www
WORKDIR /var/www
CMD ["passenger", "start"]
