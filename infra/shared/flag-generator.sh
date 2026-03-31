#!/bin/bash
# ──────────────────────────────────────────────────────
# Local-Machine — Deterministic Flag Generator
# ──────────────────────────────────────────────────────
# Generates unique flags per machine based on FLAG_SEED.
# Flags are deterministic: same seed + machine ID = same flag.
#
# Usage:
#   ./flag-generator.sh <machine_id> [flag_seed]
#
# Environment:
#   FLAG_SEED — Global seed (overridden by arg 2)
#
# Output:
#   Creates /root/root.txt and /home/user/user.txt
# ──────────────────────────────────────────────────────

set -euo pipefail

MACHINE_ID="${1:?Usage: flag-generator.sh <machine_id> [flag_seed]}"
SEED="${2:-${FLAG_SEED:?FLAG_SEED environment variable not set}}"

# Generate root flag
ROOT_FLAG=$(echo -n "${SEED}:machine_${MACHINE_ID}" | sha256sum | cut -c1-32)
# Generate user flag
USER_FLAG=$(echo -n "${SEED}:user_${MACHINE_ID}" | sha256sum | cut -c1-32)

# Write flags
mkdir -p /root /home/user

echo "FLAG{${ROOT_FLAG}}" > /root/root.txt
chmod 400 /root/root.txt
chown root:root /root/root.txt

echo "FLAG{${USER_FLAG}}" > /home/user/user.txt
chmod 444 /home/user/user.txt

# Verify
echo "[+] Flags generated for machine ${MACHINE_ID}"
echo "    Root flag: FLAG{${ROOT_FLAG}}"
echo "    User flag: FLAG{${USER_FLAG}}"
