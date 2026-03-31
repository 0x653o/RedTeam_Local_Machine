#!/bin/bash
set -e
SEED="${FLAG_SEED:-default-seed}"; MID="${MACHINE_ID:-03}"
echo "FLAG{$(echo -n "${SEED}:machine_${MID}" | sha256sum | cut -c1-32)}" > /root/root.txt; chmod 400 /root/root.txt
mkdir -p /home/user; echo "FLAG{$(echo -n "${SEED}:user_${MID}" | sha256sum | cut -c1-32)}" > /home/user/user.txt
chown user:user /home/user/user.txt; chmod 444 /home/user/user.txt
mkdir -p /var/run/sshd; ssh-keygen -A 2>/dev/null || true; /usr/sbin/sshd 2>/dev/null &
# Enable CGI
mkdir -p /opt/apache2/cgi-bin /usr/lib/cgi-bin
echo '#!/bin/bash' > /usr/lib/cgi-bin/test.cgi
echo 'echo "Content-Type: text/plain"; echo; echo "CGI works"' >> /usr/lib/cgi-bin/test.cgi
chmod +x /usr/lib/cgi-bin/test.cgi
echo "[*] PathFinder machine starting..."
/opt/apache2/bin/httpd -DFOREGROUND 2>/dev/null || apachectl -DFOREGROUND
