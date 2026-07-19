#!/usr/bin/env bash
# Build a custom ERPNext v16 image with ChangAI baked in.
# Uses official frappe_docker layered Containerfile.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

IMAGE_NAME="${IMAGE_NAME:-erpnext-changai}"
IMAGE_TAG="${IMAGE_TAG:-v16}"
FRAPPE_BRANCH="${FRAPPE_BRANCH:-version-16}"
BUILD_DIR="${BUILD_DIR:-/tmp/frappe_docker_changai}"

if ! command -v docker &>/dev/null; then
  echo "Docker is required."
  exit 1
fi

if [[ ! -f apps.json ]]; then
  echo "apps.json not found in $ROOT"
  exit 1
fi

echo "==> Preparing frappe_docker build context..."
if [[ ! -d "$BUILD_DIR/.git" ]]; then
  rm -rf "$BUILD_DIR"
  git clone --depth 1 https://github.com/frappe/frappe_docker.git "$BUILD_DIR"
else
  git -C "$BUILD_DIR" pull --ff-only || true
fi

cp "$ROOT/apps.json" "$BUILD_DIR/apps.json"

echo "==> Building layered image (ERPNext + ChangAI). This can take 20-40+ minutes..."
docker build \
  --build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
  --build-arg=FRAPPE_BRANCH="$FRAPPE_BRANCH" \
  --build-arg=CACHE_BUST="$(shasum -a 256 "$ROOT/apps.json" | awk '{print $1}')" \
  --secret=id=apps_json,src="$BUILD_DIR/apps.json" \
  --tag="${IMAGE_NAME}:${IMAGE_TAG}-raw" \
  --file="$BUILD_DIR/images/layered/Containerfile" \
  "$BUILD_DIR"

echo "==> Adding ChangAI system libraries..."
docker build \
  --tag="${IMAGE_NAME}:${IMAGE_TAG}" \
  -f- "$ROOT" <<EOF
FROM ${IMAGE_NAME}:${IMAGE_TAG}-raw
USER root
RUN apt-get update \\
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \\
    build-essential \\
    python3-dev \\
    libffi-dev \\
    pkg-config \\
    libopenblas-dev \\
    libgl1 \\
    libglib2.0-0 \\
  && rm -rf /var/lib/apt/lists/*
USER frappe
EOF

echo ""
echo "Built ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Next: docker compose --env-file .env up -d"
echo "Then:  docker compose exec backend bench --site frontend install-app changai"
