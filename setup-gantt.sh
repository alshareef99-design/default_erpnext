#!/usr/bin/env bash
# Clone (if needed), build frappe/gantt inside the ERPNext backend container,
# and serve dist via /assets/frappe-gantt/.
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -d gantt/.git ]]; then
  echo "==> Cloning https://github.com/frappe/gantt ..."
  git clone --depth 1 https://github.com/frappe/gantt.git gantt
fi

mkdir -p gantt/dist

echo "==> Recreating backend/frontend with gantt mounts..."
docker compose --env-file .env up -d --force-recreate backend frontend

echo "==> Installing and building frappe-gantt in container..."
docker compose exec -T backend bash -c '
set -euo pipefail
cd /home/frappe/frappe-gantt
npm install
npm run build
ls -la dist
'

echo ""
echo "frappe/gantt is ready."
echo "  Source in container: /home/frappe/frappe-gantt"
echo "  JS:  http://localhost:${HTTP_PORT:-8080}/assets/frappe-gantt/frappe-gantt.umd.js"
echo "  CSS: http://localhost:${HTTP_PORT:-8080}/assets/frappe-gantt/frappe-gantt.css"
