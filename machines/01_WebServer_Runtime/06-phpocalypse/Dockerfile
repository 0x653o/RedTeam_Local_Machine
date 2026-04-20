# ──────────────────────────────────────────────────────
# Machine 06: PHPocalypse — CVE-2012-1823 (CVSS 9.8)
# PHP-CGI argument injection → RCE → writable cron → root
# ──────────────────────────────────────────────────────
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# ── Base system ───────────────────────────────────────
RUN apt-get update && apt-get install -y \
    curl wget netcat-openbsd net-tools iproute2 \
    openssh-server sudo vim procps cron \
    software-properties-common gnupg2 \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# ── Install PHP 5.6 from ondrej PPA (only version with CVE-2012-1823) ──
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update && apt-get install -y \
    php5.6 \
    php5.6-cgi \
    libapache2-mod-php5.6 \
    apache2 \
    && rm -rf /var/lib/apt/lists/*

# ── Create users ──────────────────────────────────────
RUN useradd -m -s /bin/bash user && \
    echo "user:user123" | chpasswd

# ── Configure Apache to route PHP through php-cgi binary ──
# This is the vulnerable configuration: php-cgi exposed and query-string
# arguments are passed directly to the php-cgi binary.
RUN a2dismod php5.6 2>/dev/null || true && \
    a2enmod cgi actions alias

# Apache vhost config that uses php-cgi (the vulnerable setup)
COPY config/apache-php-cgi.conf /etc/apache2/sites-available/000-default.conf

# ── Create vulnerable web application ─────────────────
RUN mkdir -p /var/www/html
COPY config/www/ /var/www/html/
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# ── Create php-cgi as CGI script ──────────────────────
RUN ln -sf /usr/bin/php-cgi5.6 /usr/lib/cgi-bin/php-cgi && \
    chmod +x /usr/lib/cgi-bin/php-cgi

# ── Create writable cron script (privesc vector) ──────
RUN mkdir -p /opt/scripts && \
    echo '#!/bin/bash' > /opt/scripts/backup.sh && \
    echo '# System backup script' >> /opt/scripts/backup.sh && \
    echo 'rsync -a /var/www/html /tmp/backup/ 2>/dev/null' >> /opt/scripts/backup.sh && \
    chmod 777 /opt/scripts/backup.sh && \
    echo '* * * * * root /opt/scripts/backup.sh' >> /etc/crontab

# ── Build SUID file-reader binary (final privesc) ─────
COPY config/vuln-reader.c /tmp/vuln-reader.c
RUN gcc -o /usr/local/bin/vuln-reader /tmp/vuln-reader.c && \
    chmod u+s /usr/local/bin/vuln-reader && \
    rm /tmp/vuln-reader.c

# ── SSH setup ─────────────────────────────────────────
RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A 2>/dev/null || true

# ── Copy scripts ──────────────────────────────────────
COPY config/entrypoint.sh /entrypoint.sh
COPY config/setup.sh /opt/setup.sh
COPY config/start-service.sh /opt/config/start-service.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh

RUN chmod +x /entrypoint.sh /opt/setup.sh /opt/config/start-service.sh \
    /healthcheck.sh /opt/generate-flags.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
