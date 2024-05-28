#!/usr/bin/env bash

# wait untill the db is fully up before proceeding
while [[ $(mysqladmin --host=$MAUTIC_DB_HOST --port=$MAUTIC_DB_PORT --user=$MAUTIC_DB_USER --password=$MAUTIC_DB_PASSWORD ping) != "mysqld is alive" ]]; do
	sleep 1
done

apache2-foreground