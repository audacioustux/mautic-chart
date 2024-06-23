FROM php:8.1-apache as builder

# Install PHP extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    build-essential  \
    git \
    curl \
    libcurl4-gnutls-dev \
    libc-client-dev \
    libkrb5-dev \
    libmcrypt-dev \
    libssl-dev \
    libxml2-dev \
    libzip-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libpng-dev \
    libgif-dev \
    libtiff-dev \
    libz-dev \
    libpq-dev \
    imagemagick \
    graphicsmagick \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libxpm-dev \
    libaprutil1-dev \
    libicu-dev \
    libfreetype6-dev \
    libonig-dev \
    librabbitmq-dev \
    unzip \
    nodejs \
    npm

RUN curl -L -o /tmp/amqp.tar.gz "https://github.com/php-amqp/php-amqp/archive/refs/tags/v2.1.1.tar.gz" \
    && mkdir -p /usr/src/php/ext/amqp \
    && tar -C /usr/src/php/ext/amqp -zxvf /tmp/amqp.tar.gz --strip 1 \
    && rm /tmp/amqp.tar.gz

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install intl mbstring mysqli curl pdo_mysql zip bcmath sockets exif amqp gd imap opcache \
    && docker-php-ext-enable intl mbstring mysqli curl pdo_mysql zip bcmath sockets exif amqp gd imap opcache

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN echo "memory_limit = -1" > /usr/local/etc/php/php.ini

# Define Mautic version by package tag
ARG MAUTIC_VERSION=5.1

WORKDIR /opt
# Install Mautic
RUN COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 composer create-project mautic/recommended-project:${MAUTIC_VERSION} mautic --no-interaction
# clean up
RUN rm -rf mautic/var/cache/js && \
    find mautic/node_modules -mindepth 1 -maxdepth 1 -not \( -name 'jquery' -or -name 'vimeo-froogaloop2' -or -name 'remixicon' \) | xargs rm -rf

FROM php:8.1-apache as core

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Install PHP extensions requirements and other dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    unzip libwebp-dev libzip-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libc-client-dev librabbitmq4 \
    mariadb-client supervisor cron \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/cron.daily/*

# Setting PHP properties
ENV PHP_INI_VALUE_DATE_TIMEZONE='UTC' \
    PHP_INI_VALUE_MEMORY_LIMIT=512M \
    PHP_INI_VALUE_UPLOAD_MAX_FILESIZE=512M \
    PHP_INI_VALUE_POST_MAX_FILESIZE=512M \
    PHP_INI_VALUE_MAX_EXECUTION_TIME=300 \
    PHP_INI_SESSION_SAVE_PATH='/tmp/sessions'

COPY ./common/php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www/html

COPY --from=builder --chown=www-data:www-data /opt/mautic .
RUN mv node_modules docroot/

COPY ./bin/sync_config.php bin/sync_config.php

ENV APACHE_DOCUMENT_ROOT=/var/www/html/docroot

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable Apache Rewrite Module
RUN a2enmod rewrite

ENV MAUTIC_TRUSTED_PROXIES '[ "0.0.0.0/0", "::/0" ]'

### Mautic Web
FROM core as web

COPY ./entrypoints/web.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT exec /entrypoint.sh

### Mautic Install
FROM core as install

COPY ./entrypoints/install.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT exec /entrypoint.sh

### Mautic CLI
FROM core as console

ENTRYPOINT ["php", "bin/console", "--no-interaction", "--no-ansi"]
CMD ["--help"]