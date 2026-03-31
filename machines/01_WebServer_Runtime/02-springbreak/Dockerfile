# Machine 02: SpringBreak — CVE-2022-22965 (Spring4Shell)
# Spring Boot app with class loader RCE → JSP webshell → cron hijack → root

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk-headless curl wget netcat-openbsd net-tools \
    iproute2 openssh-server sudo vim procps cron \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user && \
    useradd -m -s /bin/bash tomcat

# Install vulnerable Spring Boot application (Tomcat 9 + Spring 5.3.17)
WORKDIR /opt/webapp
RUN mkdir -p /opt/webapp/lib /opt/tomcat

# Download Apache Tomcat 9.0.60 (vulnerable version)
RUN wget -q "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.60/bin/apache-tomcat-9.0.60.tar.gz" \
    -O /tmp/tomcat.tar.gz && \
    tar xzf /tmp/tomcat.tar.gz -C /opt/tomcat --strip-components=1 && \
    rm /tmp/tomcat.tar.gz

# Copy vulnerable Spring Boot WAR
COPY config/vuln-app/ /opt/webapp/
COPY config/setup-cron.sh /opt/setup-cron.sh
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh

RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/setup-cron.sh /opt/generate-flags.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
