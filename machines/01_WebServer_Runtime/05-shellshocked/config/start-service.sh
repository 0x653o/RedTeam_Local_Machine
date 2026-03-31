#!/bin/bash
# Machine 05: ShellShocked — Start Apache
echo "[*] Starting Apache with CGI..."
exec apachectl -DFOREGROUND
