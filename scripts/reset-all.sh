#!/bin/bash
# ──────────────────────────────────────────────────────
# Reset ALL machines to clean state
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

echo "🔄 Resetting all machines..."

find "${PROJECT_DIR}/machines" -name "docker-compose.yml" -not -name "docker-compose.*.yml" | sort | while read -r compose_file; do
    machine_name=$(basename "$(dirname "${compose_file}")")
    echo "  Resetting ${machine_name}..."
    docker compose -f "${compose_file}" down -v 2>/dev/null
    docker compose -f "${compose_file}" up -d 2>/dev/null && \
        echo "  ✅ ${machine_name}" || echo "  ❌ ${machine_name}"
done

echo ""
echo "✅ All machines reset"
