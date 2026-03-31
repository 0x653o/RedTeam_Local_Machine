# ──────────────────────────────────────────────────────
# Machine 01: Log4Hell — Dockerfile
# ──────────────────────────────────────────────────────
# Builds a vulnerable Java web application using
# Log4j 2.14.1 (affected by CVE-2021-44228).
#
# The app is a simple Spring Boot webapp that logs
# user-controlled input via Log4j.
# ──────────────────────────────────────────────────────

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ── System setup ──────────────────────────────────────
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk-headless \
    curl \
    wget \
    netcat-openbsd \
    net-tools \
    iproute2 \
    openssh-server \
    sudo \
    vim \
    procps \
    cron \
    && rm -rf /var/lib/apt/lists/*

# ── Create users ──────────────────────────────────────
RUN useradd -m -s /bin/bash user && \
    useradd -m -s /bin/bash appuser && \
    echo "root:$(head -c 32 /dev/urandom | sha256sum | cut -c1-32)" | chpasswd

# ── Install vulnerable Log4j application ─────────────
WORKDIR /opt/webapp

# Download vulnerable Log4j 2.14.1
RUN mkdir -p /opt/webapp/lib && \
    wget -q "https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.14.1/log4j-core-2.14.1.jar" \
        -O /opt/webapp/lib/log4j-core-2.14.1.jar && \
    wget -q "https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.14.1/log4j-api-2.14.1.jar" \
        -O /opt/webapp/lib/log4j-api-2.14.1.jar

# Copy vulnerable application
COPY config/VulnApp.java /opt/webapp/VulnApp.java
COPY config/log4j2.xml /opt/webapp/log4j2.xml
COPY config/start-app.sh /opt/webapp/start-app.sh

# Compile vulnerable application
RUN javac -cp "/opt/webapp/lib/*" /opt/webapp/VulnApp.java 2>/dev/null || true

# ── Setup SUID binary for privilege escalation ────────
# Create a custom SUID binary that reads files as root
COPY config/vuln-reader.c /tmp/vuln-reader.c
RUN apt-get update && apt-get install -y gcc && \
    gcc -o /usr/local/bin/vuln-reader /tmp/vuln-reader.c && \
    chmod u+s /usr/local/bin/vuln-reader && \
    rm /tmp/vuln-reader.c && \
    apt-get remove -y gcc && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# ── Generate flags ────────────────────────────────────
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /opt/generate-flags.sh

# ── Health check ──────────────────────────────────────
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

# ── Startup ───────────────────────────────────────────
COPY config/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /opt/webapp/start-app.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
