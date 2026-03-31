# Machine 16: thinkpwned -- CVE-2018-20062 (CVSS 9.8)
# ThinkPHP invokefunction RCE with SUID find
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl wget netcat-openbsd net-tools iproute2 openssh-server sudo vim procps cron && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash user

COPY config/ /opt/config/
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/generate-flags.sh 2>/dev/null || true

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
