# Machine 04: strutszone -- CVE-2017-5638 (CVSS 10.0)
# Apache Struts2 OGNL injection via Content-Type header
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl wget netcat-openbsd net-tools iproute2 openssh-server sudo vim procps cron && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash user

COPY config/ /opt/config/
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/generate-flags.sh 2>/dev/null || true

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
