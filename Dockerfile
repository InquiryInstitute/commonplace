FROM ghost:5-alpine

# Install gcloud SDK for GCS storage adapter
RUN apk add --no-cache python3 py3-pip && \
    pip3 install --upgrade pip && \
    pip3 install gcsfs

# Copy custom configuration
COPY config.production.json /var/lib/ghost/config.production.json

# Set working directory
WORKDIR /var/lib/ghost

# Expose port
EXPOSE 2368

# Start Ghost
CMD ["node", "current/index.js"]
