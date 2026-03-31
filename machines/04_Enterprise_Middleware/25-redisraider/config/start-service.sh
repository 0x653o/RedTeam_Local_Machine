#!/bin/bash
# Machine 25: RedisRaider — Start Redis (foreground, no auth)
echo "[*] Starting Redis on port 6379 (NO AUTH)..."
exec redis-server /etc/redis/redis.conf
