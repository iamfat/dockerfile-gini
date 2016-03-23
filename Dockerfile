FROM alpine:3.3
MAINTAINER iamfat@gmail.com

ENV TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini"

# Install bash, curl and gettext
RUN apk update && apk add bash curl gettext

# Install PHP
RUN apk add php-fpm php-cli php-intl php-gd php-mcrypt php-pdo php-pdo_mysql php-pdo_sqlite php-curl php-ldap php-gettext php-posix php-pcntl yaml && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php/php-fpm.conf && \
    sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php/php-fpm.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php/php.ini

RUN curl -sLo /usr/lib/php/modules/yaml.so http://files.docker.genee.in/php5/yaml.so && \
    echo "extension=yaml.so" > /etc/php/conf.d/yaml.ini

# Install Friso
RUN curl -sLo /usr/lib/libfriso.so http://files.docker.genee.in/php5/libfriso.so && \
    curl -sLo /usr/lib/php/modules/friso.so http://files.docker.genee.in/php5/friso.so && \
    curl -sL http://files.docker.genee.in/friso-etc.tgz | tar -zxf - -C /etc && \
    printf "extension=friso.so\n[friso]\nfriso.ini_file=/etc/friso/friso.ini\n" > /etc/php/conf.d/friso.ini

# Install Redis
RUN curl -sLo /usr/lib/php/modules/redis.so http://files.docker.genee.in/php5/redis.so && \
    printf "extension=redis.so\n" > /etc/php/conf.d/redis.ini

# Install ZeroMQ
RUN apk add libzmq && \
    curl -sLo /usr/lib/php/modules/zmq.so http://files.docker.genee.in/php5/zmq.so && \
    printf "extension=zmq.so\n" > /etc/php/conf.d/zmq.ini

# Install NodeJS
RUN apk add nodejs && npm install -g less less-plugin-clean-css uglify-js

# Install Development Tools
RUN apk add git php-json php-phar php-openssl

# Install Composer
RUN mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) && \
    mv composer.phar /usr/local/bin/composer && \
    echo 'export COMPOSER_HOME="/usr/local/share/composer"' > /etc/profile.d/composer.sh && \
    echo 'export PATH="/usr/local/share/composer/vendor/bin:$PATH"' >> /etc/profile.d/composer.sh
ENV COMPOSER_PROCESS_TIMEOUT 40000
ENV COMPOSER_HOME /usr/local/share/composer

# Install Gini
RUN apk add php-bcmath php-dom php-ctype php-iconv && composer global require -q iamfat/gini

# Install msmtp-mta
RUN apk add msmtp
ADD msmtprc /etc/msmtprc

EXPOSE 9000

ADD start /start
CMD ["/start"]

