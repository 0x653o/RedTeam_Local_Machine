# ──────────────────────────────────────────────────────
# Machine 07: GhostCat — CVE-2020-1938 (CVSS 9.8)
# Tomcat AJP file read → WEB-INF/web.xml creds leak
# → Tomcat Manager WAR deploy → root
# ──────────────────────────────────────────────────────

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# ── Base system ───────────────────────────────────────
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk-headless \
    curl wget netcat-openbsd net-tools iproute2 \
    openssh-server sudo vim procps cron \
    && rm -rf /var/lib/apt/lists/*

# ── Create users ──────────────────────────────────────
RUN useradd -m -s /bin/bash user && \
    useradd -m -s /bin/bash tomcat && \
    echo "user:user123" | chpasswd

# ── Install Tomcat 9.0.30 (last version with AJP enabled by default) ──
WORKDIR /opt
RUN wget -q "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.30/bin/apache-tomcat-9.0.30.tar.gz" \
    -O /tmp/tomcat.tar.gz && \
    tar xzf /tmp/tomcat.tar.gz -C /opt/ && \
    mv /opt/apache-tomcat-9.0.30 /opt/tomcat && \
    rm /tmp/tomcat.tar.gz && \
    chown -R tomcat:tomcat /opt/tomcat

# ── Remove default example webapps, keep manager ──────
RUN rm -rf /opt/tomcat/webapps/docs \
    /opt/tomcat/webapps/examples \
    /opt/tomcat/webapps/host-manager

# ── Deploy vulnerable webapp ──────────────────────────
RUN mkdir -p /opt/tomcat/webapps/app/WEB-INF
COPY config/web.xml /opt/tomcat/webapps/app/WEB-INF/web.xml
COPY config/index.jsp /opt/tomcat/webapps/app/index.jsp

# ── Tomcat configuration ──────────────────────────────
# server.xml: AJP on 8009 (secretRequired=false — exploitable)
COPY config/server.xml /opt/tomcat/conf/server.xml
# tomcat-users.xml: admin account for Manager
COPY config/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
# Allow manager access from any IP
COPY config/manager-context.xml /opt/tomcat/webapps/manager/META-INF/context.xml

RUN chown -R tomcat:tomcat /opt/tomcat

# ── Sudo misconfiguration (privesc vector) ────────────
RUN echo "tomcat ALL=(ALL) NOPASSWD: /usr/bin/find" >> /etc/sudoers.d/tomcat && \
    chmod 440 /etc/sudoers.d/tomcat

# ── SSH ───────────────────────────────────────────────
RUN mkdir -p /var/run/sshd && ssh-keygen -A 2>/dev/null || true

# ── Scripts ───────────────────────────────────────────
COPY config/entrypoint.sh /entrypoint.sh
COPY config/setup.sh /opt/setup.sh
COPY config/start-service.sh /opt/config/start-service.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh

RUN chmod +x /entrypoint.sh /opt/setup.sh /opt/config/start-service.sh \
    /healthcheck.sh /opt/generate-flags.sh

EXPOSE 8009 8080
ENTRYPOINT ["/entrypoint.sh"]
