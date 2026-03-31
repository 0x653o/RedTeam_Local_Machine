# Machine 03: PathFinder — CVE-2021-41773
# Apache 2.4.49 path traversal + CGI RCE → kernel exploit → root
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    apache2=2.4.49-* 2>/dev/null || apt-get install -y apache2 && \
    apt-get install -y curl net-tools iproute2 openssh-server sudo procps gcc \
    && rm -rf /var/lib/apt/lists/*

# If we can't get exact 2.4.49, we'll compile from source
RUN if ! apache2 -v 2>/dev/null | grep -q "2.4.49"; then \
    apt-get update && apt-get install -y build-essential libapr1-dev libaprutil1-dev libpcre3-dev && \
    wget -q "https://archive.apache.org/dist/httpd/httpd-2.4.49.tar.gz" -O /tmp/httpd.tar.gz && \
    cd /tmp && tar xzf httpd.tar.gz && cd httpd-2.4.49 && \
    ./configure --prefix=/opt/apache2 --enable-cgid --enable-cgi && \
    make -j$(nproc) && make install && \
    rm -rf /tmp/httpd*; fi

RUN useradd -m -s /bin/bash user
COPY config/httpd.conf /opt/apache2/conf/httpd.conf 2>/dev/null || true
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/generate-flags.sh
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
