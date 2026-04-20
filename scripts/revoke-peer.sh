#!/bin/bash
# ──────────────────────────────────────────────────────────────
# Local-Machine — Revoke a Player's VPN Access
# ──────────────────────────────────────────────────────────────
# Usage:
#   ./scripts/revoke-peer.sh <player_name>
#
# This invalidates the player's .ovpn file immediately.
# Their certificate is added to the CRL (revocation list).
# ──────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VPN_COMPOSE="${SCRIPT_DIR}/infra/vpn/docker-compose.yml"
PLAYERS_DIR="${SCRIPT_DIR}/infra/vpn/players"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

PEER_NAME="${1:-}"
if [[ -z "${PEER_NAME}" ]]; then
    log_error "Usage: $0 <player_name>"
    exit 1
fi

echo -e "${RED}[!] Revoking VPN access for: ${BOLD}${PEER_NAME}${NC}"
read -rp "    Confirm? (y/N): " confirm
if [[ "${confirm,,}" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

# Revoke the certificate via easyrsa
docker compose -f "${VPN_COMPOSE}" run --rm \
    -e EASYRSA_BATCH=1 \
    openvpn \
    easyrsa revoke "${PEER_NAME}"

# Regenerate CRL (Certificate Revocation List)
docker compose -f "${VPN_COMPOSE}" run --rm \
    -e EASYRSA_BATCH=1 \
    openvpn \
    easyrsa gen-crl

# Move their .ovpn file to a revoked directory
REVOKED_DIR="${PLAYERS_DIR}/revoked"
mkdir -p "${REVOKED_DIR}"
if [[ -f "${PLAYERS_DIR}/${PEER_NAME}.ovpn" ]]; then
    mv "${PLAYERS_DIR}/${PEER_NAME}.ovpn" "${REVOKED_DIR}/${PEER_NAME}.ovpn.revoked"
    log_ok "Moved config to ${REVOKED_DIR}/${PEER_NAME}.ovpn.revoked"
fi

# Restart OpenVPN to apply the new CRL
docker compose -f "${VPN_COMPOSE}" restart openvpn
log_ok "OpenVPN restarted — CRL applied"

echo ""
echo -e "${GREEN}✅  '${PEER_NAME}' has been revoked. Their .ovpn file is now invalid.${NC}"
