#!/bin/bash
set -e

echo "=== Ejecutando migraciones ==="
superset db upgrade

echo "=== Creando admin (si no existe) ==="
superset fab create-admin --username admin --firstname Admin --lastname Admin --email admin@local.com --password admin || true

echo "=== Inicializando roles y permisos ==="
superset init

echo "=== Iniciando Superset ==="
gunicorn \
  --bind 0.0.0.0:8088 \
  --workers 2 \
  --threads 4 \
  --worker-class gthread \
  --timeout 300 \
  --limit-request-line 0 \
  --limit-request-field_size 0 \
  "superset.app:create_app()"
