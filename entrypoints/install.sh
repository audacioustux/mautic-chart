#!/usr/bin/env bash

if php bin/is_installed.php; then
    echo "Mautic is already installed. Skipping installation..."
    exit 0
fi

echo "Creating database ${MAUTIC_DB_NAME:?}, if it does not already exist..."
until mysql -h ${MAUTIC_DB_HOST:?} -u ${MAUTIC_DB_USER:?} -p${MAUTIC_DB_PASSWORD:?} -e "CREATE DATABASE IF NOT EXISTS ${MAUTIC_DB_NAME:?}"; do
    sleep 5
done

php bin/sync_config.php

php bin/console mautic:install \
    --no-interaction \
    --force \
    "$@"