FROM genee/gini:php7.4

ADD install-oci8.sh /install-oci8.sh

RUN bash /install-oci8.sh

