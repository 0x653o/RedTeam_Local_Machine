# Machine 03: PathFinder — CVE-2021-41773
# Apache 2.4.49 path traversal + CGI RCE → SUID privesc → root
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential wget curl libapr1-dev libaprutil1-dev libpcre3-dev \
    net-tools iproute2 openssh-server sudo procps vim \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user

# Build Apache 2.4.49 from source (exact vulnerable version)
RUN wget -q "https://archive.apache.org/dist/httpd/httpd-2.4.49.tar.gz" -O /tmp/httpd.tar.gz && \
    cd /tmp && tar xzf httpd.tar.gz && cd httpd-2.4.49 && \
    ./configure --prefix=/opt/apache2 \
        --enable-cgid --enable-cgi \
        --enable-rewrite --enable-so && \
    make -j$(nproc) && make install && \
    rm -rf /tmp/httpd*

# Create CGI scripts
RUN mkdir -p /opt/apache2/cgi-bin && \
    printf '#!/bin/bash\necho "Content-Type: text/plain"\necho\necho "Server Status: OK"\necho "Hostname: $(hostname)"\necho "Date: $(date)"\n' > /opt/apache2/cgi-bin/status.cgi && \
    printf '#!/bin/bash\necho "Content-Type: text/plain"\necho\necho "Test CGI script"\nid\n' > /opt/apache2/cgi-bin/test.cgi && \
    chmod +x /opt/apache2/cgi-bin/*.cgi

# Create a simple SUID binary for privesc
RUN apt-get update && apt-get install -y gcc && \
    printf '#include <stdio.h>\n#include <stdlib.h>\n#include <unistd.h>\nint main(int argc, char *argv[]) {\n    if (argc != 2) { printf("Usage: %%s <file>\\n", argv[0]); return 1; }\n    setuid(0); setgid(0);\n    char cmd[512]; snprintf(cmd, sizeof(cmd), "cat %%s", argv[1]);\n    return system(cmd);\n}\n' > /tmp/reader.c && \
    gcc -o /usr/local/bin/file-reader /tmp/reader.c && \
    chmod u+s /usr/local/bin/file-reader && \
    rm /tmp/reader.c && \
    apt-get remove -y gcc && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY config/httpd.conf /opt/apache2/conf/httpd.conf
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/generate-flags.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
