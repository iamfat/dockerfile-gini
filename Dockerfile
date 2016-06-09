FROM debian:8
MAINTAINER maintain@geneegroup.com

ENV DEBIAN_FRONTEND=noninteractive \
    TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini" \
    GINI_ENV="production" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    COMPOSER_HOME="/usr/local/share/composer"

# Install cURL
RUN apt-get -q update && apt-get install -yq curl && apt-get -y autoclean && apt-get -y clean

# Install Locales
RUN apt-get install -yq locales gettext && \
    sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    /usr/sbin/update-locale LANG="en_US.UTF-8" LANGUAGE="en_US:en"

# Install PHP
RUN apt-get install -yq php5-fpm php5-cli php5-intl php5-gd php5-mcrypt php5-mysqlnd php5-redis php5-sqlite php5-curl php5-ldap libyaml-0-2 && \
    apt-get -y autoclean && apt-get -y clean && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php5/fpm/pool.d/www.conf && \
    sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php5/fpm/php-fpm.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php5/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php5/cli/php.ini

RUN curl -sLo /usr/lib/php5/20131226/yaml.so http://files.docker.genee.in/php-20131226/yaml.so && \
    echo "extension=yaml.so" > /etc/php5/mods-available/yaml.ini && \
    php5enmod yaml

# Install Friso
RUN curl -sLo /usr/lib/libfriso.so http://files.docker.genee.in/php-20131226/libfriso.so && \
    curl -sLo /usr/lib/php5/20131226/friso.so http://files.docker.genee.in/php-20131226/friso.so && \
    curl -sL http://files.docker.genee.in/friso-etc.tgz | tar -zxf - -C /etc && \
    printf "extension=friso.so\n[friso]\nfriso.ini_file=/etc/friso/friso.ini\n" > /etc/php5/mods-available/friso.ini && \
    php5enmod friso

# Install ZeroMQ
RUN apt-get install -yq libzmq3 && apt-get -y autoclean && apt-get -y clean && \
    curl -sLo /usr/lib/php5/20131226/zmq.so http://files.docker.genee.in/php-20131226/zmq.so && \
    printf "extension=zmq.so\n" > /etc/php5/mods-available/zmq.ini && \
    ldconfig && php5enmod zmq

# Install NodeJS
RUN apt-get install -yq npm && ln -sf /usr/bin/nodejs /usr/bin/node && npm install -g less less-plugin-clean-css uglify-js

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
