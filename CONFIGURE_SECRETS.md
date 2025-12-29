# Configure GitHub Secrets and gcloud

## Status

✅ **Most secrets configured!** The following GitHub secrets have been set:
- `GCP_PROJECT_ID`: `institute-481516`
- `CLOUDSQL_CONNECTION_NAME`: `institute-481516:us-central1:ghost-db-instance`
- `VPC_CONNECTOR`: `projects/institute-481516/locations/us-central1/connectors/ghost-connector`
- `GCS_BUCKET`: `institute-481516-ghost-content`
- `SERVICE_ACCOUNT`: `ghost-sa@institute-481516.iam.gserviceaccount.com`

⏳ **Remaining**: `GCP_SA_KEY` - Requires creating a service account key

## Complete Setup

### Option 1: Automated Script (Recommended)

1. **Re-authenticate gcloud**:
   ```bash
   gcloud auth login custodian@inquiry.institute
   gcloud config set project institute-481516
   ```

2. **Run the setup script**:
   ```bash
   ./scripts/create-sa-key-and-set-secret.sh
   ```

This will:
- Create a service account key
- Set it as the `GCP_SA_KEY` GitHub secret
- Clean up the temporary key file (optional)

### Option 2: Manual Steps

1. **Re-authenticate gcloud**:
   ```bash
   gcloud auth login custodian@inquiry.institute
   gcloud config set project institute-481516
   ```

2. **Create service account key**:
   ```bash
   gcloud iam service-accounts keys create /tmp/ghost-sa-key.json \
     --iam-account=ghost-sa@institute-481516.iam.gserviceaccount.com \
     --project=institute-481516
   ```

3. **Set GitHub secret**:
   ```bash
   gh secret set GCP_SA_KEY < /tmp/ghost-sa-key.json
   ```

4. **Verify secrets**:
   ```bash
   gh secret list
   ```

5. **Clean up key file** (optional, but recommended):
   ```bash
   rm /tmp/ghost-sa-key.json
   ```

## Verify Configuration

### Check GitHub Secrets
```bash
gh secret list
```

You should see:
- ✅ GCP_PROJECT_ID
- ✅ GCP_SA_KEY
- ✅ CLOUDSQL_CONNECTION_NAME
- ✅ VPC_CONNECTOR
- ✅ GCS_BUCKET
- ✅ SERVICE_ACCOUNT

### Check gcloud Configuration
```bash
gcloud config list
gcloud auth list
```

Should show:
- Project: `institute-481516`
- Active account: `custodian@inquiry.institute` (or your account)

## Service Account Permissions

The service account (`ghost-sa@institute-481516.iam.gserviceaccount.com`) needs these roles:
- `roles/run.admin` - Deploy to Cloud Run
- `roles/cloudbuild.builds.editor` - Submit Cloud Build jobs
- `roles/storage.admin` - Access GCS bucket
- `roles/secretmanager.secretAccessor` - Access secrets
- `roles/cloudsql.client` - Connect to Cloud SQL

To verify/update permissions:
```bash
gcloud projects get-iam-policy institute-481516 \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:ghost-sa@institute-481516.iam.gserviceaccount.com"
```

## Next Steps

Once all secrets are configured:

1. **Trigger deployment**:
   - Push to `main` branch, OR
   - Manually trigger workflow in GitHub Actions

2. **Monitor deployment**:
   ```bash
   gh run watch
   ```

3. **Check service status**:
   ```bash
   ./scripts/check-ghost-logs.sh
   ```

## Troubleshooting

### "Service account key creation failed"
- Ensure you're authenticated: `gcloud auth login`
- Check service account exists: `gcloud iam service-accounts list`
- Verify permissions: You need `roles/iam.serviceAccountKeyAdmin`

### "GitHub secret set failed"
- Ensure you're authenticated to GitHub: `gh auth status`
- Check repository access: `gh repo view`

### "Workflow still failing"
- Check workflow logs: `gh run view --log`
- Verify all secrets are set: `gh secret list`
- Check service account permissions (see above)

## Files Created

- `scripts/create-sa-key-and-set-secret.sh` - Script to create SA key and set secret
- `scripts/setup-github-secrets.sh` - Complete setup script (requires auth)
- `CONFIGURE_SECRETS.md` - This documentation
