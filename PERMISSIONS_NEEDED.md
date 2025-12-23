# Permissions Required

## Current Status

✅ **Terraform is working!** It can authenticate and plan resources.

❌ **Service account needs more permissions** to create resources.

## Solution

The service account `ghost-gcs-sa@institute-481516.iam.gserviceaccount.com` needs additional permissions. 

### Option 1: Grant Owner Role (Easiest)

Run this command (requires authenticated user account with project owner/admin):

```bash
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/owner"
```

### Option 2: Grant Specific Roles (More Secure)

```bash
# Compute Engine Admin (for VPC networks)
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

# Storage Admin (for buckets)
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# IAM Service Account Admin (to create service accounts)
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

# Secret Manager Admin (to create secrets)
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/secretmanager.admin"

# Cloud SQL Admin (for database)
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/cloudsql.admin"

# Cloud Run Admin (for Cloud Run service)
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# VPC Access Admin (for VPC connector)
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/vpcaccess.admin"
```

## After Granting Permissions

Once permissions are granted, run:

```bash
cd terraform
export GOOGLE_APPLICATION_CREDENTIALS="$(cd .. && pwd)/gcs-keyfile.json"
terraform apply
```

## What Will Be Created

Once permissions are in place, Terraform will create:
- ✅ Cloud SQL MySQL instance and database
- ✅ VPC network, subnet, and connector
- ✅ Cloud Storage bucket
- ✅ Service accounts and IAM bindings
- ✅ Secret Manager secrets (structure)
- ✅ Cloud Run service (placeholder)
- ✅ Route 53 DNS record (already exists, will be updated)

## Current Authentication

✅ Using service account: `ghost-gcs-sa@institute-481516.iam.gserviceaccount.com`
✅ Service account key file: `gcs-keyfile.json`
✅ Terraform can authenticate and plan
❌ Service account lacks permissions to create resources
