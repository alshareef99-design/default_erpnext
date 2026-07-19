#!/usr/bin/env bash
# Apply local ChangAI fixes inside the running backend container.
# Safe to re-run.
set -euo pipefail

cd "$(dirname "$0")"

echo "Applying ChangAI whitelist fix for check_file_updates..."
docker compose exec -T backend bash -c '
python3 - <<'"'"'PY'"'"'
from pathlib import Path
p = Path("/home/frappe/frappe-bench/apps/changai/changai/changai/api/v2/schema_utils.py")
text = p.read_text()
needle = "def check_file_updates(file_name: str):"
idx = text.find(needle)
if idx < 0:
    raise SystemExit("check_file_updates not found")
window = text[max(0, idx - 80):idx]
if "@frappe.whitelist" in window:
    print("already whitelisted")
else:
    text = text[:idx] + "@frappe.whitelist(allow_guest=False)\n" + text[idx:]
    p.write_text(text)
    print("patched check_file_updates")
PY
bench --site frontend clear-cache
'
docker compose restart backend queue-short queue-long scheduler
echo "Done. Hard-refresh http://localhost:8080 and open ChangAI Settings."
