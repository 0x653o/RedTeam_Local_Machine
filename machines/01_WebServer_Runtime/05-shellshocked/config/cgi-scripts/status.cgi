#!/opt/bash43/bin/bash
# CGI script — Server Status (VULNERABLE to Shellshock)
echo "Content-Type: text/html"
echo ""
echo "<html><head><title>Server Status</title></head><body>"
echo "<h1>System Status</h1>"
echo "<p>Hostname: $(hostname)</p>"
echo "<p>Uptime: $(uptime)</p>"
echo "<p>Date: $(date)</p>"
echo "<p>User: $(whoami)</p>"
echo "</body></html>"
