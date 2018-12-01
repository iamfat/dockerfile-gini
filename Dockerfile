FROM debian:9
MAINTAINER maintain@geneegroup.com

ENV DEBIAN_FRONTEND=noninteractive \
    TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini" \
    GINI_ENV="production" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    COMPOSER_HOME="/usr/local/share/composer"
    
# Install cURL
RUN apt-get -q update && apt-get install -yq curl bash vim && apt-get -y autoclean && apt-get -y clean

# Install Locales
RUN apt-get install -yq locales gettext && \
    sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    /usr/sbin/update-locale LANG="en_US.UTF-8" LANGUAGE="en_US:en"

# Install PHP
RUN apt-get install -yq php7.0-fpm php7.0-cli && \
    apt-get -y autoclean && apt-get -y clean && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php/7.0/fpm/php-fpm.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php/7.0/cli/php.ini

RUN apt-get install -yq php7.0-intl php7.0-gd php7.0-mcrypt php7.0-mysqlnd php7.0-redis php7.0-sqlite php7.0-curl php7.0-ldap php-dev

RUN apt-get install -yq libyaml-dev && \
    pecl install yaml && \
    echo "extension=yaml.so" > /etc/php/7.0/mods-available/yaml.ini && \
    phpenmod yaml

# Install Friso
RUN export PHP_EXTENSION_DIR=$(echo '<?= PHP_EXTENSION_DIR ?>'|php) && \
    curl -sLo /usr/lib/libfriso.so http://docker.17ker.top/libfriso.so && \
    curl -sLo $PHP_EXTENSION_DIR/friso.so http://docker.17ker.top/friso.so && \
    curl -sL http://docker.17ker.top/friso-etc.tar.gz | tar -xvzf - -C /etc && \
    printf "extension=friso.so\nfriso.ini_file=/etc/friso/friso.ini\n" > /etc/php/7.0/mods-available/friso.ini && \
    phpenmod friso

# Install ZeroMQ
RUN apt-get install -yq pkg-config libzmq3-dev && \
    pecl install zmq-1.1.3 && \
    echo "extension=zmq.so" > /etc/php/7.0/mods-available/zmq.ini && \
    phpenmod zmq

# Install NodeJS
RUN apt-get install -yq gnupg && \
    curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -yq nodejs && \
    npm install -g less less-plugin-clean-css uglify-js

# Install msmtp-mta
RUN apt-get install -yq msmtp-mta && apt-get -y autoclean && apt-get -y clean
ADD msmtprc /etc/msmtprc

# Install Development Tools
RUN apt-get install -yq git

# Install Composer
RUN mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) && \
    mv composer.phar /usr/local/bin/composer && \
    echo 'export PATH="/usr/local/share/composer/vendor/bin:$PATH"' >> /etc/profile.d/composer.sh

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
