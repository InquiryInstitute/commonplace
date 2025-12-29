FROM ghost:5-alpine

# Install dependencies: gettext for envsubst
RUN apk add --no-cache gettext

# Copy custom configuration
COPY config.production.json /var/lib/ghost/config.production.json.template

# Create startup script that substitutes environment variables
RUN echo '#!/bin/sh' > /start-ghost.sh && \
    echo 'set -e' >> /start-ghost.sh && \
    echo 'echo "Starting Ghost with environment variable substitution..."' >> /start-ghost.sh && \
    echo 'envsubst '"'"'$DB_HOST $DB_PORT $DB_USER $DB_PASSWORD $DB_NAME $MAIL_USER $MAIL_PASSWORD'"'"' < /var/lib/ghost/config.production.json.template > /var/lib/ghost/config.production.json' >> /start-ghost.sh && \
    echo 'echo "Configuration file generated. Starting Ghost..."' >> /start-ghost.sh && \
    echo 'exec node current/index.js' >> /start-ghost.sh && \
    chmod +x /start-ghost.sh

# Set working directory
WORKDIR /var/lib/ghost

# Expose port
EXPOSE 2368

# Start Ghost with variable substitution
CMD ["/start-ghost.sh"]
