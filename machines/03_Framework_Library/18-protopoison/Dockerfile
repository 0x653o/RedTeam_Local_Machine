# Machine 18: ProtoPoison — CWE-1321
# Node.js Prototype Pollution → EJS SSTI → RCE (runs as root)
FROM node:18-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    procps net-tools curl openssh-server sudo iproute2 vim \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user 2>/dev/null || true

# Install app dependencies
WORKDIR /opt/app
COPY config/app/ /opt/app/
RUN cd /opt/app && npm install --production 2>/dev/null || true

COPY config/entrypoint.sh /entrypoint.sh
COPY config/setup.sh /opt/setup.sh
COPY config/start-service.sh /opt/config/start-service.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /opt/setup.sh /opt/config/start-service.sh \
    /healthcheck.sh /opt/generate-flags.sh

EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
