#!/bin/bash

set -euo pipefail

# DEBUG set in .env
if [ ${DEBUG:-0} = 1 ]; then
    log_level="debug"
else
    log_level="info"
fi

# Wait for db migrations
sleep 10

echo "==> Running Celery beat <=="
exec celery beat -A safe_relay_service.taskapp -S django_celery_beat.schedulers:DatabaseScheduler --loglevel $log_level
