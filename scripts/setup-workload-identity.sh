#!/bin/bash
# Setup Workload Identity Federation for GitHub Actions
# This is the recommended approach when service account keys are disabled

set -e

PROJECT="institute-481516"
SERVICE_ACCOUNT="ghost-sa@institute-481516.iam.gserviceaccount.com"
POOL_NAME="ghost-github-pool"
PROVIDER_NAME="ghost-github-provider"
REPO="InquiryInstitute/commonplace"

echo "=========================================="
echo "Setting up Workload Identity Federation"
echo "=========================================="
echo ""

# Check authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ ERROR: Not authenticated"
    echo "   Please run: gcloud auth login"
    exit 1
fi

echo "✅ Authenticated as: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
echo ""

# Set project
gcloud config set project $PROJECT
echo "✅ Project: $PROJECT"
echo ""

# Enable required APIs
echo "1. Enabling required APIs..."
gcloud services enable iamcredentials.googleapis.com --project=$PROJECT 2>&1 || echo "API may already be enabled"
gcloud services enable sts.googleapis.com --project=$PROJECT 2>&1 || echo "API may already be enabled"
echo "✅ APIs enabled"
echo ""

# Create Workload Identity Pool
echo "2. Creating Workload Identity Pool..."
if gcloud iam workload-identity-pools describe $POOL_NAME \
    --location=global \
    --project=$PROJECT 2>&1 | grep -q "NOT_FOUND"; then
    
    gcloud iam workload-identity-pools create $POOL_NAME \
        --location=global \
        --display-name="Ghost GitHub Actions Pool" \
        --project=$PROJECT || {
        echo "❌ Failed to create pool"
        exit 1
    }
    echo "✅ Pool created"
else
    echo "✅ Pool already exists"
fi
echo ""

# Create Workload Identity Provider
echo "3. Creating Workload Identity Provider..."
if gcloud iam workload-identity-pools providers describe $PROVIDER_NAME \
    --workload-identity-pool=$POOL_NAME \
    --location=global \
    --project=$PROJECT 2>&1 | grep -q "NOT_FOUND"; then
    
    gcloud iam workload-identity-pools providers create-oidc $PROVIDER_NAME \
        --workload-identity-pool=$POOL_NAME \
        --location=global \
        --issuer-uri="https://token.actions.githubusercontent.com" \
        --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
        --attribute-condition="assertion.repository == '$REPO'" \
        --project=$PROJECT || {
        echo "❌ Failed to create provider"
        exit 1
    }
    echo "✅ Provider created"
else
    echo "✅ Provider already exists"
fi
echo ""

# Get the provider resource name
PROVIDER_RESOURCE="projects/$PROJECT/locations/global/workloadIdentityPools/$POOL_NAME/providers/$PROVIDER_NAME"

# Grant service account access
echo "4. Granting service account access..."
gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe $PROJECT --format='value(projectNumber)')/locations/global/workloadIdentityPools/$POOL_NAME/attribute.repository/$REPO" \
    --project=$PROJECT || {
    echo "⚠️  Failed to add IAM binding (may already exist)"
}
echo "✅ Service account access granted"
echo ""

echo "=========================================="
echo "✅ Workload Identity Federation Setup Complete!"
echo "=========================================="
echo ""
echo "Provider Resource Name:"
echo "  $PROVIDER_RESOURCE"
echo ""
echo "Next steps:"
echo "1. Update .github/workflows/deploy.yml to use Workload Identity"
echo "2. Set GitHub secret: WORKLOAD_IDENTITY_PROVIDER=$PROVIDER_RESOURCE"
echo ""
