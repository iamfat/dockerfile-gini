#!/bin/bash

set -e

apt-get install -yq libaio1 alien libaio-dev php7.4-dev

ARCH=$(uname -m)
if [ "$ARCH" == 'aarch64' ] || [ "$ARCH"] == 'arm64' ]; then
    curl -sLo /tmp/basiclite.rpm http://files.docker.genee.in/oracle-instantclient19.10-basiclite-19.10.0.0.0-1.aarch64.rpm
    curl -sLo /tmp/devel.rpm http://files.docker.genee.in/oracle-instantclient19.10-devel-19.10.0.0.0-1.aarch64.rpm
    alien -i --target=arm64 /tmp/basiclite.rpm /tmp/devel.rpm
else
    curl -sLo /tmp/basiclite.rpm http://files.docker.genee.in/oracle-instantclient-basiclite-21.3.0.0.0-1.el8.x86_64.rpm
    curl -sLo /tmp/devel.rpm http://files.docker.genee.in/oracle-instantclient-devel-21.3.0.0.0-1.el8.x86_64.rpm
    alien -i /tmp/basiclite.rpm /tmp/devel.rpm
fi

printf "\n" | pecl install oci8-2.2.0
PHP_VERSION_ID=$(echo "<?= PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION ?>" | php)
echo 'extension=oci8.so' >/etc/php/$PHP_VERSION_ID/mods-available/oci8.ini
phpenmod oci8

if [ "$ARCH" == 'aarch64' ] || [ "$ARCH"] == 'arm64' ]; then
    dpkg -r oracle-instantclient19.10-devel
else
    dpkg -r oracle-instantclient-devel
fi

apt-get -yq autoremove --purge php7.4-dev libaio-dev alien
apt-get -yq autoclean && apt-get -yq clean
rm -rf /var/lib/apt/lists/*
