#!/usr/bin/env bash

echo "waiting for db server..."
while [[ $(mysqladmin --host=$MAUTIC_DB_HOST --port=$MAUTIC_DB_PORT --user=$MAUTIC_DB_USER --password=$MAUTIC_DB_PASSWORD ping) != "mysqld is alive" ]]; do
    echo -n "."
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