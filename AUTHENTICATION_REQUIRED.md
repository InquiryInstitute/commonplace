# Authentication Required

To complete the Terraform deployment, you need to authenticate the `custodian@inquiry.institute` account.

## Quick Fix

Run these commands in your terminal:

```bash
# Set the account
gcloud config set account custodian@inquiry.institute
gcloud config set project institute-481516

# Authenticate the account (will open browser)
gcloud auth login custodian@inquiry.institute

# Set up application default credentials (will open browser)
gcloud auth application-default login --account=custodian@inquiry.institute
```

After authentication, run:

```bash
cd terraform
terraform apply
```

## Alternative: Use Service Account

If you prefer to use a service account (recommended for CI/CD):

1. Create a service account with necessary permissions:
```bash
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account" \
  --project=institute-481516

# Grant necessary roles
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:terraform-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/owner"
```

2. Create and download key:
```bash
gcloud iam service-accounts keys create terraform-key.json \
  --iam-account=terraform-sa@institute-481516.iam.gserviceaccount.com \
  --project=institute-481516
```

3. Use with Terraform:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/terraform-key.json
cd terraform
terraform apply
```

## Current Status

- ✅ Billing account linked: `01F153-96A498-0EC7EE` (Inquiry.Institute)
- ✅ GCP APIs enabled (most of them)
- ✅ Terraform configuration validated
- ✅ AWS Route 53 zone already exists (from previous run)
- ⚠️ Need authentication for `custodian@inquiry.institute` account

## What Will Be Created

Once authenticated, Terraform will create:
- Cloud SQL MySQL instance
- VPC network and connector
- Cloud Storage bucket
- Service accounts and IAM bindings
- Secret Manager secrets
- Cloud Run service (placeholder)
- Route 53 DNS record (already exists, will be updated)
