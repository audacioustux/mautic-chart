#!/usr/bin/env bash

config_file=config/local.php

echo "waiting for $config_file"
while [ ! -f $config_file ]; do
	sleep 1
done

apache2-foreground