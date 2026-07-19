# Default ERPNext v16 + ChangAI

Local ERPNext v16 stack with [ChangAI](https://github.com/alshareef99-design/changai) (AI assistant for ERPNext) baked into a custom Docker image.

## Quick start

If the custom image is already built:

```bash
./setup.sh
```

First-time / rebuild image with ChangAI:

```bash
./build-changai.sh
docker compose --env-file .env up -d
docker compose exec backend bench --site frontend install-app changai
```

First site creation takes 3–5 minutes. Image builds take longer (20–40+ minutes) because of ChangAI ML dependencies.

## Access

| | |
|---|---|
| **URL** | http://localhost:8080 |
| **Username** | `Administrator` |
| **Password** | `admin` (set in `.env` as `ADMIN_PASSWORD`) |

## Installed apps

- **Frappe** / **ERPNext** v16
- **ChangAI** `0.0.1` from https://github.com/alshareef99-design/changai.git

### Configure ChangAI in Desk

1. Log in as **Administrator** (System Manager required).
2. Search Awesome Bar for **`ChangAI Settings`** and open it  
   (URL: http://localhost:8080/app/changai-settings/ChangAI%20Settings).
3. **Download Embedding Model** — button in the **top form toolbar** (not on a tab).
4. Open the **Training** tab → click **Update MasterData file**.
5. Add your **Gemini API key** on the main settings form, then Save.

If you see `check_file_updates is not whitelisted` (Download button missing), run:

```bash
./fix-changai.sh
```

Then hard-refresh the browser (Cmd+Shift+R).

## Frappe Charts

[`frappe/charts`](https://github.com/frappe/charts) is a JS charting library (not a Frappe app). It is cloned into `./charts`, built in the backend container, and served from site assets.

```bash
./setup-charts.sh
```

Then use:

- JS: http://localhost:8080/assets/frappe-charts/frappe-charts.umd.js
- CSS: http://localhost:8080/assets/frappe-charts/frappe-charts.min.css

In a custom page / HTML:

```html
<link rel="stylesheet" href="/assets/frappe-charts/frappe-charts.min.css">
<script src="/assets/frappe-charts/frappe-charts.umd.js"></script>
```

Container paths:

- Source: `/home/frappe/frappe-charts`
- Built assets: `/home/frappe/frappe-bench/assets/frappe-charts`

## Frappe DataTable

[`frappe/datatable`](https://github.com/frappe/datatable) is a JS datatable library (not a Frappe app). Same pattern as charts.

```bash
./setup-datatable.sh
```

Then use:

- JS: http://localhost:8080/assets/frappe-datatable/frappe-datatable.min.js
- CSS: http://localhost:8080/assets/frappe-datatable/frappe-datatable.min.css

Container paths:

- Source: `/home/frappe/frappe-datatable`
- Built assets: `/home/frappe/frappe-bench/assets/frappe-datatable`

## Frappe Gantt

[`frappe/gantt`](https://github.com/frappe/gantt) is a JS gantt library (not a Frappe app). Same pattern as charts/datatable.

```bash
./setup-gantt.sh
```

Then use:

- JS: http://localhost:8080/assets/frappe-gantt/frappe-gantt.umd.js
- CSS: http://localhost:8080/assets/frappe-gantt/frappe-gantt.css

Container paths:

- Source: `/home/frappe/frappe-gantt`
- Built assets: `/home/frappe/frappe-bench/assets/frappe-gantt`

## Versions

- **Custom image:** `erpnext-changai:v16`
- **MariaDB:** 11.8
- **Redis:** 6.2
- **frappe/charts:** v1.6.3 (cloned in `./charts`)
- **frappe/datatable:** cloned in `./datatable`
- **frappe/gantt:** v1.2.2 (cloned in `./gantt`)
## Configuration

Copy `.env.example` to `.env` and adjust as needed:

| Variable | Default | Description |
|---|---|---|
| `CUSTOM_IMAGE` | `erpnext-changai` | Docker image name |
| `CUSTOM_TAG` | `v16` | Docker image tag |
| `HTTP_PORT` | `8080` | Web UI port |
| `ADMIN_PASSWORD` | `admin` | Administrator password |
| `DB_ROOT_PASSWORD` | `admin` | MariaDB root password |
| `SITE_NAME` | `frontend` | Frappe site name |

Apps included in the image are defined in `apps.json`.

## Common commands

```bash
# Rebuild image after changing apps.json
./build-changai.sh

# View logs
docker compose logs -f

# Stop
docker compose down

# Stop and remove all data (fresh install)
docker compose down -v

# Open backend shell
docker compose exec backend bash

# List apps
docker compose exec backend bench --site frontend list-apps
```

## Stack services

- **frontend** — Nginx reverse proxy (port 8080)
- **backend** — Frappe/ERPNext application server
- **websocket** — Socket.IO for real-time updates
- **scheduler** — Background job scheduler
- **queue-short / queue-long** — Background workers
- **db** — MariaDB database
- **redis-cache / redis-queue** — Redis instances

## Notes

- This is a **development/demo** setup, not production-ready.
- ChangAI needs a Gemini API key (and optional master-data sync) before useful answers — see the [ChangAI README](https://github.com/alshareef99-design/changai).
- For production, see [frappe_docker docs](https://github.com/frappe/frappe_docker).
- Data persists in Docker volumes (`db-data`, `sites`, `logs`, `redis-queue-data`).
