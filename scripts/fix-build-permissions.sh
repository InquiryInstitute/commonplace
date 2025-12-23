#!/bin/bash
# Script to fix Cloud Build permissions and build Ghost image

set -e

PROJECT_ID="institute-481516"
PROJECT_NUMBER="584409871588"

echo "Fixing Cloud Build permissions for project: $PROJECT_ID"
echo ""

# Grant Storage Admin to Cloud Build service account
echo "Granting Storage Admin role to Cloud Build service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/storage.admin" || echo "Permission may already be granted"

# Also grant to compute service account (if needed)
echo "Granting Storage Admin role to Compute service account..."
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
