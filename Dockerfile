FROM debian:7.6
MAINTAINER maintain@geneegroup.com

ENV DEBIAN_FRONTEND noninteractive

# Install cURL
RUN apt-get update && apt-get install -y curl apt-utils

# Install PHP 5.5
RUN echo "deb http://packages.dotdeb.org wheezy-php55 all" > /etc/apt/sources.list.d/dotdeb-php5.list && \
    (curl -sL http://www.dotdeb.org/dotdeb.gpg | apt-key add -) && \
    apt-get update && apt-get install -y locales gettext php5-fpm php5-cli php5-intl php5-gd php5-mcrypt php5-mysqlnd php5-redis php5-sqlite php5-curl libyaml-0-2 && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php5/fpm/pool.d/www.conf && \
    sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php5/fpm/php-fpm.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php5/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php5/cli/php.ini

ADD yaml.so /usr/lib/php5/20121212/yaml.so
RUN echo "extension=yaml.so" > /etc/php5/mods-available/yaml.ini && \
    php5enmod yaml
	
# Install NodeJS
RUN (curl -sL https://deb.nodesource.com/setup | bash -) && \
    apt-get install -y nodejs && npm install -g less uglify-js

# Install Development Tools
RUN apt-get install -y git

# Install Composer
RUN mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) && \
    mv composer.phar /usr/local/bin/composer && \
    echo 'export COMPOSER_HOME="/usr/local/share/composer"' > /etc/profile.d/composer.sh && \
    echo 'export PATH="/usr/local/share/composer/vendor/bin:$PATH"' >> /etc/profile.d/composer.sh
ENV COMPOSER_PROCESS_TIMEOUT 40000
ENV COMPOSER_HOME /usr/local/share/composer

# Install Gini
RUN composer global require -q 'iamfat/gini:dev-master'

# Setup Locale
RUN \
    sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    /usr/sbin/update-locale LANG="en_US.UTF-8" LANGUAGE="en_US:en"

# Install msmtp-mta
RUN apt-get install -y msmtp-mta
ADD msmtprc /etc/msmtprc

EXPOSE 9000

ADD start /start
CMD ["/start"]
