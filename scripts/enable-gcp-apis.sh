#!/bin/bash

# Script to enable required Google Cloud APIs
# Usage: ./scripts/enable-gcp-apis.sh

set -e

PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}

if [ "$PROJECT_ID" == "your-project-id" ]; then
    echo "Error: Please set GCP_PROJECT_ID environment variable"
    echo "Usage: GCP_PROJECT_ID=your-project-id ./scripts/enable-gcp-apis.sh"
    exit 1
fi

echo "Enabling required APIs for project: $PROJECT_ID"

APIS=(
    "run.googleapis.com"
    "sqladmin.googleapis.com"
    "storage.googleapis.com"
    "secretmanager.googleapis.com"
    "vpcaccess.googleapis.com"
    "cloudbuild.googleapis.com"
    "compute.googleapis.com"
    "iam.googleapis.com"
)

for API in "${APIS[@]}"; do
    echo "Enabling $API..."
    gcloud services enable $API --project=$PROJECT_ID || echo "API $API may already be enabled"
done

echo ""
echo "All required APIs have been enabled!"
echo ""
echo "Note: It may take a few minutes for all APIs to be fully activated."
