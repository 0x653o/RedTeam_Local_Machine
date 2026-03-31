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

# Install Apache Tomcat 9.0.60 (required for Spring4Shell — WAR + Tomcat combo)
WORKDIR /opt
RUN wget -q "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.60/bin/apache-tomcat-9.0.60.tar.gz" \
    -O /tmp/tomcat.tar.gz && \
    tar xzf /tmp/tomcat.tar.gz -C /opt/ && \
    mv /opt/apache-tomcat-9.0.60 /opt/tomcat && \
    rm /tmp/tomcat.tar.gz && \
    chown -R tomcat:tomcat /opt/tomcat

# Download vulnerable Spring Framework WAR
# Using a known-vulnerable Spring MVC petclinic-like WAR
# Spring Framework 5.3.17 on JDK 11+ with Tomcat WAR deployment = vulnerable
RUN mkdir -p /opt/vuln-war && \
    wget -q "https://repo1.maven.org/maven2/org/springframework/spring-webmvc/5.3.17/spring-webmvc-5.3.17.jar" \
        -O /opt/vuln-war/spring-webmvc-5.3.17.jar && \
    wget -q "https://repo1.maven.org/maven2/org/springframework/spring-beans/5.3.17/spring-beans-5.3.17.jar" \
        -O /opt/vuln-war/spring-beans-5.3.17.jar && \
    wget -q "https://repo1.maven.org/maven2/org/springframework/spring-context/5.3.17/spring-context-5.3.17.jar" \
        -O /opt/vuln-war/spring-context-5.3.17.jar && \
    wget -q "https://repo1.maven.org/maven2/org/springframework/spring-core/5.3.17/spring-core-5.3.17.jar" \
        -O /opt/vuln-war/spring-core-5.3.17.jar && \
    wget -q "https://repo1.maven.org/maven2/org/springframework/spring-expression/5.3.17/spring-expression-5.3.17.jar" \
        -O /opt/vuln-war/spring-expression-5.3.17.jar && \
    wget -q "https://repo1.maven.org/maven2/org/springframework/spring-web/5.3.17/spring-web-5.3.17.jar" \
        -O /opt/vuln-war/spring-web-5.3.17.jar && \
    wget -q "https://repo1.maven.org/maven2/org/springframework/spring-aop/5.3.17/spring-aop-5.3.17.jar" \
        -O /opt/vuln-war/spring-aop-5.3.17.jar && \
    wget -q "https://repo1.maven.org/maven2/org/springframework/spring-jcl/5.3.17/spring-jcl-5.3.17.jar" \
        -O /opt/vuln-war/spring-jcl-5.3.17.jar

# Build the minimal vulnerable WAR application
COPY config/vuln-app/ /opt/vuln-war/src/
RUN cd /opt/vuln-war && \
    mkdir -p /opt/vuln-war/build/WEB-INF/lib && \
    mkdir -p /opt/vuln-war/build/WEB-INF/classes && \
    cp /opt/vuln-war/*.jar /opt/vuln-war/build/WEB-INF/lib/ && \
    cp /opt/vuln-war/src/web.xml /opt/vuln-war/build/WEB-INF/web.xml && \
    cp /opt/vuln-war/src/dispatcher-servlet.xml /opt/vuln-war/build/WEB-INF/dispatcher-servlet.xml && \
    javac -cp "/opt/vuln-war/build/WEB-INF/lib/*" \
        -d /opt/vuln-war/build/WEB-INF/classes \
        /opt/vuln-war/src/*.java 2>/dev/null || true && \
    cd /opt/vuln-war/build && jar -cf /opt/tomcat/webapps/springapp.war . && \
    chown tomcat:tomcat /opt/tomcat/webapps/springapp.war

# Remove default Tomcat webapps (cleanup noise for recon)
RUN rm -rf /opt/tomcat/webapps/ROOT /opt/tomcat/webapps/docs \
    /opt/tomcat/webapps/examples /opt/tomcat/webapps/host-manager

COPY config/setup-cron.sh /opt/setup-cron.sh
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh

RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/setup-cron.sh /opt/generate-flags.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
