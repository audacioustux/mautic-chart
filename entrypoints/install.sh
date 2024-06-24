#!/usr/bin/env bash

# create $MAUTIC_DB_NAME database if it doesn't exist
# keep retrying until the db server is up
while ! mysqladmin --host=$MAUTIC_DB_HOST --port=$MAUTIC_DB_PORT --user=$MAUTIC_DB_USER --password=$MAUTIC_DB_PASSWORD create $MAUTIC_DB_NAME; do
    echo "waiting for db server..."
    sleep 1
done

config_file=config/local.php

if [ -f $config_file ]; then
    echo $config_file already exists, skipping installation...
else
    php bin/sync_config.php

    php bin/console mautic:install \
        --no-interaction \
        --force \
        ${MAUTIC_SITE_URL:?} 
fi