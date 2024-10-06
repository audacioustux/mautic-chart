ARG APT_DEPS="libcurl4-gnutls-dev libc-client-dev libkrb5-dev libmcrypt-dev libssl-dev libxml2-dev libzip-dev libjpeg-dev libmagickwand-dev libpng-dev libgif-dev libtiff-dev libz-dev libpq-dev imagemagick graphicsmagick libwebp-dev libjpeg62-turbo-dev libxpm-dev libaprutil1-dev libicu-dev libfreetype6-dev libonig-dev unzip"

FROM php:8.1-apache AS builder

ARG MAUTIC_VERSION=5.1
ARG APT_DEPS

# Install PHP extensions
RUN apt-get update && apt-get install -y \
    ${APT_DEPS} \
    ca-certificates \
    build-essential  \
    git \
    curl \
    nodejs \
    npm

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install redis
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install intl mbstring mysqli curl pdo_mysql zip bcmath sockets exif gd imap opcache \
    && docker-php-ext-enable intl mbstring mysqli curl pdo_mysql zip bcmath sockets exif gd imap opcache redis

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN echo "memory_limit=-1" > /usr/local/etc/php/php.ini

# Install Mautic
WORKDIR /opt
RUN COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 composer create-project mautic/recommended-project:${MAUTIC_VERSION} mautic --no-interaction
# Customizations
WORKDIR /opt/mautic
RUN COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 composer require pabloveintimilla/mautic-amazon-ses

# Clean up
RUN rm -rf var/cache/js && \
    find node_modules -mindepth 1 -maxdepth 1 -not \( -name 'jquery' -or -name 'vimeo-froogaloop2' -or -name 'remixicon' \) | xargs rm -rf
RUN mv node_modules docroot/

FROM php:8.1-apache AS core

ARG APT_DEPS

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

RUN apt-get update && apt-get install --no-install-recommends -y \
    ${APT_DEPS} \
    mariadb-client redis-tools \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && rm -rf /var/lib/apt/lists/*

# Configure PHP
ENV PHP_INI_VALUE_DATE_TIMEZONE=UTC \
    PHP_INI_VALUE_UPLOAD_MAX_FILESIZE=512M \
    PHP_INI_VALUE_POST_MAX_FILESIZE=512M \
    PHP_INI_VALUE_MEMORY_LIMIT=512M \
    PHP_INI_VALUE_MAX_EXECUTION_TIME=600 

COPY ./common/php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www/html

COPY --from=builder --chown=www-data:www-data /opt/mautic .

COPY ./bin/ bin/

ENV APACHE_DOCUMENT_ROOT=/var/www/html/docroot

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable Apache Rewrite Module
RUN a2enmod rewrite

ENV MAUTIC_TRUSTED_PROXIES='[ "0.0.0.0/0", "::/0" ]'

### Mautic Web
FROM core AS web

COPY ./entrypoints/web.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

### Mautic Install
FROM core AS install

COPY ./entrypoints/install.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

### Mautic CLI
FROM core AS console

ENV PHP_INI_VALUE_MAX_EXECUTION_TIME=600 \
    PHP_INI_VALUE_MEMORY_LIMIT=-1

COPY ./entrypoints/console.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
