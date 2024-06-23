#!/usr/bin/env bash

config_file=config/local.php

echo "waiting for mautic to be installed..."
until php -r "file_exists('$config_file') ? include('$config_file') : exit(1); exit(isset(\$parameters['site_url']) ? 0 : 1);"; do
	echo -n "."
	sleep 5
done

php bin/sync_config.php

apache2-foreground