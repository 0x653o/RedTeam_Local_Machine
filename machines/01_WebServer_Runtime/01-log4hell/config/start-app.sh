#!/bin/bash
# Start the vulnerable Java web application
cd /opt/webapp
mkdir -p /var/log/webapp

exec java \
    -cp ".:/opt/webapp/lib/*" \
    -Dlog4j.configurationFile=/opt/webapp/log4j2.xml \
    -Dcom.sun.jndi.ldap.object.trustURLCodebase=true \
    -Dcom.sun.jndi.rmi.object.trustURLCodebase=true \
    VulnApp
