#!/bin/bash
# ──────────────────────────────────────────────────────────────
# Local-Machine — OpenVPN CA / Server Setup
# ──────────────────────────────────────────────────────────────
# Run this ONCE before anything else.
# It initializes the PKI, generates the CA, and starts the
# OpenVPN server — all inside Docker, nothing on the host.
#
# Usage:
#   ./infra/vpn/setup-ca.sh
#
# After this, use:
#   ./scripts/add-peer.sh <player_name>   ← generate player .ovpn
# ──────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VPN_COMPOSE="${SCRIPT_DIR}/docker-compose.yml"
DATA_DIR="${SCRIPT_DIR}/data"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# ── Load .env ─────────────────────────────────────────────────
source "${ROOT_DIR}/.env" 2>/dev/null || true

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
  ╔═╗╔═╗╔═╗╔╗╔  ╦  ╦╔═╗╔╗╔  ╔═╗╔═╗╔╦╗╦ ╦╔═╗
  ║ ║╠═╝║╣ ║║║  ╚╗╔╝╠═╝║║║  ╚═╗║╣  ║ ║ ║╠═╝
  ╚═╝╩  ╚═╝╝╚╝   ╚╝ ╩  ╝╚╝  ╚═╝╚═╝ ╩ ╚═╝╩
  One-Time CA Initialization
EOF
echo -e "${NC}"

# ── Guard: Already initialized? ───────────────────────────────
if [[ -f "${DATA_DIR}/pki/ca.crt" ]]; then
    log_warn "PKI already initialized at ${DATA_DIR}/pki/ca.crt"
    log_warn "To re-initialize, delete ${DATA_DIR}/ and re-run."
    exit 0
fi

# ── Resolve Public IP ─────────────────────────────────────────
log_step "1/4  Resolving public IP..."

if [[ -n "${SERVER_IP:-}" ]]; then
    PUBLIC_IP="${SERVER_IP}"
    log_ok "Using configured SERVER_IP: ${PUBLIC_IP}"
else
    PUBLIC_IP=$(curl -sf --max-time 5 https://ifconfig.me || \
                curl -sf --max-time 5 https://api.ipify.org || \
                curl -sf --max-time 5 https://icanhazip.com || true)
    if [[ -z "${PUBLIC_IP}" ]]; then
        log_error "Could not detect public IP. Set SERVER_IP=x.x.x.x in your .env file."
        exit 1
    fi
    log_ok "Detected public IP: ${PUBLIC_IP}"
fi

# ── Step 1: Generate server config ───────────────────────────
log_step "2/4  Generating OpenVPN server config..."

mkdir -p "${DATA_DIR}"

# ovpn_genconfig builds the server.conf and push routes
# -d disables default route (only lab traffic through VPN, not all internet)
# -p pushes the lab subnet route to connecting clients
docker compose -f "${VPN_COMPOSE}" run --rm openvpn \
    ovpn_genconfig \
    -u "udp://${PUBLIC_IP}:${VPN_PORT}" \
    -p "route 10.10.0.0 255.255.0.0" \
    -n "8.8.8.8" \
    -d

log_ok "Server config generated"

# ── Step 2: Initialize PKI / CA ───────────────────────────────
log_step "3/4  Initializing PKI (Certificate Authority)..."
echo ""
echo -e "  ${YELLOW}You will be prompted to set a CA passphrase.${NC}"
echo -e "  ${YELLOW}Remember it — you need it every time you add a new player.${NC}"
echo -e "  ${YELLOW}Or press Enter twice to use NO passphrase (easier for labs).${NC}"
echo ""

# EASYRSA_BATCH=1 skips confirmations; nopass skips CA key encryption
docker compose -f "${VPN_COMPOSE}" run --rm \
    -e EASYRSA_BATCH=1 \
    -e EASYRSA_REQ_CN="LocalMachine-CA" \
    openvpn ovpn_initpki nopass

log_ok "PKI initialized (CA created without passphrase — lab mode)"

# ── Step 3: Start OpenVPN server ─────────────────────────────
log_step "4/4  Starting OpenVPN server..."

docker compose -f "${VPN_COMPOSE}" up -d
sleep 3

# Verify
if docker compose -f "${VPN_COMPOSE}" ps | grep -q "Up\|running"; then
    log_ok "OpenVPN server is running on UDP ${PUBLIC_IP}:${VPN_PORT}"
else
    log_error "OpenVPN failed to start. Check logs:"
    log_error "  docker logs lm-vpn-gw"
    exit 1
fi

# ── Open firewall port ────────────────────────────────────────
if command -v ufw &>/dev/null && sudo ufw status | grep -q "Status: active"; then
    sudo ufw allow "${VPN_PORT}/udp" &>/dev/null
    log_ok "Firewall: UDP ${VPN_PORT} allowed"
fi

echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ✅  OpenVPN CA ready!${NC}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Next step — add your first player:"
echo -e "  ${CYAN}./scripts/add-peer.sh player1${NC}"
echo ""
echo -e "  Player connects with:"
echo -e "  ${CYAN}sudo openvpn player1.ovpn${NC}"
echo ""
