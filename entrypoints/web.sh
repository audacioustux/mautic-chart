#!/usr/bin/env bash

if php bin/is_installed.php; then
    echo "Mautic is already installed. Skipping installation..."
    exit 0
fi

php bin/sync_config.php

apache2-foreground