# Complete Setup - Final Step Required

## Current Status

✅ **5 out of 6 GitHub secrets configured!**
- GCP_PROJECT_ID
- CLOUDSQL_CONNECTION_NAME  
- VPC_CONNECTOR
- GCS_BUCKET
- SERVICE_ACCOUNT

⏳ **1 remaining**: `GCP_SA_KEY` (requires interactive authentication)

## Complete the Setup

The final step requires **interactive browser authentication**. Run these commands in your terminal:

### Step 1: Re-authenticate gcloud
```bash
gcloud auth login custodian@inquiry.institute
```
This will open your browser for authentication.

### Step 2: Run the setup script
```bash
cd /Users/danielmcshan/GitHub/commonplace
./scripts/create-sa-key-and-set-secret.sh
```

This will:
1. Create a service account key
2. Set it as the `GCP_SA_KEY` GitHub secret
3. Verify the secret is set

## Alternative: Manual Steps

If you prefer to do it manually:

```bash
# 1. Authenticate (opens browser)
gcloud auth login custodian@inquiry.institute
gcloud config set project institute-481516

# 2. Create service account key
gcloud iam service-accounts keys create /tmp/ghost-sa-key.json \
  --iam-account=ghost-sa@institute-481516.iam.gserviceaccount.com \
  --project=institute-481516

# 3. Set GitHub secret
gh secret set GCP_SA_KEY < /tmp/ghost-sa-key.json

# 4. Verify
gh secret list

# 5. Clean up (optional but recommended)
rm /tmp/ghost-sa-key.json
```

## Verify Complete Setup

After completing the above, verify all secrets are set:

```bash
gh secret list
```

You should see all 6 secrets:
- ✅ GCP_PROJECT_ID
- ✅ GCP_SA_KEY
- ✅ CLOUDSQL_CONNECTION_NAME
- ✅ VPC_CONNECTOR
- ✅ GCS_BUCKET
- ✅ SERVICE_ACCOUNT

## Next Steps

Once `GCP_SA_KEY` is set:

1. **Trigger deployment**:
   ```bash
   # Option A: Push to main (triggers workflow automatically)
   git add .
   git commit -m "Configure GitHub secrets"
   git push origin main
   
   # Option B: Manually trigger workflow
   gh workflow run "Deploy Ghost to Google Cloud"
   ```

2. **Monitor deployment**:
   ```bash
   gh run watch
   ```

3. **Check service status** (after deployment):
   ```bash
   ./scripts/check-ghost-logs.sh
   ```

## Troubleshooting

### "gcloud auth login" doesn't open browser
- Try: `gcloud auth login --no-launch-browser` and copy the URL manually
- Or use: `gcloud auth application-default login`

### "Failed to create service account key"
- Verify you're authenticated: `gcloud auth list`
- Check service account exists: `gcloud iam service-accounts list`
- Verify permissions: You need `roles/iam.serviceAccountKeyAdmin`

### "Failed to set GitHub secret"
- Verify GitHub CLI is authenticated: `gh auth status`
- Check repository access: `gh repo view`

## Summary

**Progress**: 83% complete (5/6 secrets)

**Action Required**: Interactive authentication to create service account key

**Time Required**: ~2 minutes

Once complete, the GitHub Actions workflow will be able to deploy successfully!
