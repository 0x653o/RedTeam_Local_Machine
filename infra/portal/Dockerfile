FROM node:20-alpine

WORKDIR /app

# Install dependencies
RUN apk add --no-cache curl openssl

# Generate self-signed cert for HTTPS
RUN mkdir -p /app/certs && \
    openssl req -x509 -nodes -days 365 \
    -subj "/C=XX/ST=Lab/L=Lab/O=LocalMachine/CN=portal.local" \
    -newkey rsa:2048 \
    -keyout /app/certs/key.pem \
    -out /app/certs/cert.pem

# Copy application
COPY src/ /app/src/
COPY package.json /app/package.json

RUN npm install --production 2>/dev/null || true

EXPOSE 8443

CMD ["node", "src/server.js"]
