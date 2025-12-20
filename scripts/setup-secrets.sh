#!/bin/bash

# Script to setup Google Cloud Secret Manager secrets
# Usage: ./scripts/setup-secrets.sh

set -e

PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}
REGION=${GCP_REGION:-"us-central1"}

echo "Setting up secrets for Ghost installation..."

# Create secrets
echo "Creating secrets in Secret Manager..."

# Database password
read -sp "Enter database password: " DB_PASSWORD
echo ""
echo -n "$DB_PASSWORD" | gcloud secrets create db-password \
  --project=$PROJECT_ID \
  --data-file=- \
  --replication-policy="automatic" || \
echo -n "$DB_PASSWORD" | gcloud secrets versions add db-password \
  --project=$PROJECT_ID \
  --data-file=-

# Mail user
read -p "Enter email address for Ghost mail: " MAIL_USER
echo -n "$MAIL_USER" | gcloud secrets create mail-user \
  --project=$PROJECT_ID \
  --data-file=- \
  --replication-policy="automatic" || \
echo -n "$MAIL_USER" | gcloud secrets versions add mail-user \
  --project=$PROJECT_ID \
  --data-file=-

# Mail password
read -sp "Enter email password/app password: " MAIL_PASSWORD
echo ""
echo -n "$MAIL_PASSWORD" | gcloud secrets create mail-password \
  --project=$PROJECT_ID \
  --data-file=- \
  --replication-policy="automatic" || \
echo -n "$MAIL_PASSWORD" | gcloud secrets versions add mail-password \
  --project=$PROJECT_ID \
  --data-file=-

# GCS Service Account Keyfile
read -p "Enter path to GCS service account keyfile (JSON): " KEYFILE_PATH
if [ -f "$KEYFILE_PATH" ]; then
  gcloud secrets create gcs-keyfile \
    --project=$PROJECT_ID \
    --data-file="$KEYFILE_PATH" \
    --replication-policy="automatic" || \
  gcloud secrets versions add gcs-keyfile \
    --project=$PROJECT_ID \
    --data-file="$KEYFILE_PATH"
else
  echo "Keyfile not found. Please create a service account key and try again."
  exit 1
fi

echo "Secrets setup complete!"
