Docker Hub: iamfat/gini
===========

## Gini Environment (Gini + Composer + PHP5.5 + Nginx + SSH)
```bash
docker build -t iamfat/gini gini
docker run --name gini -v /dev/log:/dev/log -v /data:/data --privileged \
    -v /data/logs/supervisor:/var/log/supervisor \
    -v /data/config/sites:/etc/nginx/sites-enabled \
    -v /data/logs/nginx:/var/log/nginx \
    -p 80:80 \
    -d iamfat/gini
```