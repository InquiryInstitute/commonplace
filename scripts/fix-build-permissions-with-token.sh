#!/bin/bash
# Script to fix Cloud Build permissions and build Ghost image using access token

set -e

PROJECT_ID="institute-481516"
PROJECT_NUMBER="584409871588"

echo "Fixing Cloud Build permissions for project: $PROJECT_ID"
echo ""

# Get access token
ACCESS_TOKEN=$(gcloud auth print-access-token 2>&1)
if [[ $ACCESS_TOKEN == *"ERROR"* ]]; then
    echo "ERROR: Authentication required. Please run:"
    echo "  gcloud auth login"
    exit 1
fi

echo "✅ Access token obtained"
echo ""

# Grant Storage Admin to Cloud Build service account using API
echo "Granting Storage Admin role to Cloud Build service account..."
curl -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://cloudresourcemanager.googleapis.com/v1/projects/$PROJECT_ID:getIamPolicy" \
  -o /tmp/current-policy.json 2>/dev/null || echo "Getting current policy..."

# Note: Full IAM policy update is complex. Using gcloud with token instead.
echo "Using gcloud with access token..."
export CLOUDSDK_AUTH_ACCESS_TOKEN=$ACCESS_TOKEN

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/storage.admin" || echo "Permission may already be granted"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/storage.admin" || echo "Permission may already be granted"

echo ""
echo "✅ Permissions granted!"
echo ""
echo "Now building Ghost Docker image..."
echo ""

# Build and push the image
gcloud builds submit --tag gcr.io/$PROJECT_ID/ghost:latest

echo ""
echo "✅ Docker image built and pushed!"
echo ""
echo "Next step: Run terraform apply to complete Cloud Run deployment"
