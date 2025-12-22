#!/bin/bash
# Script to setup application default credentials for custodian account
# This requires manual browser authentication

echo "Setting up application default credentials for custodian@inquiry.institute"
echo ""
echo "Please run the following command in your terminal:"
echo "  gcloud auth application-default login --account=custodian@inquiry.institute"
echo ""
echo "Or if you have a service account key file:"
echo "  export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json"
echo ""
echo "After authentication, run terraform apply again."
