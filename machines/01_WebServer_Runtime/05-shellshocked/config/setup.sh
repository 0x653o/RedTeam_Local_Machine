#!/bin/bash
# Machine 05: ShellShocked — Privilege escalation setup
# SUID nmap is already set in Dockerfile
# This script sets up the CGI scripts to use vulnerable bash

# Make CGI scripts use the vulnerable bash 4.3
for f in /usr/lib/cgi-bin/*.cgi; do
    sed -i "1s|.*|#!/opt/bash43/bin/bash|" "$f" 2>/dev/null
done

# Create Apache CGI config
cat > /etc/apache2/conf-available/serve-cgi-bin.conf << 'CONF'
<IfModule mod_alias.c>
    <IfModule mod_cgi.c>
        Define ENABLE_USR_LIB_CGI_BIN
    </IfModule>
    <IfModule mod_cgid.c>
        Define ENABLE_USR_LIB_CGI_BIN
    </IfModule>
    <IfDefine ENABLE_USR_LIB_CGI_BIN>
        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
            AllowOverride None
            Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
            Require all granted
        </Directory>
    </IfDefine>
</IfModule>
CONF

echo "[*] ShellShocked privesc setup complete (SUID nmap)"
