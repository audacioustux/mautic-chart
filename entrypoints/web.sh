#!/usr/bin/env bash

config_file=config/local.php

echo "Waiting for config file to be created..."
while [ ! -f $config_file ]; do
	sleep 5
done

php bin/sync_config.php

apache2-foreground