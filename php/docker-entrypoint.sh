#!/bin/sh
set -e

# Configurar zona horaria si está definida
if [ -n "$TZ" ]; then
    cp /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
fi

# Configurar cron para Moodle si existe el archivo
if [ -f /etc/cron.d/moodle-cron ]; then
    chmod 0644 /etc/cron.d/moodle-cron
    crontab /etc/cron.d/moodle-cron
fi

# Ejecutar comando principal
exec "$@"
