#!/bin/bash
# ──────────────────────────────────────────────────────
# Reset a single machine to clean state
# ──────────────────────────────────────────────────────
# Usage: ./reset-machine.sh <machine_id>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

MACHINE_ID="${1:?Usage: reset-machine.sh <machine_id>}"
MACHINE_ID_PADDED=$(printf "%02d" "${MACHINE_ID}")

compose_file=$(find "${PROJECT_DIR}/machines" -path "*/${MACHINE_ID_PADDED}-*/docker-compose.yml" | head -1)

if [ -z "${compose_file}" ]; then
    echo "❌ Machine ${MACHINE_ID} not found"
    exit 1
fi

machine_name=$(basename "$(dirname "${compose_file}")")
echo "🔄 Resetting ${machine_name}..."

docker compose -f "${compose_file}" down -v 2>/dev/null
docker compose -f "${compose_file}" up -d 2>/dev/null

echo "✅ ${machine_name} reset complete"
