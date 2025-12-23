#!/bin/bash
# Script to grant permissions using authenticated gcloud
# This requires a user account with project admin permissions

set -e

PROJECT_ID="naphome-korvo1"
SERVICE_ACCOUNT="ghost-gcs-sa@${PROJECT_ID}.iam.gserviceaccount.com"

echo "=========================================="
echo "Granting permissions to service account"
echo "=========================================="
echo "Project: $PROJECT_ID"
echo "Service Account: $SERVICE_ACCOUNT"
echo ""

# Check authentication
CURRENT_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || echo "")
if [ -z "$CURRENT_ACCOUNT" ]; then
    echo "❌ ERROR: No active gcloud authentication found."
    echo ""
    echo "Please authenticate first:"
    echo "  gcloud auth login"
    echo "  gcloud config set project $PROJECT_ID"
    echo ""
    exit 1
fi

echo "✅ Authenticated as: $CURRENT_ACCOUNT"
echo ""

# Set project
gcloud config set project $PROJECT_ID

# Grant Owner role
echo "Granting Owner role to service account..."
if gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/owner" \
  --condition=None 2>&1; then
    echo "✅ Owner role granted successfully!"
else
    echo "⚠️  Note: Role may already be granted or you may need additional permissions"
fi

echo ""
echo "Verifying permissions..."
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:${SERVICE_ACCOUNT}" \
  --format="table(bindings.role)" 2>&1 || echo "Could not verify (may need permissions)"

echo ""
echo "=========================================="
echo "✅ Permission grant complete!"
echo "=========================================="
echo ""
echo "You can now run:"
echo "  cd terraform"
echo "  export GOOGLE_APPLICATION_CREDENTIALS=\"\$(cd .. && pwd)/gcs-keyfile.json\""
echo "  terraform apply"
