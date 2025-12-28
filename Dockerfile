FROM ghost:5-alpine

# Install dependencies: gettext for envsubst
RUN apk add --no-cache gettext

# Install Ghost GCS storage adapter
WORKDIR /var/lib/ghost
RUN npm install --save ghost-storage-adapter-gcs

# Copy custom configuration
COPY config.production.json /var/lib/ghost/config.production.json.template

# Create startup script that substitutes environment variables
RUN echo '#!/bin/sh' > /start-ghost.sh && \
    echo 'envsubst < /var/lib/ghost/config.production.json.template > /var/lib/ghost/config.production.json' >> /start-ghost.sh && \
    echo 'exec node current/index.js' >> /start-ghost.sh && \
    chmod +x /start-ghost.sh

# Expose port
EXPOSE 2368

# Start Ghost with variable substitution
CMD ["/start-ghost.sh"]
