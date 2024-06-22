#!/usr/bin/env bash

echo "waiting for db server"
while [[ $(mysqladmin --host=$MAUTIC_DB_HOST --port=$MAUTIC_DB_PORT --user=$MAUTIC_DB_USER --password=$MAUTIC_DB_PASSWORD ping) != "mysqld is alive" ]]; do
	sleep 1
done

if [ "$CREATE_DB" = true ]; then
    echo "Creating database $MAUTIC_DB_NAME"
    mysql -h $MAUTIC_DB_HOST -P $MAUTIC_DB_PORT -u $MAUTIC_DB_USER -p$MAUTIC_DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $MAUTIC_DB_NAME;"
fi

config_file=config/local.php

if [ -f $config_file ]; then
    echo $config_file already exists, skipping installation...
else
    php bin/sync_config.sh

    php bin/console mautic:install \
        --no-interaction \
        --force \
        ${MAUTIC_URL:?} 
fi