#!/usr/bin/env bash

set -e

echo "Waiting for Mautic to be installed..."
until php bin/is_installed.php; do
	sleep 5
done

php bin/console --no-interaction --no-ansi "$@"