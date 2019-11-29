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
RUN apt-get -q update && apt-get install -yq curl bash vim unzip && apt-get -y autoclean && apt-get -y clean

# Install Locales
RUN apt-get install -yq locales gettext && \
    sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    /usr/sbin/update-locale LANG="en_US.UTF-8" LANGUAGE="en_US:en"

# Install PHP
RUN apt-get install -yq software-properties-common apt-transport-https gnupg && \
    curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add - && \
    add-apt-repository "deb https://packages.sury.org/php/ stretch main" && \
    apt-get update && \
    apt-get install -yq php7.1-fpm php7.1-cli && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php/7.1/fpm/php-fpm.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php/7.1/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php/7.1/cli/php.ini && \
    apt-get -y --purge remove software-properties-common gnupg apt-transport-https && \
    apt-get -y autoremove && \
    apt-get -y autoclean && apt-get -y clean

RUN apt-get install -yq apt-transport-https \
    && apt-get install -yq php7.1-intl php7.1-gd php7.1-mysqlnd php7.1-redis php7.1-sqlite php7.1-curl php7.1-zip php7.1-mbstring php7.1-ldap php7.1-yaml php7.1-zmq php7.1-mcrypt php7.1-xml \
    && apt-get -y --purge remove apt-transport-https \
    && apt-get -y autoremove \
    && apt-get -y autoclean && apt-get -y clean 

# Install NodeJS
RUN apt-get install -yq gnupg apt-transport-https && \
    curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -yq nodejs && \
    npm install -g less less-plugin-clean-css uglify-js && \
    apt-get -y --purge remove software-properties-common gnupg apt-transport-https lsb-release && \
    apt-get -y autoremove && \
    apt-get -y autoclean && apt-get -y clean

# Install msmtp-mta
RUN apt-get install -yq msmtp-mta && apt-get -y autoclean && apt-get -y clean
ADD msmtprc /etc/msmtprc

# Install Composer
RUN mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) && \
    mv composer.phar /usr/local/bin/composer && \
    echo 'export PATH="/usr/local/share/composer/vendor/bin:$PATH"' >> /etc/profile.d/composer.sh

# Install Gini
RUN apt-get install -yq git \
    && mkdir -p /usr/local/share && git clone https://github.com/iamfat/gini /usr/local/share/gini \
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
