#!/usr/bin/env bash

config_file=config/local.php

if [ -f $config_file ]; then
    echo $config_file already exists, skipping installation...
    exit 0
fi

echo "Creating database ${MAUTIC_DB_NAME:?}, if it does not already exist..."
while ! mysql -h ${MAUTIC_DB_HOST:?} -u ${MAUTIC_DB_USER:?} -p${MAUTIC_DB_PASSWORD:?} -e "CREATE DATABASE IF NOT EXISTS ${MAUTIC_DB_NAME:?}"; do
    sleep 5
done

php bin/sync_config.php

echo "Provided arguments: $@"
php bin/console mautic:install \
    --no-interaction \
    --force \
    "$@"