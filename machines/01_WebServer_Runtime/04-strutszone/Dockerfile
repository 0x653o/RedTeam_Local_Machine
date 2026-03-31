# Machine 04: StrutsZone — CVE-2017-5638
# Apache Struts 2.3.x OGNL injection in Content-Type → RCE → sudo find → root
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-8-jdk-headless curl wget net-tools iproute2 \
    openssh-server sudo vim procps \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user && \
    useradd -m -s /bin/bash tomcat

# Install Tomcat 8.5 + vulnerable Struts 2.3.31 showcase
WORKDIR /opt
RUN wget -q "https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.78/bin/apache-tomcat-8.5.78.tar.gz" \
    -O /tmp/tomcat.tar.gz && \
    tar xzf /tmp/tomcat.tar.gz -C /opt/ && \
    mv /opt/apache-tomcat-8.5.78 /opt/tomcat && \
    rm /tmp/tomcat.tar.gz && \
    chown -R tomcat:tomcat /opt/tomcat

# Download the vulnerable Struts2 showcase WAR
RUN wget -q "https://archive.apache.org/dist/struts/2.3.31/struts-2.3.31-apps.zip" \
    -O /tmp/struts.zip && \
    apt-get update && apt-get install -y unzip && \
    cd /tmp && unzip -q struts.zip && \
    cp /tmp/struts-2.3.31/apps/struts2-showcase-2.3.31.war /opt/tomcat/webapps/struts2-showcase.war && \
    rm -rf /tmp/struts* && \
    apt-get remove -y unzip && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Remove default webapps
RUN rm -rf /opt/tomcat/webapps/ROOT /opt/tomcat/webapps/docs \
    /opt/tomcat/webapps/examples /opt/tomcat/webapps/host-manager

COPY config/entrypoint.sh /entrypoint.sh
COPY config/setup.sh /opt/setup.sh
COPY config/start-service.sh /opt/config/start-service.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /opt/setup.sh /opt/config/start-service.sh \
    /healthcheck.sh /opt/generate-flags.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
