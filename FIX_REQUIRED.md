# Fix Required: Grant Service Account Permissions

## Issue

The service account `ghost-gcs-sa@institute-481516.iam.gserviceaccount.com` needs additional permissions to create infrastructure resources.

## Quick Fix (Choose One Method)

### Method 1: Using gcloud CLI (Recommended)

**Prerequisites:** You must be authenticated with a user account that has Project Owner or IAM Admin permissions.

```bash
# Authenticate if needed
gcloud auth login
gcloud config set project institute-481516

# Run the permission grant script
./scripts/grant-permissions.sh
```

Or manually:
```bash
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/owner"
```

### Method 2: Using GCP Console

1. Go to: https://console.cloud.google.com/iam-admin/iam?project=institute-481516
2. Find service account: `ghost-gcs-sa@institute-481516.iam.gserviceaccount.com`
3. Click the pencil icon to edit
4. Click "ADD ANOTHER ROLE"
5. Select "Owner" role
6. Click "SAVE"

### Method 3: Grant Specific Roles (More Secure)

If you prefer not to grant Owner role, grant these specific roles:

```bash
PROJECT_ID="institute-481516"
SA="ghost-gcs-sa@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA}" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA}" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA}" \
  --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA}" \
  --role="roles/secretmanager.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA}" \
  --role="roles/cloudsql.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA}" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA}" \
  --role="roles/vpcaccess.admin"
```

## After Granting Permissions

Once permissions are granted, deploy the infrastructure:

```bash
cd terraform
export GOOGLE_APPLICATION_CREDENTIALS="$(cd .. && pwd)/gcs-keyfile.json"
terraform apply
```

## Verification

To verify permissions were granted:

```bash
gcloud projects get-iam-policy institute-481516 \
  --flatten="bindings[].members" \
  --filter="bindings.members:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --format="table(bindings.role)"
```

You should see `roles/owner` or the specific admin roles listed.

## Current Status

- ✅ All code and configuration ready
- ✅ Service account created
- ✅ Authentication working
- ❌ **BLOCKED:** Service account needs permissions
- ⏳ Waiting for permission grant to proceed

## Expected Outcome

After granting permissions and running `terraform apply`, you should see:
- 15 resources created successfully
- Infrastructure ready for Ghost deployment
- Estimated time: 5-10 minutes
