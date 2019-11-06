FROM debian:9
MAINTAINER maintain@geneegroup.com

ENV DEBIAN_FRONTEND=noninteractive \
    TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini" \
    GINI_ENV="production" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    COMPOSER_HOME="/usr/local/share/composer"
    
# Install cURL
RUN apt-get -q update && apt-get install -yq curl bash vim unzip software-properties-common apt-transport-https gnupg && apt-get -y autoclean && apt-get -y clean

# Install Locales
RUN apt-get install -yq locales gettext && \
    sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    /usr/sbin/update-locale LANG="en_US.UTF-8" LANGUAGE="en_US:en"

# Install PHP
RUN curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add - && \
    add-apt-repository "deb https://packages.sury.org/php/ stretch main" && \
    apt-get update && \
    apt-get install -yq php7.2-fpm php7.2-cli && \
    apt-get -y --purge remove software-properties-common gnupg && \
    apt-get -y autoremove && \
    apt-get -y autoclean && apt-get -y clean && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php/7.2/fpm/pool.d/www.conf && \
    sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php/7.2/fpm/php-fpm.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php/7.2/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php/7.2/cli/php.ini

RUN apt-get install -yq php7.2-intl php7.2-gd php7.2-mysqlnd php7.2-redis php7.2-sqlite php7.2-curl php7.2-zip php7.2-mbstring php7.2-ldap php7.2-dev php7.2-xml

RUN apt-get install -yq libyaml-dev && \
    curl -sLo /tmp/yaml-2.0.4.tgz https://pecl.php.net/get/yaml-2.0.4.tgz && \
    pecl install /tmp/yaml-2.0.4.tgz && \
    echo "extension=yaml.so" > /etc/php/7.2/mods-available/yaml.ini && \
    phpenmod yaml && \
    rm -rf /tmp/yaml-2.0.4.tgz 

# Install mcrypt
RUN apt-get -yq install libmcrypt-dev && \
    curl -sLo /tmp/mcrypt-1.0.3.tgz https://pecl.php.net/get/mcrypt-1.0.3.tgz && \
    pecl install /tmp/mcrypt-1.0.3.tgz && \
    echo "extension=mcrypt.so" > /etc/php/7.2/mods-available/mcrypt.ini && \
    phpenmod mcrypt && \
    rm -rf /tmp/mcrypt-1.0.3.tgz

# Install Friso
RUN export PHP_EXTENSION_DIR=$(echo '<?= PHP_EXTENSION_DIR ?>'|php) && \
    curl -sLo /usr/lib/libfriso.so http://files.genee.cn/debian/php-7.0/libfriso.so && \
    curl -sLo $PHP_EXTENSION_DIR/friso.so http://files.genee.cn/debian/php-7.0/friso.so && \
    curl -sL http://files.genee.cn/debian/php-7.0/friso-etc.tar.gz | tar -xvzf - -C /etc && \
    printf "extension=friso.so\nfriso.ini_file=/etc/friso/friso.ini\n" > /etc/php/7.2/mods-available/friso.ini && \
    phpenmod friso

# Install ZeroMQ
RUN apt-get install -yq pkg-config libzmq3-dev && \
    curl -sLo /tmp/zmq-1.1.3.tgz https://pecl.php.net/get/zmq-1.1.3.tgz && \
    pecl install /tmp/zmq-1.1.3.tgz && \
    echo "extension=zmq.so" > /etc/php/7.2/mods-available/zmq.ini && \
    phpenmod zmq && \
    rm -rf /tmp/zmq-1.1.3.tgz

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
    && apt-get -y --purge remove git && apt-get -y autoremove && apt-get -y autoclean && apt-get -y clean \
    && mkdir -p /data/gini-modules

EXPOSE 9000

ENV PATH="/usr/local/share/gini/bin:/usr/local/share/composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
GINI_MODULE_BASE_PATH="/data/gini-modules"

ADD start /start
WORKDIR /data/gini-modules
ENTRYPOINT ["/start"]
