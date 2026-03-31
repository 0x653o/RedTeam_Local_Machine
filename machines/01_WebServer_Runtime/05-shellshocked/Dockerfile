# Machine 05: ShellShocked — CVE-2014-6271 (Shellshock)
# Apache CGI + old Bash → Shellshock RCE → SUID nmap → root
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache + old bash (Ubuntu 20.04 ships bash 5.0, we need to downgrade or simulate)
RUN apt-get update && apt-get install -y \
    apache2 curl wget net-tools iproute2 openssh-server \
    sudo vim procps nmap gcc \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user

# Build a vulnerable bash 4.3 from source
RUN wget -q "https://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz" -O /tmp/bash.tar.gz && \
    cd /tmp && tar xzf bash.tar.gz && cd bash-4.3 && \
    ./configure --prefix=/opt/bash43 && \
    make -j$(nproc) && make install && \
    rm -rf /tmp/bash*

# Setup CGI with vulnerable bash
RUN a2enmod cgid cgi && \
    mkdir -p /usr/lib/cgi-bin

# Create CGI scripts that use the VULNERABLE bash
COPY config/cgi-scripts/ /usr/lib/cgi-bin/
RUN chmod +x /usr/lib/cgi-bin/*.cgi

# Setup SUID nmap for privilege escalation
# nmap --interactive allows shell escape via !sh
RUN chmod u+s /usr/bin/nmap

COPY config/entrypoint.sh /entrypoint.sh
COPY config/setup.sh /opt/setup.sh
COPY config/start-service.sh /opt/config/start-service.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /opt/setup.sh /opt/config/start-service.sh \
    /healthcheck.sh /opt/generate-flags.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
