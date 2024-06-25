#!/usr/bin/env bash

set -e

echo "Waiting for Mautic to be installed..."
until php bin/is_installed.php; do
	sleep 5
done

php bin/sync_config.php

php bin/console cache:warmup -n --no-ansi

apache2-foreground