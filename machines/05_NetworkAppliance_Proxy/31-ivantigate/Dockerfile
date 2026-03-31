# Machine 31: ivantigate -- CVE-2024-21887 (CVSS 9.1)
# Ivanti Connect Secure auth bypass cmd injection
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl wget netcat-openbsd net-tools iproute2 openssh-server sudo vim procps cron && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash user

COPY config/ /opt/config/
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/generate-flags.sh 2>/dev/null || true

EXPOSE 443
ENTRYPOINT ["/entrypoint.sh"]
