# Machine 19: picklerick -- CWE-502 (CVSS 9.8)
# Python pickle deserialization Redis pivot SSH key
FROM python:3.11-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y procps net-tools curl openssh-server sudo iproute2 && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash user

COPY config/ /opt/config/
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/generate-flags.sh 2>/dev/null || true

EXPOSE 5000
ENTRYPOINT ["/entrypoint.sh"]
