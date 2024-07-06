#!/usr/bin/env bash

set -e

echo "Creating database ${MAUTIC_DB_NAME:?}, if it does not already exist..."
mysql -h ${MAUTIC_DB_HOST:?} -u ${MAUTIC_DB_USER:?} -p${MAUTIC_DB_PASSWORD:?} -e "CREATE DATABASE IF NOT EXISTS ${MAUTIC_DB_NAME:?}"

php bin/console mautic:install \
    --db-host=${MAUTIC_DB_HOST:?} \
    --db-port=${MAUTIC_DB_PORT:?} \
    --db-name=${MAUTIC_DB_NAME:?} \
    --db-user=${MAUTIC_DB_USER:?} \
    --db-password=${MAUTIC_DB_PASSWORD:?} \
    --admin-username=${MAUTIC_ADMIN_USER:?} \
    --admin-email=${MAUTIC_ADMIN_EMAIL:?} \
    --admin-password=${MAUTIC_ADMIN_PASSWORD:?} \
    --no-interaction \
    --force \
    ${SITE_URL:-"$@"}