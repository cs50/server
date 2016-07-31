#!/bin/bash

/bin/sed -i '/^env\[.\+\] *=.*/d' /etc/php5/fpm/pool.d/www.conf
/usr/bin/env | /bin/sed 's/\([^=]\+\)=\(.*\)/env[\1]=\"\2\"/' | /usr/bin/awk 'length <= 1024' >> /etc/php5/fpm/pool.d/www.conf

if [ "$APPLICATION_ENV" == "dev" ]; then
    /usr/sbin/php5enmod xdebug && \
    /bin/cp -f /usr/share/php5/php.ini-development /etc/php5/fpm/php.ini && \
    /usr/sbin/php5-fpm -F
else
    /usr/sbin/php5dismod xdebug && \
    /bin/cp -f /usr/share/php5/php.ini-production /etc/php5/fpm/php.ini && \
    /usr/sbin/php5-fpm -F
fi

/etc/init.d/php5-fpm start
