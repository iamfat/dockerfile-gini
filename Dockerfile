FROM alpine:3.5
MAINTAINER iamfat@gmail.com

ENV TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini" \
    GINI_ENV="production" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    COMPOSER_HOME="/usr/local/share/composer"

# Install bash, curl and gettext
RUN apk add --no-cache bash curl gettext

# Install PHP7
RUN apk add --no-cache php7-fpm php7-session php7-intl php7-gd \
      php7-mcrypt php7-pdo php7-pdo_mysql php7-pdo_sqlite php7-curl \
      php7-json php7-phar php7-openssl php7-bcmath php7-dom php7-ctype \
      php7-iconv php7-zip php7-xml php7-zlib \
      php7-ldap php7-gettext php7-posix php7-pcntl yaml \
    && sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php7/php-fpm.conf \
    && sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php7/php-fpm.conf \
    && sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php7/php.ini \
    && ln -sf /usr/sbin/php-fpm7 /usr/sbin/php-fpm \
    && ln -sf /usr/bin/php7 /usr/bin/php

RUN curl -sLo /usr/lib/php7/modules/yaml.so http://files.docker.genee.in/php7/yaml.so \
    && printf "extension=yaml.so\n" > /etc/php7/conf.d/yaml.ini

# Install Redis
RUN curl -sLo /usr/lib/php7/modules/redis.so http://files.docker.genee.in/php7/redis.so \
    && printf "extension=redis.so\n" > /etc/php7/conf.d/redis.ini

# Install ZeroMQ
RUN apk add --no-cache libzmq \
    && curl -sLo /usr/lib/php7/modules/zmq.so http://files.docker.genee.in/php7/zmq.so \
    && printf "extension=zmq.so\n" > /etc/php7/conf.d/zmq.ini

# Install NodeJS
RUN apk add --no-cache nodejs && npm install -g less less-plugin-clean-css uglify-js

# Install msmtp-mta
RUN apk add --no-cache msmtp && ln -sf /usr/bin/msmtp /usr/sbin/sendmail
ADD msmtprc /etc/msmtprc

# Install Development Tools
RUN apk add --no-cache git

# Install Composer
RUN mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) && \
    mv composer.phar /usr/local/bin/composer

# Install Gini
RUN mkdir -p /usr/local/share && git clone https://github.com/iamfat/gini /usr/local/share/gini \
    && cd /usr/local/share/gini && bin/gini composer init -f \
    && /usr/local/bin/composer update --prefer-dist --no-dev \
    && mkdir -p /data/gini-modules

EXPOSE 9000

ENV PATH="/usr/local/share/gini/bin:/usr/local/share/composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
GINI_MODULE_BASE_PATH="/data/gini-modules"

ADD start /start
WORKDIR /data/gini-modules
ENTRYPOINT ["/start"]