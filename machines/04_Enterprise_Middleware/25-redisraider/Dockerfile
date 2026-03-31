# Machine 25: RedisRaider — Misconfiguration
# Redis no auth → SSH key write → root
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    redis-server curl wget net-tools iproute2 \
    openssh-server sudo vim procps \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user

# Configure Redis with NO authentication (intentional miscfg)
COPY config/redis.conf /etc/redis/redis.conf

COPY config/entrypoint.sh /entrypoint.sh
COPY config/setup.sh /opt/setup.sh
COPY config/start-service.sh /opt/config/start-service.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /opt/setup.sh /opt/config/start-service.sh \
    /healthcheck.sh /opt/generate-flags.sh

EXPOSE 6379
ENTRYPOINT ["/entrypoint.sh"]
