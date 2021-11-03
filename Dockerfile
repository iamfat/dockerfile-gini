FROM alpine:3
LABEL maintainer=iamfat@gmail.com

ENV TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini" \
    GINI_ENV="production" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    COMPOSER_HOME="/usr/local/share/composer"

RUN apk update \
    && apk add bash curl gettext jq php7 php7-fpm \
    && apk add php7-session php7-intl php7-gd php7-pdo php7-pdo_mysql php7-pdo_sqlite \
      php7-curl php7-soap php7-sockets php7-json php7-phar php7-openssl php7-bcmath php7-ldap php7-posix php7-pcntl \
      php7-ctype php7-iconv php7-gettext php7-mbstring php7-fileinfo php7-zip php7-zlib \
      php7-dom php7-simplexml php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter \
      php7-pecl-yaml php7-pecl-zmq php7-pecl-redis \
      && sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php7/php-fpm.d/www.conf \
      && echo 'catch_workers_output = yes' >> /etc/php7/php-fpm.d/www.conf \
      && echo 'decorate_workers_output = no' >> /etc/php7/php-fpm.d/www.conf \
      && sed -i 's/^\;error_log\s*=.*$/error_log = \/dev\/stderr/' /etc/php7/php-fpm.conf \
      && sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/dev\/stderr/' /etc/php7/php.ini \
      && ln -sf /usr/sbin/php-fpm7 /usr/sbin/php-fpm \
      && ln -sf /usr/bin/php7 /usr/bin/php \
    && apk add nodejs-less nodejs-less-plugin-clean-css uglify-js \
    && apk add msmtp && ln -sf /usr/bin/msmtp /usr/sbin/sendmail \
    && apk add git \
    && mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) \
      && mv composer.phar /usr/local/bin/composer \
    && mkdir -p /data/gini-modules && git clone --depth 1 https://github.com/iamfat/gini.git -b 1.13.2 /usr/local/share/gini \
        && cd /usr/local/share/gini && bin/gini composer init -f \
        && /usr/local/bin/composer install --no-dev \
        && bin/gini cache \
    && rm -rf /var/cache/apk/*

ADD msmtprc /etc/msmtprc

EXPOSE 9000

ENV PATH="/usr/local/share/gini/bin:/usr/local/share/composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
GINI_MODULE_BASE_PATH="/data/gini-modules"

ADD start /start
WORKDIR /data/gini-modules
CMD ["/start"]
