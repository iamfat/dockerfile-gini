FROM alpine:3
LABEL maintainer=iamfat@gmail.com

ENV TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini" \
    GINI_ENV="production" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    COMPOSER_HOME="/usr/local/share/composer"

RUN apk update \
    && apk add bash curl gettext jq php81 \
    && apk add php81-fpm php81-session php81-intl php81-gd php81-curl php81-soap php81-sockets \
    && apk add php81-pdo php81-pdo_mysql php81-pdo_sqlite \
    && apk add php81-json php81-phar php81-openssl php81-bcmath php81-dom php81-ctype php81-iconv php81-zip php81-zlib php81-mbstring \
    && apk add php81-ldap php81-gettext php81-posix php81-pcntl php81-fileinfo \
    && apk add php81-simplexml php81-tokenizer php81-xml php81-xmlreader php81-xmlwriter \
    && apk add php81-pecl-yaml php81-pecl-redis \
    && sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php81/php-fpm.d/www.conf \
    && echo 'catch_workers_output = yes' >> /etc/php81/php-fpm.d/www.conf \
    && echo 'decorate_workers_output = no' >> /etc/php81/php-fpm.d/www.conf \
    && sed -i 's/^\;error_log\s*=.*$/error_log = \/dev\/stderr/' /etc/php81/php-fpm.conf \
    && sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/dev\/stderr/' /etc/php81/php.ini \
    && ln -sf /usr/sbin/php-fpm81 /usr/sbin/php-fpm \
    && ln -sf /usr/bin/php81 /usr/bin/php \
    && apk add nodejs-less nodejs-less-plugin-clean-css uglify-js \
    && apk add msmtp && ln -sf /usr/bin/msmtp /usr/sbin/sendmail \
    && apk add git \
    && mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) \
    && mv composer.phar /usr/local/bin/composer  \
    && rm -rf /var/cache/apk/*

ADD msmtprc /etc/msmtprc

EXPOSE 9000

ENV PATH="/usr/local/share/gini/bin:/usr/local/share/composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
GINI_MODULE_BASE_PATH="/data/gini-modules"

ADD start /start
WORKDIR /data/gini-modules
CMD ["/start"]
