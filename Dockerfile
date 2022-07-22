FROM alpine:3
LABEL maintainer=iamfat@gmail.com

ENV TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini" \
    GINI_ENV="production" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    COMPOSER_HOME="/usr/local/share/composer"

RUN apk update \
    && apk add bash curl gettext jq php8 \
    && apk add php8-fpm php8-session php8-intl php8-gd php8-curl php8-soap php8-sockets \
    && apk add php8-pdo php8-pdo_mysql php8-pdo_sqlite \
    && apk add php8-json php8-phar php8-openssl php8-bcmath php8-dom php8-ctype php8-iconv php8-zip php8-zlib php8-mbstring \
    && apk add php8-ldap php8-gettext php8-posix php8-pcntl php8-fileinfo \
    && apk add php8-simplexml php8-tokenizer php8-xml php8-xmlreader php8-xmlwriter \
    && apk add php8-pecl-yaml php8-pecl-redis \
    && sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php8/php-fpm.d/www.conf \
    && echo 'catch_workers_output = yes' >> /etc/php8/php-fpm.d/www.conf \
    && echo 'decorate_workers_output = no' >> /etc/php8/php-fpm.d/www.conf \
    && sed -i 's/^\;error_log\s*=.*$/error_log = \/dev\/stderr/' /etc/php8/php-fpm.conf \
    && sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/dev\/stderr/' /etc/php8/php.ini \
    && ln -sf /usr/sbin/php-fpm8 /usr/sbin/php-fpm \
    && ln -sf /usr/bin/php8 /usr/bin/php \
    && apk add nodejs-less nodejs-less-plugin-clean-css uglify-js \
    && apk add msmtp && ln -sf /usr/bin/msmtp /usr/sbin/sendmail \
    && apk add git \
    && mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) \
      && mv composer.phar /usr/local/bin/composer \
    && mkdir -p /data/gini-modules && git clone --depth 1 https://github.com/iamfat/gini.git /usr/local/share/gini \
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
