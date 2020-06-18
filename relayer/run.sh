#!/bin/bash

DOCKER_SHARED_DIR=/nginx

set -euo pipefail

echo "==> $(date +%H:%M:%S) ==> Wait for migrations..."
sleep 10

echo "==> $(date +%H:%M:%S) ==> Setup Gas Station..."
python manage.py setup_gas_station

echo "==> $(date +%H:%M:%S) ==> Setting up service... "
python manage.py setup_service

if [ "${DEPLOY_MASTER_COPY_ON_INIT:-0}" = 1 ]; then
    echo "==> $(date +%H:%M:%S) ==> Deploy Safe master copy..."
    python manage.py deploy_safe_master_copy
fi

if [ "${DEPLOY_PROXY_FACTORY_ON_INIT:-0}" = 1 ]; then
    echo "==> $(date +%H:%M:%S) ==> Deploy proxy factory..."
    python manage.py deploy_proxy_factory
fi

echo "==> $(date +%H:%M:%S) ==> Collecting statics... "
DOCKER_SHARED_DIR=/nginx
rm -rf $DOCKER_SHARED_DIR/*
STATIC_ROOT=$DOCKER_SHARED_DIR/staticfiles python manage.py collectstatic --noinput

echo "==> $(date +%H:%M:%S) ==> Running Gunicorn... "
exec gunicorn --worker-class gevent --pythonpath "$PWD" config.wsgi:application --timeout 60 --graceful-timeout 60 --log-file=- --error-logfile=- --access-logfile=- --log-level info --logger-class='safe_relay_service.relay.utils.CustomGunicornLogger' -b unix:$DOCKER_SHARED_DIR/gunicorn.socket -b 0.0.0.0:8888
