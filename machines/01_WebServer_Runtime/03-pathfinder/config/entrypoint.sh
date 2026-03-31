#!/bin/bash
set -e

SEED="${FLAG_SEED:-default-seed}"
MID="${MACHINE_ID:-03}"

# Generate flags
ROOT_FLAG=$(echo -n "${SEED}:machine_${MID}" | sha256sum | cut -c1-32)
USER_FLAG=$(echo -n "${SEED}:user_${MID}" | sha256sum | cut -c1-32)
echo "FLAG{${ROOT_FLAG}}" > /root/root.txt; chmod 400 /root/root.txt
mkdir -p /home/user
echo "FLAG{${USER_FLAG}}" > /home/user/user.txt
chown user:user /home/user/user.txt; chmod 444 /home/user/user.txt

# Setup SSH
mkdir -p /var/run/sshd
ssh-keygen -A 2>/dev/null || true
/usr/sbin/sshd 2>/dev/null &

# Create web content
mkdir -p /opt/apache2/htdocs
cat > /opt/apache2/htdocs/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head><title>Internal Server</title></head>
<body>
<h1>Internal File Server</h1>
<p>Apache/2.4.49 — Internal use only.</p>
<ul>
  <li><a href="/cgi-bin/status.cgi">Server Status</a></li>
  <li><a href="/cgi-bin/test.cgi">Test CGI</a></li>
</ul>
</body>
</html>
HTML

# Create log directory
mkdir -p /opt/apache2/logs

echo "[*] PathFinder machine starting..."
echo "[*] Apache 2.4.49 with CGI enabled"

# Start Apache in foreground
exec /opt/apache2/bin/httpd -DFOREGROUND
