#!/usr/bin/env bash
# Clone (if needed), build frappe/datatable inside the ERPNext backend container,
# and serve dist via /assets/frappe-datatable/.
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -d datatable/.git ]]; then
  echo "==> Cloning https://github.com/frappe/datatable ..."
  git clone --depth 1 https://github.com/frappe/datatable.git datatable
fi

mkdir -p datatable/dist

echo "==> Recreating backend/frontend with datatable mounts..."
docker compose --env-file .env up -d --force-recreate backend frontend

echo "==> Installing and building frappe-datatable in container..."
docker compose exec -T backend bash -c '
set -euo pipefail
cd /home/frappe/frappe-datatable
if command -v yarn >/dev/null 2>&1; then
  yarn install
  yarn build
else
  npm install
  npm run build
fi
ls -la dist
'

echo ""
echo "frappe/datatable is ready."
echo "  Source in container: /home/frappe/frappe-datatable"
echo "  JS:  http://localhost:${HTTP_PORT:-8080}/assets/frappe-datatable/frappe-datatable.min.js"
echo "  CSS: http://localhost:${HTTP_PORT:-8080}/assets/frappe-datatable/frappe-datatable.min.css"
