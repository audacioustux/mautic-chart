#!/usr/bin/env bash

echo "Waiting for Mautic to be installed..."
until php bin/is_installed.php; do
	sleep 5
done

php bin/sync_config.php

apache2-foreground