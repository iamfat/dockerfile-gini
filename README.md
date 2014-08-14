Docker Hub: iamfat/gini
===========

## Gini Environment (Gini + Composer + PHP5.5)
```bash
docker build -t iamfat/gini gini
docker run --name gini --privileged \
    -v /dev/log:/dev/log -v /data:/data \
    --link mysql:mysql --link redis:redis \
    -d iamfat/gini
```