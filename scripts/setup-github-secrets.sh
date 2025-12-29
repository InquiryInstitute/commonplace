#!/bin/bash
# Script to set up GitHub secrets for Ghost deployment
# This script requires gcloud authentication and gh CLI

set -e

PROJECT="institute-481516"
SERVICE_ACCOUNT="ghost-sa@institute-481516.iam.gserviceaccount.com"
KEY_FILE="/tmp/ghost-sa-key.json"

echo "=========================================="
echo "Setting up GitHub Secrets for Ghost Deployment"
echo "=========================================="
echo ""

# Check if gcloud is authenticated
echo "1. Checking gcloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ ERROR: No active gcloud authentication found"
    echo "   Please run: gcloud auth login"
    exit 1
fi
echo "✅ Authenticated as: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
echo ""

# Set project
echo "2. Setting gcloud project..."
gcloud config set project $PROJECT
echo "✅ Project set to: $PROJECT"
echo ""

# Get values from terraform outputs
echo "3. Getting values from Terraform outputs..."
cd "$(dirname "$0")/../terraform" || exit 1

CLOUDSQL_CONNECTION_NAME=$(terraform output -raw cloud_sql_connection_name 2>/dev/null || echo "institute-481516:us-central1:ghost-db-instance")
VPC_CONNECTOR=$(terraform output -raw vpc_connector_name 2>/dev/null || echo "projects/institute-481516/locations/us-central1/connectors/ghost-connector")
GCS_BUCKET=$(terraform output -raw gcs_bucket_name 2>/dev/null || echo "institute-481516-ghost-content")

echo "✅ Cloud SQL Connection: $CLOUDSQL_CONNECTION_NAME"
echo "✅ VPC Connector: $VPC_CONNECTOR"
echo "✅ GCS Bucket: $GCS_BUCKET"
echo ""

# Create or get service account key
echo "4. Creating service account key..."
if [ -f "$KEY_FILE" ]; then
    echo "⚠️  Key file already exists at $KEY_FILE"
    read -p "   Delete and create new key? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$KEY_FILE"
    else
        echo "   Using existing key file"
    fi
fi

if [ ! -f "$KEY_FILE" ]; then
    echo "   Creating new service account key..."
    gcloud iam service-accounts keys create "$KEY_FILE" \
        --iam-account="$SERVICE_ACCOUNT" \
        --project="$PROJECT" 2>&1 || {
        echo "❌ ERROR: Failed to create service account key"
        echo "   Make sure the service account exists and you have permissions"
        exit 1
    }
    echo "✅ Service account key created at $KEY_FILE"
fi
echo ""

# Set GitHub secrets
echo "5. Setting GitHub secrets..."

echo "   Setting GCP_PROJECT_ID..."
gh secret set GCP_PROJECT_ID --body "$PROJECT" 2>&1 || {
    echo "❌ ERROR: Failed to set GCP_PROJECT_ID"
    exit 1
}
echo "   ✅ GCP_PROJECT_ID set"

echo "   Setting CLOUDSQL_CONNECTION_NAME..."
gh secret set CLOUDSQL_CONNECTION_NAME --body "$CLOUDSQL_CONNECTION_NAME" 2>&1 || {
    echo "❌ ERROR: Failed to set CLOUDSQL_CONNECTION_NAME"
    exit 1
}
echo "   ✅ CLOUDSQL_CONNECTION_NAME set"

echo "   Setting VPC_CONNECTOR..."
gh secret set VPC_CONNECTOR --body "$VPC_CONNECTOR" 2>&1 || {
    echo "❌ ERROR: Failed to set VPC_CONNECTOR"
    exit 1
}
echo "   ✅ VPC_CONNECTOR set"

echo "   Setting GCS_BUCKET..."
gh secret set GCS_BUCKET --body "$GCS_BUCKET" 2>&1 || {
    echo "❌ ERROR: Failed to set GCS_BUCKET"
    exit 1
}
echo "   ✅ GCS_BUCKET set"

echo "   Setting SERVICE_ACCOUNT..."
gh secret set SERVICE_ACCOUNT --body "$SERVICE_ACCOUNT" 2>&1 || {
    echo "❌ ERROR: Failed to set SERVICE_ACCOUNT"
    exit 1
}
echo "   ✅ SERVICE_ACCOUNT set"

echo "   Setting GCP_SA_KEY (from key file)..."
gh secret set GCP_SA_KEY < "$KEY_FILE" 2>&1 || {
    echo "❌ ERROR: Failed to set GCP_SA_KEY"
    exit 1
}
echo "   ✅ GCP_SA_KEY set"
echo ""

# Verify secrets
echo "6. Verifying GitHub secrets..."
echo "----------------------------------------"
gh secret list 2>&1 | grep -E "(GCP_PROJECT_ID|GCP_SA_KEY|CLOUDSQL_CONNECTION_NAME|VPC_CONNECTOR|GCS_BUCKET|SERVICE_ACCOUNT)" || echo "⚠️  Could not verify secrets"
echo ""

echo "=========================================="
echo "✅ GitHub secrets configured successfully!"
echo "=========================================="
echo ""
echo "Secrets set:"
echo "  - GCP_PROJECT_ID: $PROJECT"
echo "  - CLOUDSQL_CONNECTION_NAME: $CLOUDSQL_CONNECTION_NAME"
echo "  - VPC_CONNECTOR: $VPC_CONNECTOR"
echo "  - GCS_BUCKET: $GCS_BUCKET"
echo "  - SERVICE_ACCOUNT: $SERVICE_ACCOUNT"
echo "  - GCP_SA_KEY: (from $KEY_FILE)"
echo ""
echo "⚠️  IMPORTANT: The service account key file is stored at:"
echo "   $KEY_FILE"
echo "   Keep this file secure and delete it if no longer needed."
echo ""
echo "Next steps:"
echo "1. Push to main branch or trigger workflow manually"
echo "2. Monitor GitHub Actions for deployment status"
echo ""
