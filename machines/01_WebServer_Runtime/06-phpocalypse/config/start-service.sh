#!/bin/bash
# Machine 06: PHPocalypse — Start Apache with PHP-CGI
echo "[*] Starting Apache (PHP-CGI mode)..."
# Enable the CGI and actions modules
a2enmod cgi actions alias 2>/dev/null

# Ensure apache is configured correctly
apache2ctl configtest 2>&1 | grep -v "^Syntax OK" || true

exec apache2ctl -D FOREGROUND
