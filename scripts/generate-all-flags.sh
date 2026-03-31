#!/bin/bash
# ──────────────────────────────────────────────────────
# Generate flags for all machines
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
source "${PROJECT_DIR}/.env" 2>/dev/null || true

SEED="${FLAG_SEED:?FLAG_SEED not set. Set it in .env}"

echo "🏴 Generating flags for all machines..."
echo "   Seed: ${SEED:0:8}..."
echo ""

for i in $(seq 1 ${TOTAL_MACHINES:-42}); do
    id=$(printf "%02d" "${i}")
    root_flag=$(echo -n "${SEED}:machine_${id}" | sha256sum | cut -c1-32)
    user_flag=$(echo -n "${SEED}:user_${id}" | sha256sum | cut -c1-32)
    
    # Find machine directory
    machine_dir=$(find "${PROJECT_DIR}/machines" -type d -name "${id}-*" | head -1)
    
    if [ -n "${machine_dir}" ]; then
        machine_name=$(basename "${machine_dir}")
        echo "  [${id}] ${machine_name}"
        echo "       Root: FLAG{${root_flag}}"
        echo "       User: FLAG{${user_flag}}"
        
        # Write to flags directory
        mkdir -p "${machine_dir}/flags"
        echo "FLAG{${root_flag}}" > "${machine_dir}/flags/root.txt"
        echo "FLAG{${user_flag}}" > "${machine_dir}/flags/user.txt"
    fi
done

echo ""
echo "✅ All flags generated."
