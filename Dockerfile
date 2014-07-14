FROM genee/gini:php7

RUN apt-get install -yq libaio1 alien libaio-dev php7.1-dev  \
        && curl -sLo /tmp/basiclite.rpm http://files.docker.genee.in/oracle-instantclient12.2-basiclite-12.2.0.1.0-1.x86_64.rpm \
        && curl -sLo /tmp/devel.rpm http://files.docker.genee.in/oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm \
        && alien -i /tmp/basiclite.rpm /tmp/devel.rpm \
        && pecl install oci8 \
        && PHP_VERSION_ID=$(echo "<?= PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION ?>"|php) \
        && echo 'extension=oci8.so' > /etc/php/$PHP_VERSION_ID/mods-available/oci8.ini \
        && phpenmod oci8 \
        && echo '/usr/lib/oracle/12.2/client64/lib' > /etc/ld.so.conf.d/oracle.conf \
    && dpkg -r oracle-instantclient12.2-devel \
    && apt-get -yq autoremove --purge php7.1-dev libaio-dev alien \
    && apt-get -yq autoclean && apt-get -yq clean \
    && rm -rf /var/lib/apt/lists/*

ENV ORACLE_HOME="/usr/lib/oracle/12.2/client64"
