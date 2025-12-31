#!/bin/bash
# Quick setup script - Run this after authenticating gcloud

set -e

echo "=========================================="
echo "Quick Setup - Creating GCP_SA_KEY Secret"
echo "=========================================="
echo ""

# Check if authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ ERROR: Not authenticated"
    echo "   Please run: gcloud auth login custodian@inquiry.institute"
    exit 1
fi

PROJECT="institute-481516"
SERVICE_ACCOUNT="ghost-sa@institute-481516.iam.gserviceaccount.com"
KEY_FILE="/tmp/ghost-sa-key-$(date +%s).json"

echo "✅ Authenticated as: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
echo ""

# Set project
gcloud config set project $PROJECT
echo "✅ Project: $PROJECT"
echo ""

# Create key
echo "Creating service account key..."
gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SERVICE_ACCOUNT" \
    --project="$PROJECT" || {
    echo "❌ Failed to create key"
    exit 1
}
echo "✅ Key created: $KEY_FILE"
echo ""

# Set secret
echo "Setting GitHub secret..."
gh secret set GCP_SA_KEY < "$KEY_FILE" || {
    echo "❌ Failed to set secret"
    exit 1
}
echo "✅ GCP_SA_KEY set!"
echo ""

# Verify
echo "Verifying secrets..."
gh secret list | grep -E "(GCP_PROJECT_ID|GCP_SA_KEY|CLOUDSQL|VPC|GCS|SERVICE_ACCOUNT)"
echo ""

echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "All 6 secrets are now configured."
echo "You can now trigger a deployment!"
echo ""
echo "Next: git push origin main (or gh workflow run)"
echo ""
