FROM n8nio/n8n:1.33.0

ENV NODE_ENV=production
ENV TZ=UTC

RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    awscli \
    jq \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Configure n8n for ECS
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV N8N_DIAGNOSTICS_ENABLED=false
N8N_SECURE_COOKIE=false
ENV N8N_EDITOR_BASE_URL=https://n8n.bspcloud.com  # Update with your domain

# Webhook configuration for ECS
ENV WEBHOOK_URL=https://n8n.bspcloud.com         # Update with your domain
ENV VUE_APP_URL_BASE_API=https://n8n.bspcloud.com # Update with your domain

# Create directories for persistent data
RUN mkdir -p /data/n8n && \
    chown -R node:node /data/n8n && \
    mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

# Switch to non-root user
USER node

# Volume for persistent data
VOLUME ["/home/node/.n8n"]

ENTRYPOINT ["/home/node/entrypoint.sh"]
CMD ["n8n", "start"]
