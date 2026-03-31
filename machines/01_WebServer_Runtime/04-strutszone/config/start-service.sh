#!/bin/bash
# Machine 04: StrutsZone — Start Tomcat with vulnerable Struts2
echo "[*] Starting Tomcat with Struts2 showcase..."
exec su -c "/opt/tomcat/bin/catalina.sh run" tomcat
