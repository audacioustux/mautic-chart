#!/usr/bin/env bash

set -eax

# wait untill the db is fully up before proceeding
while [[ $(mysqladmin --host=$MAUTIC_DB_HOST --port=$MAUTIC_DB_PORT --user=$MAUTIC_DB_USER --password=$MAUTIC_DB_PASSWORD ping) != "mysqld is alive" ]]; do
	sleep 1
done

if [ "$CREATE_DB" = true ]; then
    mysql -h $MAUTIC_DB_HOST -P $MAUTIC_DB_PORT -u $MAUTIC_DB_USER -p$MAUTIC_DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $MAUTIC_DB_NAME;"
fi

config_file=config/local.php

if [ -f $config_file ]; then
    echo $config_file already exists, skipping
else
    php bin/console mautic:install \
        --db_host=${MAUTIC_DB_HOST:?} \
        --db_port=${MAUTIC_DB_PORT:?} \
        --db_name=${MAUTIC_DB_NAME:?} \
        --db_user=${MAUTIC_DB_USER:?} \
        --db_password=${MAUTIC_DB_PASSWORD:?} \
        --admin_email=${MAUTIC_ADMIN_EMAIL:?} \
        --admin_password=${MAUTIC_ADMIN_PASSWORD:?} \
        --no-interaction \
        --force \
        ${MAUTIC_URL:?} 
fi