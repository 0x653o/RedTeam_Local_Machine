#!/opt/bash43/bin/bash
# CGI script — Test page (VULNERABLE to Shellshock)
echo "Content-Type: text/plain"
echo ""
echo "CGI Test OK"
echo "Server: $(hostname)"
echo "Time: $(date)"
