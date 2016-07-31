#!/bin/bash

#
sed -i '/^env\[.\+\] *=.*/d' /etc/php5/fpm/pool.d/www.conf
env | grep -v ^PASSENGER_ | sed 's/\([^=]\+\)=\(.*\)/env[\1]=\"\2\"/' | awk 'length <= 1024' >> /etc/php5/fpm/pool.d/www.conf

#
if [ "$APPLICATION_ENV" == "dev" ]; then
    php5enmod xdebug && \
    cp -f /usr/share/php5/php.ini-development /etc/php5/fpm/php.ini
else
    php5dismod xdebug && \
    cp -f /usr/share/php5/php.ini-production /etc/php5/fpm/php.ini
fi

# 
/etc/init.d/php5-fpm start
