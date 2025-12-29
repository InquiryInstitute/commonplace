#!/bin/bash
# Create service account key and set as GitHub secret
# This requires gcloud authentication

set -e

PROJECT="institute-481516"
SERVICE_ACCOUNT="ghost-sa@institute-481516.iam.gserviceaccount.com"
KEY_FILE="/tmp/ghost-sa-key-$(date +%s).json"

echo "=========================================="
echo "Creating Service Account Key and Setting GitHub Secret"
echo "=========================================="
echo ""

# Check authentication
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

# Create service account key
echo "3. Creating service account key..."
gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SERVICE_ACCOUNT" \
    --project="$PROJECT" 2>&1 || {
    echo "❌ ERROR: Failed to create service account key"
    echo "   Make sure the service account exists and you have permissions"
    exit 1
}
echo "✅ Service account key created at $KEY_FILE"
echo ""

# Set GitHub secret
echo "4. Setting GCP_SA_KEY GitHub secret..."
gh secret set GCP_SA_KEY < "$KEY_FILE" 2>&1 || {
    echo "❌ ERROR: Failed to set GCP_SA_KEY"
    echo "   Key file is at: $KEY_FILE"
    exit 1
}
echo "✅ GCP_SA_KEY set in GitHub secrets"
echo ""

# Verify
echo "5. Verifying secret..."
if gh secret list 2>&1 | grep -q "GCP_SA_KEY"; then
    echo "✅ GCP_SA_KEY is set in GitHub secrets"
else
    echo "⚠️  Could not verify GCP_SA_KEY in secrets list"
fi
echo ""

echo "=========================================="
echo "✅ Service account key created and secret set!"
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT: The service account key file is stored at:"
echo "   $KEY_FILE"
echo "   Keep this file secure and delete it if no longer needed."
echo ""
echo "   To delete the key file: rm $KEY_FILE"
echo ""
