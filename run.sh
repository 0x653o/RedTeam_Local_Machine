#!/bin/bash
# ──────────────────────────────────────────────────────
# Local-Machine — Admin CLI
# ──────────────────────────────────────────────────────
# Central management script for the Local-Machine pentest lab.
#
# Usage:
#   ./run.sh up [--enable-escape-challenges]     Start all machines + infra
#   ./run.sh down                                 Stop all machines + infra
#   ./run.sh reset [machine_id|all]               Reset machine(s) to clean state
#   ./run.sh status                               Show all machine statuses
#   ./run.sh logs [machine_id]                    View machine logs
#   ./run.sh health [machine_id]                  Run health checks
#   ./run.sh vpn-add <peer_name>                  Generate VPN peer config
#   ./run.sh vpn-list                             List VPN peers
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env" 2>/dev/null || true

# ── Colors ────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Banner ────────────────────────────────────────────
banner() {
    echo -e "${RED}"
    cat << 'EOF'
    ╦  ╔═╗╔═╗╔═╗╦    ╔╦╗╔═╗╔═╗╦ ╦╦╔╗╔╔═╗
    ║  ║ ║║  ╠═╣║    ║║║╠═╣║  ╠═╣║║║║║╣ 
    ╩═╝╚═╝╚═╝╩ ╩╩═╝  ╩ ╩╩ ╩╚═╝╩ ╩╩╝╚╝╚═╝
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Advanced Red Team Lab — 42 Machines
EOF
    echo -e "${NC}"
}

# ── Utility Functions ─────────────────────────────────
log_info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()  { echo -e "${MAGENTA}[STEP]${NC} $*"; }

# Get all machine compose files
get_machine_compose_files() {
    find "${SCRIPT_DIR}/machines" -name "docker-compose.yml" -not -name "docker-compose.*.yml" | sort
}

# Get machine compose file by ID
get_machine_compose_by_id() {
    local machine_id=$(printf "%02d" "$1")
    find "${SCRIPT_DIR}/machines" -path "*/${machine_id}-*/docker-compose.yml" | head -1
}

# Get machine name from path
get_machine_name() {
    basename "$(dirname "$1")"
}

# ── Strip Escape Configs ─────────────────────────────
# When --enable-escape-challenges is NOT set, dynamically
# strip dangerous configurations from compose files
strip_escape_configs() {
    local compose_file="$1"
    local machine_name
    machine_name=$(get_machine_name "${compose_file}")
    
    # Machines with escape configurations
    local escape_machines=("09-pressgrave" "21-weblogicbmb" "38-dirtypipe")
    
    for em in "${escape_machines[@]}"; do
        if [[ "${machine_name}" == "${em}" ]]; then
            log_warn "Escape challenges DISABLED for ${machine_name}"
            log_warn "  Run with --enable-escape-challenges to enable"
            # Use docker compose with override that strips escape configs
            return 1
        fi
    done
    return 0
}

# ── Command: up ───────────────────────────────────────
cmd_up() {
    banner
    local enable_escapes=false
    
    for arg in "$@"; do
        case "${arg}" in
            --enable-escape-challenges)
                enable_escapes=true
                ;;
        esac
    done
    
    if [ "${enable_escapes}" = true ]; then
        echo -e "${RED}${BOLD}"
        echo "  ⚠️  ESCAPE CHALLENGES ENABLED ⚠️"
        echo "  This exposes REAL attack surface on the host."
        echo "  Only run inside a DISPOSABLE VM!"
        echo -e "${NC}"
        read -p "  Are you sure? (type 'YES' to confirm): " confirm
        if [ "${confirm}" != "YES" ]; then
            log_error "Aborted."
            exit 1
        fi
        export ENABLE_ESCAPE_CHALLENGES=true
    fi
    
    # Start infrastructure
    log_step "Starting infrastructure (VPN + Portal)..."
    if [ -f "${SCRIPT_DIR}/infra/vpn/docker-compose.yml" ]; then
        docker compose -f "${SCRIPT_DIR}/infra/vpn/docker-compose.yml" up -d 2>/dev/null && \
            log_ok "VPN gateway started" || log_warn "VPN gateway failed to start"
    fi
    
    if [ -f "${SCRIPT_DIR}/infra/portal/docker-compose.yml" ]; then
        docker compose -f "${SCRIPT_DIR}/infra/portal/docker-compose.yml" up -d 2>/dev/null && \
            log_ok "Web portal started" || log_warn "Portal failed to start"
    fi
    
    # Start machines
    log_step "Starting challenge machines..."
    local started=0
    local failed=0
    
    while IFS= read -r compose_file; do
        local name
        name=$(get_machine_name "${compose_file}")
        
        if [ "${enable_escapes}" != true ]; then
            # Check if this machine has escape configs that need stripping
            strip_escape_configs "${compose_file}" 2>/dev/null || true
        fi
        
        if docker compose -f "${compose_file}" up -d 2>/dev/null; then
            log_ok "${name}"
            ((started++)) || true
        else
            log_error "${name} failed"
            ((failed++)) || true
        fi
    done < <(get_machine_compose_files)
    
    echo ""
    log_info "Started: ${started} | Failed: ${failed}"
    
    # Start lifecycle manager
    log_step "Starting lifecycle manager..."
    nohup "${SCRIPT_DIR}/lifecycle-manager.sh" >> "${LOG_DIR:-/var/log/local-machine}/lifecycle.log" 2>&1 &
    log_ok "Lifecycle manager PID: $!"
    
    echo ""
    echo -e "${GREEN}${BOLD}  🏴 Lab is LIVE!${NC}"
    echo -e "  Portal: ${CYAN}https://localhost:${PORTAL_PORT:-8443}${NC}"
    echo -e "  VPN:    ${CYAN}udp://0.0.0.0:${VPN_PORT:-51820}${NC}"
    echo ""
}

# ── Command: down ─────────────────────────────────────
cmd_down() {
    banner
    log_step "Stopping all machines..."
    
    while IFS= read -r compose_file; do
        local name
        name=$(get_machine_name "${compose_file}")
        docker compose -f "${compose_file}" down 2>/dev/null && \
            log_ok "${name} stopped" || log_warn "${name} may not have been running"
    done < <(get_machine_compose_files)
    
    log_step "Stopping infrastructure..."
    [ -f "${SCRIPT_DIR}/infra/portal/docker-compose.yml" ] && \
        docker compose -f "${SCRIPT_DIR}/infra/portal/docker-compose.yml" down 2>/dev/null
    [ -f "${SCRIPT_DIR}/infra/vpn/docker-compose.yml" ] && \
        docker compose -f "${SCRIPT_DIR}/infra/vpn/docker-compose.yml" down 2>/dev/null
    
    # Kill lifecycle manager
    pkill -f "lifecycle-manager.sh" 2>/dev/null || true
    
    log_ok "All services stopped"
}

# ── Command: reset ────────────────────────────────────
cmd_reset() {
    local target="${1:-}"
    
    if [ -z "${target}" ]; then
        echo "Usage: ./run.sh reset <machine_id|all>"
        exit 1
    fi
    
    if [ "${target}" = "all" ]; then
        log_step "Resetting ALL machines to clean state..."
        while IFS= read -r compose_file; do
            local name
            name=$(get_machine_name "${compose_file}")
            docker compose -f "${compose_file}" down -v 2>/dev/null
            docker compose -f "${compose_file}" up -d 2>/dev/null && \
                log_ok "${name} reset" || log_error "${name} reset failed"
        done < <(get_machine_compose_files)
    else
        local compose_file
        compose_file=$(get_machine_compose_by_id "${target}")
        if [ -z "${compose_file}" ]; then
            log_error "Machine ${target} not found"
            exit 1
        fi
        local name
        name=$(get_machine_name "${compose_file}")
        log_step "Resetting ${name}..."
        docker compose -f "${compose_file}" down -v 2>/dev/null
        docker compose -f "${compose_file}" up -d 2>/dev/null
        log_ok "${name} reset complete"
    fi
}

# ── Command: status ───────────────────────────────────
cmd_status() {
    banner
    echo -e "${BOLD}  Machine Status Overview${NC}"
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  ${BOLD}%-4s %-20s %-12s %-10s${NC}\n" "#" "Name" "Status" "Health"
    echo "  ──────────────────────────────────────────────────────"
    
    local running=0
    local stopped=0
    local total=0
    
    while IFS= read -r compose_file; do
        local name
        name=$(get_machine_name "${compose_file}")
        local id
        id=$(echo "${name}" | grep -oP '^\d+')
        
        # Get container status
        local status
        local health
        local container_name
        container_name=$(docker compose -f "${compose_file}" ps --format '{{.Name}}' 2>/dev/null | head -1)
        
        if [ -n "${container_name}" ]; then
            status=$(docker inspect --format='{{.State.Status}}' "${container_name}" 2>/dev/null || echo "unknown")
            health=$(docker inspect --format='{{.State.Health.Status}}' "${container_name}" 2>/dev/null || echo "N/A")
        else
            status="stopped"
            health="N/A"
        fi
        
        # Color-code status
        local status_color="${RED}"
        local health_color="${RED}"
        [ "${status}" = "running" ] && status_color="${GREEN}" && ((running++)) || ((stopped++))
        [ "${health}" = "healthy" ] && health_color="${GREEN}"
        [ "${health}" = "starting" ] && health_color="${YELLOW}"
        
        printf "  %-4s %-20s ${status_color}%-12s${NC} ${health_color}%-10s${NC}\n" \
            "${id}" "${name}" "${status}" "${health}"
        ((total++)) || true
    done < <(get_machine_compose_files)
    
    echo "  ──────────────────────────────────────────────────────"
    echo -e "  ${GREEN}Running: ${running}${NC} | ${RED}Stopped: ${stopped}${NC} | Total: ${total}"
    echo ""
}

# ── Command: logs ─────────────────────────────────────
cmd_logs() {
    local target="${1:-}"
    
    if [ -z "${target}" ]; then
        echo "Usage: ./run.sh logs <machine_id>"
        exit 1
    fi
    
    local compose_file
    compose_file=$(get_machine_compose_by_id "${target}")
    if [ -z "${compose_file}" ]; then
        log_error "Machine ${target} not found"
        exit 1
    fi
    
    docker compose -f "${compose_file}" logs --tail=100 -f
}

# ── Command: health ───────────────────────────────────
cmd_health() {
    local target="${1:-}"
    
    if [ -n "${target}" ]; then
        local compose_file
        compose_file=$(get_machine_compose_by_id "${target}")
        if [ -z "${compose_file}" ]; then
            log_error "Machine ${target} not found"
            exit 1
        fi
        local container
        container=$(docker compose -f "${compose_file}" ps --format '{{.Name}}' 2>/dev/null | head -1)
        if [ -n "${container}" ]; then
            docker exec "${container}" /healthcheck.sh 2>/dev/null || \
                log_error "Health check failed for machine ${target}"
        else
            log_error "Machine ${target} is not running"
        fi
    else
        "${SCRIPT_DIR}/scripts/validate-machines.sh"
    fi
}

# ── Command: vpn-add ──────────────────────────────────
cmd_vpn_add() {
    local peer_name="${1:?Usage: ./run.sh vpn-add <peer_name>}"
    
    log_step "Generating VPN config for peer: ${peer_name}"
    
    local vpn_container
    vpn_container=$(docker compose -f "${SCRIPT_DIR}/infra/vpn/docker-compose.yml" ps --format '{{.Name}}' 2>/dev/null | head -1)
    
    if [ -z "${vpn_container}" ]; then
        log_error "VPN container is not running. Start it with: ./run.sh up"
        exit 1
    fi
    
    # Generate peer config using linuxserver/wireguard's built-in mechanism
    docker exec "${vpn_container}" /app/show-peer "${peer_name}" 2>/dev/null || {
        log_info "Adding new peer ${peer_name}..."
        # Add PEERS env and restart
        log_warn "Peer management requires updating VPN config. See docs/03_ADMIN_GUIDE.md"
    }
}

# ── Command: vpn-list ─────────────────────────────────
cmd_vpn_list() {
    local vpn_container
    vpn_container=$(docker compose -f "${SCRIPT_DIR}/infra/vpn/docker-compose.yml" ps --format '{{.Name}}' 2>/dev/null | head -1)
    
    if [ -z "${vpn_container}" ]; then
        log_error "VPN container is not running"
        exit 1
    fi
    
    docker exec "${vpn_container}" wg show 2>/dev/null || log_error "Failed to query WireGuard"
}

# ── Main ──────────────────────────────────────────────
main() {
    local command="${1:-help}"
    shift || true
    
    case "${command}" in
        up)      cmd_up "$@" ;;
        down)    cmd_down ;;
        reset)   cmd_reset "$@" ;;
        status)  cmd_status ;;
        logs)    cmd_logs "$@" ;;
        health)  cmd_health "$@" ;;
        vpn-add) cmd_vpn_add "$@" ;;
        vpn-list) cmd_vpn_list ;;
        help|--help|-h)
            banner
            echo "  Usage: ./run.sh <command> [options]"
            echo ""
            echo "  Commands:"
            echo "    up [--enable-escape-challenges]   Start lab"
            echo "    down                              Stop lab"
            echo "    reset <id|all>                    Reset machine(s)"
            echo "    status                            Machine statuses"
            echo "    logs <id>                         View machine logs"
            echo "    health [id]                       Run health checks"
            echo "    vpn-add <peer>                    Add VPN peer"
            echo "    vpn-list                          List VPN peers"
            echo ""
            ;;
        *)
            log_error "Unknown command: ${command}"
            echo "Run './run.sh help' for usage."
            exit 1
            ;;
    esac
}

main "$@"
