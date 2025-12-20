#!/bin/bash

# Script to create GitHub repository in InquiryInstitute organization
# Usage: ./scripts/create-github-repo.sh

set -e

ORG="InquiryInstitute"
REPO_NAME="commonplace"
DESCRIPTION="Ghost CMS installation for commonplace.inquiry.institute"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Not authenticated with GitHub. Please run: gh auth login"
    exit 1
fi

echo "Creating repository $REPO_NAME in $ORG organization..."

# Create the repository
gh repo create "$ORG/$REPO_NAME" \
  --public \
  --description "$DESCRIPTION" \
  --clone || \
echo "Repository may already exist"

# If repository was created, add remote and push
if [ -d ".git" ]; then
    echo "Repository already initialized locally"
else
    echo "Initializing git repository..."
    git init
    git branch -M main
fi

# Check if remote exists
if git remote get-url origin &> /dev/null; then
    echo "Remote 'origin' already exists"
    git remote set-url origin "https://github.com/$ORG/$REPO_NAME.git"
else
    git remote add origin "https://github.com/$ORG/$REPO_NAME.git"
fi

echo ""
echo "Repository created: https://github.com/$ORG/$REPO_NAME"
echo ""
echo "Next steps:"
echo "1. Add and commit your files:"
echo "   git add ."
echo "   git commit -m 'Initial commit: Ghost installation setup'"
echo "2. Push to GitHub:"
echo "   git push -u origin main"
echo ""
echo "3. Configure GitHub Secrets:"
echo "   - GCP_PROJECT_ID"
echo "   - GCP_SA_KEY"
echo "   - CLOUDSQL_CONNECTION_NAME (after Terraform apply)"
echo "   - VPC_CONNECTOR (after Terraform apply)"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "   - DB_PASSWORD"
