#!/bin/bash
# ============================================================
# 01_WebServer_Runtime — Master Test Runner
# Usage:
#   ./tests/run_tests.sh              # test all machines
#   ./tests/run_tests.sh 06           # test only machine 06
#   ./tests/run_tests.sh 05 06 07     # test specific machines
#   ./tests/run_tests.sh --no-cleanup # keep containers after test
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$SCRIPT_DIR"

# ── Colours ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

pass() { echo -e "  ${GREEN}✅ PASS${RESET} $1"; }
fail() { echo -e "  ${RED}❌ FAIL${RESET} $1"; FAIL_COUNT=$((FAIL_COUNT+1)); }
warn() { echo -e "  ${YELLOW}⚠️  WARN${RESET} $1"; }
info() { echo -e "  ${CYAN}ℹ${RESET}  $1"; }

# ── Args ─────────────────────────────────────────────────────
CLEANUP=true
MACHINES_TO_TEST=()

for arg in "$@"; do
  case "$arg" in
    --no-cleanup) CLEANUP=false ;;
    [0-9][0-9])   MACHINES_TO_TEST+=("$arg") ;;
    *)            echo "Unknown arg: $arg"; exit 1 ;;
  esac
done

ALL_MACHINES=(01 02 03 04 05 06 07)
[ ${#MACHINES_TO_TEST[@]} -eq 0 ] && MACHINES_TO_TEST=("${ALL_MACHINES[@]}")

# ── Preflight ─────────────────────────────────────────────────
echo -e "${BOLD}=== 01_WebServer_Runtime — Test Suite ===${RESET}"
echo "Base dir : $BASE_DIR"
echo "Machines : ${MACHINES_TO_TEST[*]}"
echo "Cleanup  : $CLEANUP"
echo ""

# Check Docker
if ! docker info &>/dev/null; then
  echo -e "${RED}ERROR: Docker daemon not reachable. Start Docker first.${RESET}"
  exit 1
fi

TOTAL=0; PASS_COUNT=0; FAIL_COUNT=0; SKIP_COUNT=0
RESULTS=()

# ── Run per-machine test ──────────────────────────────────────
for NUM in "${MACHINES_TO_TEST[@]}"; do
  TEST_SCRIPT="$TESTS_DIR/test_${NUM}.sh"

  if [ ! -f "$TEST_SCRIPT" ]; then
    warn "No test script for machine $NUM — skipping"
    SKIP_COUNT=$((SKIP_COUNT+1))
    RESULTS+=("M${NUM}: SKIP (no test script)")
    continue
  fi

  echo -e "${BOLD}────────────────────────────────────────${RESET}"
  echo -e "${BOLD}Testing Machine ${NUM}...${RESET}"
  echo ""

  FAIL_COUNT=0
  CLEANUP_FLAG="$CLEANUP"
  bash "$TEST_SCRIPT" "$BASE_DIR" "$CLEANUP_FLAG" 2>&1
  STATUS=$?

  TOTAL=$((TOTAL+1))
  if [ $STATUS -eq 0 ]; then
    PASS_COUNT=$((PASS_COUNT+1))
    RESULTS+=("M${NUM}: PASS")
  else
    RESULTS+=("M${NUM}: FAIL (exit $STATUS)")
  fi
  echo ""
done

# ── Summary ───────────────────────────────────────────────────
echo -e "${BOLD}════════════════════════════════════════${RESET}"
echo -e "${BOLD}  TEST SUMMARY${RESET}"
echo -e "${BOLD}════════════════════════════════════════${RESET}"
for r in "${RESULTS[@]}"; do
  if [[ "$r" == *PASS* ]]; then
    echo -e "  ${GREEN}$r${RESET}"
  elif [[ "$r" == *SKIP* ]]; then
    echo -e "  ${YELLOW}$r${RESET}"
  else
    echo -e "  ${RED}$r${RESET}"
  fi
done
echo ""
echo -e "Passed: ${GREEN}${PASS_COUNT}${RESET} | Failed: ${RED}$((TOTAL-PASS_COUNT))${RESET} | Skipped: ${YELLOW}${SKIP_COUNT}${RESET} | Total: ${TOTAL}"
echo ""
[ $((TOTAL - PASS_COUNT)) -eq 0 ] && exit 0 || exit 1
