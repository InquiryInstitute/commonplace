#!/bin/bash
# Run this script in your terminal to complete the setup
# It requires interactive browser authentication

echo "=========================================="
echo "Completing GitHub Secrets Setup"
echo "=========================================="
echo ""
echo "Step 1: Authenticating gcloud (will open browser)..."
gcloud auth login custodian@inquiry.institute

echo ""
echo "Step 2: Setting project..."
gcloud config set project institute-481516

echo ""
echo "Step 3: Creating service account key and setting GitHub secret..."
./QUICK_SETUP.sh

echo ""
echo "Done! All secrets should now be configured."
echo "Run: gh secret list (to verify)"
