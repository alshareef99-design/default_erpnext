#!/usr/bin/env bash
# Clone (if needed), build frappe/charts inside the ERPNext backend container,
# and serve dist via /assets/frappe-charts/.
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -d charts/.git ]]; then
  echo "==> Cloning https://github.com/frappe/charts ..."
  git clone --depth 1 https://github.com/frappe/charts.git charts
fi

mkdir -p charts/dist

echo "==> Recreating backend/frontend with charts mounts..."
docker compose --env-file .env up -d --force-recreate backend frontend

echo "==> Installing and building frappe-charts in container..."
docker compose exec -T backend bash -c '
set -euo pipefail
cd /home/frappe/frappe-charts
npm install
npm run build
ls -la dist
'

echo ""
echo "frappe/charts is ready."
echo "  Source in container: /home/frappe/frappe-charts"
echo "  JS:  http://localhost:${HTTP_PORT:-8080}/assets/frappe-charts/frappe-charts.umd.js"
echo "  CSS: http://localhost:${HTTP_PORT:-8080}/assets/frappe-charts/frappe-charts.min.css"
