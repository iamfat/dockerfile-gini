FROM ubuntu:20.04
LABEL maintainer=maintain@geneegroup.com

ENV DEBIAN_FRONTEND=noninteractive \
    TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini" \
    GINI_ENV="production" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    COMPOSER_HOME="/usr/local/share/composer"
    
RUN apt-get -q update && \
    # Install Locales
    apt-get install -yq locales gettext && \
        sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
        sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && \
        locale-gen && \
        /usr/sbin/update-locale LANG="en_US.UTF-8" LANGUAGE="en_US:en" && \
    # Install PHP
    apt-get install -yq php7.4-fpm php7.4-cli && \
        sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php/7.4/fpm/pool.d/www.conf && \
        echo 'catch_workers_output = yes' >> /etc/php/7.4/fpm/pool.d/www.conf && \
        sed -i 's/^error_log\s*=.*$/error_log = \/dev\/stderr/' /etc/php/7.4/fpm/php-fpm.conf && \
        sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/dev\/stderr/' /etc/php/7.4/fpm/php.ini && \
    # Install PHP modules
    apt-get install -yq php7.4-intl php7.4-gd php7.4-mysqlnd php7.4-redis \
        php7.4-sqlite php7.4-curl php7.4-zip php7.4-mbstring php7.4-ldap php7.4-yaml \
        php7.4-zmq php7.4-xml php7.4-xmlreader php7.4-xmlwriter php7.4-soap && \
    # Install NodeJS
    apt-get install -yq curl && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
        apt-get install -yq nodejs && \
        npm install -g less less-plugin-clean-css uglify-js && \
    # Install msmtp-mta
    apt-get install -yq msmtp-mta && \
    # Clean Up
    apt-get -yq --purge autoremove software-properties-common && \
    apt-get -yq autoclean && apt-get -yq clean

RUN apt-get install -yq git && \    
    # Install Composer
    mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) && \
        mv composer.phar /usr/local/bin/composer && \
        echo 'export PATH="/usr/local/share/composer/vendor/bin:$PATH"' >> /etc/profile.d/composer.sh && \
    # Install Gini
    mkdir -p /usr/local/share && git clone --depth=1 https://github.com/iamfat/gini.git /usr/local/share/gini \
        && cd /usr/local/share/gini && bin/gini composer init -f \
        && /usr/local/bin/composer update --prefer-dist --no-dev \
        && mkdir -p /data/gini-modules && \
    # Clean Up
    apt-get -yq --purge autoremove git && \
    apt-get -yq autoclean && apt-get -yq clean

ADD msmtprc /etc/msmtprc

EXPOSE 9000

ENV PATH="/usr/local/share/gini/bin:/usr/local/share/composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
GINI_MODULE_BASE_PATH="/data/gini-modules"

ADD start /start
WORKDIR /data/gini-modules
CMD ["/start"]
