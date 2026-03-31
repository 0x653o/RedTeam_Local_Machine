#!/bin/bash
# ──────────────────────────────────────────────────────
# Validate all machine health checks
# ──────────────────────────────────────────────────────
# Usage:
#   ./validate-machines.sh              # All machines
#   ./validate-machines.sh 01           # Single machine
#   ./validate-machines.sh --include-escapes  # Include escape checks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

INCLUDE_ESCAPES=false
TARGET=""

for arg in "$@"; do
    case "${arg}" in
        --include-escapes) INCLUDE_ESCAPES=true ;;
        [0-9]*) TARGET="${arg}" ;;
    esac
done

echo -e "${BOLD}🔍 Validating machine health checks...${NC}"
echo ""

passed=0
failed=0
skipped=0

validate_machine() {
    local compose_file="$1"
    local machine_name
    machine_name=$(basename "$(dirname "${compose_file}")")
    local machine_id
    machine_id=$(echo "${machine_name}" | grep -oP '^\d+')
    
    # Get container
    local container
    container=$(docker compose -f "${compose_file}" ps --format '{{.Name}}' 2>/dev/null | head -1)
    
    if [ -z "${container}" ]; then
        printf "  %-4s %-20s ${YELLOW}SKIPPED${NC} (not running)\n" "${machine_id}" "${machine_name}"
        ((skipped++)) || true
        return
    fi
    
    # Run health check
    if docker exec "${container}" /healthcheck.sh 2>/dev/null; then
        printf "  %-4s %-20s ${GREEN}PASSED${NC}\n" "${machine_id}" "${machine_name}"
        ((passed++)) || true
    else
        printf "  %-4s %-20s ${RED}FAILED${NC}\n" "${machine_id}" "${machine_name}"
        ((failed++)) || true
    fi
}

if [ -n "${TARGET}" ]; then
    target_padded=$(printf "%02d" "${TARGET}")
    compose_file=$(find "${PROJECT_DIR}/machines" -path "*/${target_padded}-*/docker-compose.yml" | head -1)
    if [ -z "${compose_file}" ]; then
        echo -e "${RED}Machine ${TARGET} not found${NC}"
        exit 1
    fi
    validate_machine "${compose_file}"
else
    find "${PROJECT_DIR}/machines" -name "docker-compose.yml" -not -name "docker-compose.*.yml" | sort | while read -r compose_file; do
        validate_machine "${compose_file}"
    done
fi

echo ""
echo -e "${BOLD}Results:${NC} ${GREEN}Passed: ${passed}${NC} | ${RED}Failed: ${failed}${NC} | ${YELLOW}Skipped: ${skipped}${NC}"
