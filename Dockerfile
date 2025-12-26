FROM ghost:5-alpine

# Install gcloud SDK for GCS storage adapter
# Use virtual environment to avoid externally-managed-environment error
RUN apk add --no-cache python3 py3-pip && \
    python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install gcsfs

# Copy custom configuration
COPY config.production.json /var/lib/ghost/config.production.json

# Set working directory
WORKDIR /var/lib/ghost

# Expose port
EXPOSE 2368

# Start Ghost
CMD ["node", "current/index.js"]
