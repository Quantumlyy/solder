FROM alpine:latest

ARG composer_hash=756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3
ENV COMPOSER_HASH=${composer_hash}

RUN apk --no-cache add nginx ca-certificates wget curl

RUN apk --no-cache \
        add php7 php7-cli php7-curl php7-mcrypt php7-apcu php7-bcmath \
        php7-fpm php7-json php7-mbstring php7-pgsql php7-redis php7-xml \
        php7-zip php7-phar php7-openssl php7-pdo php7-fileinfo php7-dom \
        php7-xmlwriter php7-tokenizer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
        php -r "if (hash_file('SHA384', 'composer-setup.php') === '${COMPOSER_HASH}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

RUN php composer-setup.php && \
        php -r "unlink('composer-setup.php');"

RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64" && \
        chmod +x /usr/local/bin/gosu

RUN wget http://github.com/TechnicPack/TechnicSolder/archive/master.tar.gz -qO- | tar -xzf - -C /var/www
RUN mv var/www/TechnicSolder-master var/www/technicsolder && \
        cd /var/www/technicsolder && \
        php /composer.phar install --no-dev --no-interaction && \
        php /composer.phar install --no-dev --no-interaction
RUN chown -R nginx . && \
        chmod -R 777 ./app && \
        chmod -R 777 ./storage && \
        chmod -R 777 /var/www/technicsolder/public && \
        cd /

RUN curl -o /usr/local/bin/gpm -sSL "https://github.com/zlepper/gpm/releases/download/1.0.1/gpm-1.0.1-linux-x64" && \
    chmod +x /usr/local/bin/gpm

RUN curl -o /usr/local/bin/gfs -sSL "https://github.com/zlepper/gfs/releases/download/0.0.4/gfs-linux-x64" && \
    chmod +x /usr/local/bin/gfs 