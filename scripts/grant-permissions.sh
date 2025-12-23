#!/bin/bash
# Script to grant necessary permissions to the service account
# This must be run with a user account that has project Owner/Admin permissions

set -e

PROJECT_ID=${GCP_PROJECT_ID:-"institute-481516"}
SERVICE_ACCOUNT="ghost-gcs-sa@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Granting permissions to service account: $SERVICE_ACCOUNT"
echo "Project: $PROJECT_ID"
echo ""

# Check if we're authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "ERROR: No active gcloud authentication found."
    echo "Please run: gcloud auth login"
    exit 1
fi

echo "Granting roles to service account..."

# Grant Owner role (simplest, gives all permissions)
echo "Granting Owner role..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/owner" \
  --condition=None || echo "Owner role may already be granted"

echo ""
echo "✅ Permissions granted successfully!"
echo ""
echo "You can now run:"
echo "  cd terraform"
echo "  export GOOGLE_APPLICATION_CREDENTIALS=\"\$(cd .. && pwd)/gcs-keyfile.json\""
echo "  terraform apply"
