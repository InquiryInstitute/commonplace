# Configuration Status

**Last Updated**: 2025-12-29

## GitHub Secrets Status

✅ **Configured** (5/6):
- ✅ `GCP_PROJECT_ID`: `institute-481516`
- ✅ `CLOUDSQL_CONNECTION_NAME`: `institute-481516:us-central1:ghost-db-instance`
- ✅ `VPC_CONNECTOR`: `projects/institute-481516/locations/us-central1/connectors/ghost-connector`
- ✅ `GCS_BUCKET`: `institute-481516-ghost-content`
- ✅ `SERVICE_ACCOUNT`: `ghost-sa@institute-481516.iam.gserviceaccount.com`

⏳ **Pending** (1/6):
- ⏳ `GCP_SA_KEY`: Requires creating service account key (needs gcloud auth)

## gcloud Configuration

**Project**: `institute-481516` ✅

**Authentication**: ⚠️ **Expired** - Needs re-authentication

To re-authenticate:
```bash
gcloud auth login custodian@inquiry.institute
gcloud config set project institute-481516
```

## Complete the Setup

### Step 1: Re-authenticate gcloud
```bash
gcloud auth login custodian@inquiry.institute
gcloud config set project institute-481516
```

### Step 2: Create Service Account Key and Set Secret
```bash
./scripts/create-sa-key-and-set-secret.sh
```

Or manually:
```bash
# Create key
gcloud iam service-accounts keys create /tmp/ghost-sa-key.json \
  --iam-account=ghost-sa@institute-481516.iam.gserviceaccount.com \
  --project=institute-481516

# Set GitHub secret
gh secret set GCP_SA_KEY < /tmp/ghost-sa-key.json

# Clean up (optional)
rm /tmp/ghost-sa-key.json
```

### Step 3: Verify All Secrets
```bash
gh secret list
```

Should show all 6 secrets.

## Next Steps After Configuration

1. **Trigger Deployment**:
   ```bash
   # Option A: Push to main
   git push origin main
   
   # Option B: Manually trigger workflow
   gh workflow run "Deploy Ghost to Google Cloud"
   ```

2. **Monitor Deployment**:
   ```bash
   gh run watch
   ```

3. **Check Service Status**:
   ```bash
   ./scripts/check-ghost-logs.sh
   ```

## Service Account Permissions

The service account needs these roles:
- `roles/run.admin` - Deploy to Cloud Run
- `roles/cloudbuild.builds.editor` - Submit Cloud Build jobs
- `roles/storage.admin` - Access GCS bucket
- `roles/secretmanager.secretAccessor` - Access secrets
- `roles/cloudsql.client` - Connect to Cloud SQL

To check permissions:
```bash
gcloud projects get-iam-policy institute-481516 \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:ghost-sa@institute-481516.iam.gserviceaccount.com" \
  --format="table(bindings.role)"
```

## Files Created

- ✅ `scripts/create-sa-key-and-set-secret.sh` - Create SA key and set secret
- ✅ `scripts/setup-github-secrets.sh` - Complete setup script
- ✅ `CONFIGURE_SECRETS.md` - Detailed configuration guide
- ✅ `CONFIGURATION_STATUS.md` - This status document

## Summary

**Progress**: 83% complete (5/6 secrets configured)

**Remaining**: 
1. Re-authenticate gcloud
2. Create service account key
3. Set `GCP_SA_KEY` secret
4. Trigger deployment

Once `GCP_SA_KEY` is set, the GitHub Actions workflow should be able to deploy successfully!
