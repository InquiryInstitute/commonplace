# Current Deployment Status

## ❌ Deployment Failed - Permissions Required

Terraform attempted to create resources but failed due to insufficient permissions on the service account.

## What Happened

The service account `ghost-gcs-sa@naphome-korvo1.iam.gserviceaccount.com` is being used for authentication, but it lacks the following permissions:

1. **compute.networks.create** - To create VPC network
2. **storage.buckets.create** - To create Cloud Storage bucket  
3. **iam.serviceAccounts.create** - To create service accounts
4. **secretmanager.secrets.create** - To create secrets

## Solution

You need to grant the service account Owner role or the specific roles listed in `PERMISSIONS_NEEDED.md`.

### Quick Fix (Run this command):

```bash
gcloud projects add-iam-policy-binding naphome-korvo1 \
  --member="serviceAccount:ghost-gcs-sa@naphome-korvo1.iam.gserviceaccount.com" \
  --role="roles/owner"
```

**Note:** This requires you to be authenticated with a user account that has Project Owner or IAM Admin permissions.

### After Granting Permissions

Once permissions are granted, run:

```bash
cd terraform
export GOOGLE_APPLICATION_CREDENTIALS="$(cd .. && pwd)/gcs-keyfile.json"
terraform apply
```

## What's Ready to Deploy

Terraform plan shows **15 resources** ready to create:
- ✅ Cloud SQL MySQL instance and database
- ✅ VPC network, subnet, and connector
- ✅ Cloud Storage bucket
- ✅ Service accounts and IAM bindings
- ✅ Secret Manager secrets
- ✅ Cloud Run service
- ✅ Route 53 DNS record (already exists)

## Current Configuration

- **Project**: naphome-korvo1
- **Service Account**: ghost-gcs-sa@naphome-korvo1.iam.gserviceaccount.com
- **Authentication**: ✅ Working (using service account key)
- **Billing**: ✅ Enabled
- **APIs**: ✅ Enabled
- **Permissions**: ❌ Need to grant Owner role

## Next Steps

1. Grant Owner role to the service account (see command above)
2. Run `terraform apply` again
3. Wait for resources to be created (~5-10 minutes)
4. Configure secrets using `./scripts/setup-secrets.sh`
5. Deploy Ghost application
