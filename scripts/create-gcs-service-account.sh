#!/bin/bash

# Script to create GCS service account for Ghost storage
# Usage: ./scripts/create-gcs-service-account.sh

set -e

PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}
SA_NAME="ghost-gcs-sa"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Creating service account for GCS access..."

# Create service account
gcloud iam service-accounts create $SA_NAME \
  --project=$PROJECT_ID \
  --display-name="Ghost GCS Service Account" \
  --description="Service account for Ghost to access Cloud Storage" || \
echo "Service account may already exist"

# Grant Storage Object Admin role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.objectAdmin"

# Create and download key
KEY_FILE="gcs-keyfile.json"
gcloud iam service-accounts keys create $KEY_FILE \
  --iam-account=$SA_EMAIL \
  --project=$PROJECT_ID

echo "Service account created: $SA_EMAIL"
echo "Key file saved to: $KEY_FILE"
echo ""
echo "Next steps:"
echo "1. Upload this keyfile to Secret Manager using setup-secrets.sh"
echo "2. Store this keyfile securely (it will be used in Secret Manager)"
