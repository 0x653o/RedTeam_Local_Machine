# Machine 22: react2shell -- CVE-2025-55182 (CVSS 10.0)
# Next.js RSC Flight protocol deserialization env pivot PostgreSQL SSH
FROM node:20
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
