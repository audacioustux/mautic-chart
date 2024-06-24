#!/usr/bin/env bash

config_file=config/local.php

php bin/sync_config.php

apache2-foreground