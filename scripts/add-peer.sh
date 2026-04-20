#!/bin/bash
# ──────────────────────────────────────────────────────────────
# Local-Machine — Automated OpenVPN Player Onboarding
# ──────────────────────────────────────────────────────────────
# HTB-style: generates a .ovpn file the player just runs once.
#
# Usage:
#   ./scripts/add-peer.sh <player_name>
#
# Prerequisites:
#   - Run ./infra/vpn/setup-ca.sh once first
#   - Lab must be running: ./run.sh up
#
# Output:
#   infra/vpn/players/<player_name>.ovpn
# ──────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VPN_COMPOSE="${SCRIPT_DIR}/infra/vpn/docker-compose.yml"
PLAYERS_DIR="${SCRIPT_DIR}/infra/vpn/players"

# ── Load .env ─────────────────────────────────────────────────
source "${SCRIPT_DIR}/.env" 2>/dev/null || true
VPN_PORT="${VPN_PORT:-1194}"

# ── Colors ────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

log_info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_step()  { echo -e "\n${MAGENTA}[STEP]${NC} ${BOLD}$*${NC}"; }

echo -e "${RED}"
cat << 'EOF'
  ╦  ╔╦╗   ╔═╗╔╦╗╔╦╗   ╔═╗╔═╗╔═╗╦═╗
  ║  ║║║───╠═╣ ║║ ║║───╠═╝║╣ ║╣ ╠╦╝
  ╩═╝╩ ╩   ╩ ╩═╩╝═╩╝   ╩  ╚═╝╚═╝╩╚═
  OpenVPN Player Config Generator
EOF
echo -e "${NC}"

# ── Argument validation ───────────────────────────────────────
PEER_NAME="${1:-}"
if [[ -z "${PEER_NAME}" ]]; then
    log_error "Usage: $0 <player_name>"
    log_error "Example: $0 alice"
    exit 1
fi

if [[ ! "${PEER_NAME}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    log_error "Player name must be alphanumeric (underscores/hyphens allowed). Got: '${PEER_NAME}'"
    exit 1
fi

# ── Step 1: Check PKI is initialized ─────────────────────────
log_step "1/4  Checking CA / PKI..."

if [[ ! -f "${SCRIPT_DIR}/infra/vpn/data/pki/ca.crt" ]]; then
    log_error "PKI not initialized. Run the one-time setup first:"
    log_error "  ./infra/vpn/setup-ca.sh"
    exit 1
fi
log_ok "CA found"

# ── Step 2: Check player doesn't already exist ────────────────
OVPN_OUTPUT="${PLAYERS_DIR}/${PEER_NAME}.ovpn"
mkdir -p "${PLAYERS_DIR}"

if [[ -f "${OVPN_OUTPUT}" ]]; then
    log_warn "Player '${PEER_NAME}' already has a config: ${OVPN_OUTPUT}"
    read -rp "  Regenerate? (y/N): " confirm
    if [[ "${confirm,,}" != "y" ]]; then
        log_info "Skipping. Existing config: ${OVPN_OUTPUT}"
        exit 0
    fi
fi

# ── Step 3: Generate client certificate ───────────────────────
log_step "2/4  Generating certificate for '${PEER_NAME}'..."

# Check if cert already exists in PKI
EXISTING=$(docker compose -f "${VPN_COMPOSE}" run --rm openvpn \
    bash -c "ls /etc/openvpn/pki/issued/ 2>/dev/null" | grep -w "${PEER_NAME}.crt" || true)

if [[ -n "${EXISTING}" ]]; then
    log_warn "Certificate already exists in PKI — reusing it"
else
    # build-client-full <name> nopass → client key without passphrase
    # Player just runs openvpn, no passphrase prompt
    docker compose -f "${VPN_COMPOSE}" run --rm \
        -e EASYRSA_BATCH=1 \
        openvpn \
        easyrsa build-client-full "${PEER_NAME}" nopass
    log_ok "Certificate issued for '${PEER_NAME}'"
fi

# ── Step 4: Export the .ovpn file ────────────────────────────
log_step "3/4  Exporting .ovpn file..."

# ovpn_getclient bundles: CA cert, client cert, client key, TLS auth → single .ovpn file
docker compose -f "${VPN_COMPOSE}" run --rm openvpn \
    ovpn_getclient "${PEER_NAME}" > "${OVPN_OUTPUT}"

# Verify the file isn't empty
if [[ ! -s "${OVPN_OUTPUT}" ]]; then
    log_error "Generated .ovpn file is empty. Check container logs:"
    log_error "  docker logs lm-vpn-gw"
    rm -f "${OVPN_OUTPUT}"
    exit 1
fi

log_ok "Saved: ${OVPN_OUTPUT}"

# ── Step 5: Open firewall ─────────────────────────────────────
log_step "4/4  Firewall check..."

if command -v ufw &>/dev/null && sudo ufw status | grep -q "Status: active"; then
    sudo ufw allow "${VPN_PORT}/udp" &>/dev/null
    log_ok "ufw: UDP ${VPN_PORT} is open"
else
    log_warn "ufw not active — ensure port ${VPN_PORT}/udp is open on your server"
fi

# ── Print player instructions ─────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ✅  ${PEER_NAME}.ovpn is ready!${NC}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}File:${NC}  ${OVPN_OUTPUT}"
echo ""
echo -e "  ${BOLD}Send the player this file + these instructions:${NC}"
echo ""
echo -e "  ┌──────────────────────────────────────────────────────────┐"
echo -e "  │                                                          │"
echo -e "  │  1. Install OpenVPN:                                     │"
echo -e "  │       Linux:    sudo apt install openvpn                 │"
echo -e "  │       Windows:  https://openvpn.net/community-downloads/ │"
echo -e "  │       macOS:    brew install openvpn                     │"
echo -e "  │                                                          │"
echo -e "  │  2. Connect (one command):                               │"
echo -e "  │       sudo openvpn ${PEER_NAME}.ovpn                     │"
echo -e "  │                                                          │"
echo -e "  │  3. Open lab dashboard:                                  │"
echo -e "  │       https://10.10.0.3:${PORTAL_PORT:-8443}             │"
echo -e "  │       Lab Secret: ${PORTAL_SECRET:-<see your .env>}      │"
echo -e "  │                                                          │"
echo -e "  │  4. Attack machines at:  10.10.<ID>.10                   │"
echo -e "  │       e.g.  nmap -sC -sV 10.10.1.10                     │"
echo -e "  │                                                          │"
echo -e "  └──────────────────────────────────────────────────────────┘"
echo ""
echo -e "  ${CYAN}All players:${NC}  ls ${PLAYERS_DIR}/"
echo -e "  ${CYAN}Revoke peer:${NC}  ./scripts/revoke-peer.sh ${PEER_NAME}"
echo ""
