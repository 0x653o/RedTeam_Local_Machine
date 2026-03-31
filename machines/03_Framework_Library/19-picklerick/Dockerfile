# Machine 19: PickleRick — CWE-502
# Flask + Pickle deserialization → RCE → Redis cred dump → root SSH
FROM python:3.11-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    redis-server procps net-tools curl openssh-server \
    sudo iproute2 vim \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user 2>/dev/null || true

WORKDIR /opt/app
COPY config/app/ /opt/app/
RUN pip install --no-cache-dir -r /opt/app/requirements.txt

COPY config/entrypoint.sh /entrypoint.sh
COPY config/setup.sh /opt/setup.sh
COPY config/start-service.sh /opt/config/start-service.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /opt/setup.sh /opt/config/start-service.sh \
    /healthcheck.sh /opt/generate-flags.sh

EXPOSE 5000
ENTRYPOINT ["/entrypoint.sh"]
