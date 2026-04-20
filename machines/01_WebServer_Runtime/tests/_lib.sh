#!/bin/bash
# ── Shared test helpers for 01_WebServer_Runtime tests ────────
export DOCKER_HOST="unix://${HOME}/.docker/desktop/docker.sock"
# Source this file at the top of each machine test script:
#   source "$(dirname "$0")/_lib.sh"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

PASS_COUNT=0; FAIL_COUNT=0
CONTAINER_STARTED=false

pass() { echo -e "  ${GREEN}✅ PASS${RESET} $1"; PASS_COUNT=$((PASS_COUNT+1)); }
fail() { echo -e "  ${RED}❌ FAIL${RESET} $1"; FAIL_COUNT=$((FAIL_COUNT+1)); }
warn() { echo -e "  ${YELLOW}⚠️  WARN${RESET} $1"; }
info() { echo -e "  ${CYAN}ℹ${RESET}  $1"; }
section() { echo -e "\n${BOLD}  ── $1${RESET}"; }

# Start a machine container. Args: compose_file container_name [timeout_secs]
start_machine() {
  local compose_file=$1 container=$2 timeout=${3:-90}
  info "Building & starting $container (timeout: ${timeout}s)..."
  docker compose -f "$compose_file" up -d --build 2>&1 | tail -5
  CONTAINER_STARTED=true

  # Wait for container to be healthy or running
  local elapsed=0
  while [ $elapsed -lt $timeout ]; do
    local state
    state=$(docker inspect "$container" --format '{{.State.Status}}' 2>/dev/null || echo "missing")
    local health
    health=$(docker inspect "$container" --format '{{.State.Health.Status}}' 2>/dev/null || echo "none")

    if [ "$health" = "healthy" ]; then
      pass "Container healthy after ${elapsed}s"
      return 0
    elif [ "$health" = "unhealthy" ]; then
      fail "Container reported unhealthy after ${elapsed}s"
      docker logs "$container" --tail 20 2>/dev/null || true
      return 1
    elif [ "$state" = "exited" ]; then
      fail "Container exited unexpectedly"
      docker logs "$container" --tail 20 2>/dev/null || true
      return 1
    fi
    sleep 5; elapsed=$((elapsed+5))
    echo -n "."
  done
  echo ""
  warn "Timeout waiting for health — proceeding with functional tests anyway"
}

# Stop and remove a machine container
stop_machine() {
  local compose_file=$1
  [ "$CONTAINER_STARTED" = true ] && \
    docker compose -f "$compose_file" down --volumes 2>/dev/null || true
}

# Check TCP port is open on a container IP
check_port() {
  local ip=$1 port=$2 label=${3:-"port $port"}
  if timeout 5 bash -c "echo >/dev/tcp/${ip}/${port}" 2>/dev/null; then
    pass "$label is open (${ip}:${port})"
    return 0
  else
    fail "$label not reachable (${ip}:${port})"
    return 1
  fi
}

# Check HTTP endpoint returns expected status code
check_http() {
  local url=$1 expected_code=${2:-200} label=${3:-$url}
  local code
  code=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 5 "$url" 2>/dev/null)
  if [ "$code" = "$expected_code" ]; then
    pass "HTTP $expected_code from $label"
  else
    fail "HTTP $code (expected $expected_code) from $label"
  fi
}

# Check HTTP response body contains a string
check_http_contains() {
  local url=$1 needle=$2 label=${3:-"response"}
  local body
  body=$(curl -sk --max-time 5 "$url" 2>/dev/null)
  if echo "$body" | grep -q "$needle"; then
    pass "$label contains '$needle'"
  else
    fail "$label missing '$needle'"
    info "Actual body snippet: $(echo "$body" | head -3)"
  fi
}

# Execute a command inside a container and check output
check_exec() {
  local container=$1 cmd=$2 needle=$3 label=$4
  local out
  out=$(docker exec "$container" bash -c "$cmd" 2>/dev/null)
  if echo "$out" | grep -q "$needle"; then
    pass "$label"
  else
    fail "$label — expected '$needle', got: $(echo "$out" | head -3)"
  fi
}

# Print final result and exit
finish() {
  echo ""
  echo -e "  ${BOLD}Result: ${PASS_COUNT} passed, ${FAIL_COUNT} failed${RESET}"
  [ $FAIL_COUNT -eq 0 ] && exit 0 || exit 1
}
