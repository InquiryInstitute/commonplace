FROM ghost:5-alpine

# Install dependencies: gettext for envsubst, python for GCS
RUN apk add --no-cache python3 py3-pip gettext && \
    python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install gcsfs

# Copy custom configuration
COPY config.production.json /var/lib/ghost/config.production.json.template

# Create startup script that substitutes environment variables
RUN echo '#!/bin/sh' > /start-ghost.sh && \
    echo 'envsubst < /var/lib/ghost/config.production.json.template > /var/lib/ghost/config.production.json' >> /start-ghost.sh && \
    echo 'exec node current/index.js' >> /start-ghost.sh && \
    chmod +x /start-ghost.sh

# Set working directory
WORKDIR /var/lib/ghost

# Expose port
EXPOSE 2368

# Start Ghost with variable substitution
CMD ["/start-ghost.sh"]
