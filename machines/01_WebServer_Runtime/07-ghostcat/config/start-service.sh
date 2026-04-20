#!/bin/bash
# Machine 07: GhostCat — Start Tomcat
echo "[*] Starting Tomcat 9.0.30 (AJP on 8009, HTTP on 8080)..."
exec su -c "/opt/tomcat/bin/catalina.sh run" tomcat
