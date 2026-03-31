# Machine 18: protopoison -- CWE-1321 (CVSS 9.8)
# Node.js prototype pollution into EJS SSTI RCE
FROM node:18-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update 2>/dev/null || true; apt-get install -y procps net-tools curl 2>/dev/null || apk add --no-cache procps net-tools curl 2>/dev/null || true
RUN adduser --disabled-password --gecos '' user 2>/dev/null || useradd -m user 2>/dev/null || true

COPY config/ /opt/config/
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/generate-flags.sh 2>/dev/null || true

EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
