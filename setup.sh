#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if ! command -v docker &>/dev/null; then
  echo "Docker is required. Install Docker Desktop: https://docs.docker.com/get-docker/"
  exit 1
fi

echo "Starting ERPNext v16..."
docker compose --env-file .env up -d

echo ""
echo "Waiting for site creation (this can take 3-5 minutes on first run)..."
docker compose --env-file .env logs -f create-site &
LOG_PID=$!

for i in {1..60}; do
  if curl -sf "http://localhost:${HTTP_PORT:-8080}" >/dev/null 2>&1; then
  kill "$LOG_PID" 2>/dev/null || true
    echo ""
    echo "ERPNext is ready!"
    echo "  URL:      http://localhost:${HTTP_PORT:-8080}"
    echo "  Username: Administrator"
    echo "  Password: ${ADMIN_PASSWORD:-admin}"
    exit 0
  fi
  sleep 10
done

kill "$LOG_PID" 2>/dev/null || true
echo "Site may still be initializing. Check progress with:"
echo "  docker compose logs -f create-site"
