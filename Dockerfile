FROM debian:8
MAINTAINER iamfat@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# Install cURL
RUN apt-get -q update && apt-get install -yq curl

# Add DotDeb Source
RUN echo "deb http://packages.dotdeb.org jessie all">/etc/apt/sources.list.d/dotdeb.list && \
    curl -sLo /tmp/dotdeb.gpg https://www.dotdeb.org/dotdeb.gpg && \
    apt-key add /tmp/dotdeb.gpg && rm /tmp/dotdeb.gpg && apt-get update

# Install Locales
RUN apt-get install -yq locales gettext && \
    sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    /usr/sbin/update-locale LANG="en_US.UTF-8" LANGUAGE="en_US:en"

# Install PHP
RUN apt-get install -yq php7.0-fpm php7.0-cli php7.0-intl php7.0-gd php7.0-sqlite php7.0-curl php7.0-ldap && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php/7.0/fpm/php-fpm.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php/7.0/cli/php.ini

RUN \
    # Install YAML
    apt-get install -yq libyaml-0-2 && \
    curl -sLo /usr/lib/php/20151012/yaml.so http://files.docker.genee.in/php-20151012/yaml.so && \
    echo "extension=yaml.so" > /etc/php/mods-available/yaml.ini && \
    phpenmod -v 7.0 yaml && \
    # Install Redis
    curl -sLo /usr/lib/php/20151012/redis.so http://files.docker.genee.in/php-20151012/redis.so && \
    echo "extension=redis.so" > /etc/php/mods-available/redis.ini && \
    phpenmod -v 7.0 redis && \
    # Install Friso
    curl -sLo /usr/lib/libfriso.so http://files.docker.genee.in/php-20151012/libfriso.so && \
    curl -sLo /usr/lib/php/20151012/friso.so http://files.docker.genee.in/php-20151012/friso.so && \
    curl -sL http://files.docker.genee.in/friso-etc.tgz | tar -zxf - -C /etc && \
    printf "extension=friso.so\n[friso]\nfriso.ini_file=/etc/friso/friso.ini\n" > /etc/php/mods-available/friso.ini && \
    phpenmod -v 7.0 friso && \
    # Install ZeroMQ
    apt-get install -yq libzmq3 && \
    curl -sLo /usr/lib/php/20151012/zmq.so http://files.docker.genee.in/php-20151012/zmq.so && \
    printf "extension=zmq.so\n" > /etc/php/mods-available/zmq.ini && \
    ldconfig && phpenmod -v 7.0 zmq

# Install NodeJS
RUN apt-get install -yq npm && ln -sf /usr/bin/nodejs /usr/bin/node && npm install -g less less-plugin-clean-css uglify-js

# Install Development Tools
RUN apt-get install -yq git

# Install Composer
RUN mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) && \
    mv composer.phar /usr/local/bin/composer && \
    echo 'export COMPOSER_HOME="/usr/local/share/composer"' > /etc/profile.d/composer.sh && \
    echo 'export PATH="/usr/local/share/composer/vendor/bin:$PATH"' >> /etc/profile.d/composer.sh
ENV COMPOSER_PROCESS_TIMEOUT 40000
ENV COMPOSER_HOME /usr/local/share/composer

# Install Gini
RUN composer global require -q 'iamfat/gini:dev-master'

# Install msmtp-mta
RUN apt-get install -yq msmtp-mta
ADD msmtprc /etc/msmtprc

RUN apt-get -y autoremove && apt-get -y autoclean && apt-get -y clean

EXPOSE 9000

ADD start /start
CMD ["/start"]

