# Workload Identity Federation Setup Complete! ✅

## What Was Done

Since service account key creation is blocked by organization policy, we've set up **Workload Identity Federation**, which is the recommended and more secure approach for GitHub Actions.

### ✅ Completed

1. **Workload Identity Pool Created**: `ghost-github-pool`
2. **Workload Identity Provider Created**: `ghost-github-provider`
3. **Service Account Access Granted**: `ghost-sa@institute-481516.iam.gserviceaccount.com` can now be used via Workload Identity
4. **GitHub Secret Set**: `WORKLOAD_IDENTITY_PROVIDER`
5. **GitHub Actions Workflow Updated**: Now uses Workload Identity instead of service account keys

## Configuration

### GitHub Secrets (All Set ✅)

- ✅ `GCP_PROJECT_ID`: `institute-481516`
- ✅ `WORKLOAD_IDENTITY_PROVIDER`: `projects/institute-481516/locations/global/workloadIdentityPools/ghost-github-pool/providers/ghost-github-provider`
- ✅ `SERVICE_ACCOUNT`: `ghost-sa@institute-481516.iam.gserviceaccount.com`
- ✅ `CLOUDSQL_CONNECTION_NAME`: `institute-481516:us-central1:ghost-db-instance`
- ✅ `VPC_CONNECTOR`: `projects/institute-481516/locations/us-central1/connectors/ghost-connector`
- ✅ `GCS_BUCKET`: `institute-481516-ghost-content`

**Note**: `GCP_SA_KEY` is no longer needed! Workload Identity replaces it.

## How It Works

1. GitHub Actions workflow runs
2. GitHub provides an OIDC token
3. Google authenticates the token via Workload Identity Provider
4. Workflow impersonates the service account (`ghost-sa`)
5. All GCP operations use the service account permissions

## Benefits

- ✅ **More Secure**: No long-lived service account keys
- ✅ **Organization Policy Compliant**: Works with key creation restrictions
- ✅ **Recommended by Google**: Best practice for CI/CD
- ✅ **Automatic Rotation**: Tokens are short-lived and automatically rotated

## Next Steps

### 1. Verify Secrets

```bash
gh secret list
```

Should show all 6 secrets (no `GCP_SA_KEY` needed).

### 2. Trigger Deployment

```bash
# Option A: Push to main (auto-triggers)
git add .github/workflows/deploy.yml
git commit -m "Switch to Workload Identity Federation"
git push origin main

# Option B: Manually trigger
gh workflow run "Deploy Ghost to Google Cloud"
```

### 3. Monitor Deployment

```bash
gh run watch
```

## Troubleshooting

### "Permission denied" errors

If you see permission errors, verify the service account has the required roles:

```bash
gcloud projects get-iam-policy institute-481516 \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:ghost-sa@institute-481516.iam.gserviceaccount.com" \
  --format="table(bindings.role)"
```

Required roles:
- `roles/run.admin` - Deploy to Cloud Run
- `roles/cloudbuild.builds.editor` - Submit Cloud Build jobs
- `roles/storage.admin` - Access GCS bucket
- `roles/secretmanager.secretAccessor` - Access secrets
- `roles/iam.serviceAccountUser` - Impersonate service account

### "Workload Identity Provider not found"

If the provider isn't found, verify it exists:

```bash
gcloud iam workload-identity-pools providers describe ghost-github-provider \
  --workload-identity-pool=ghost-github-pool \
  --location=global \
  --project=institute-481516
```

## Summary

✅ **All configuration complete!**

- Workload Identity Federation: ✅ Set up
- GitHub Secrets: ✅ All 6 configured
- GitHub Actions Workflow: ✅ Updated to use Workload Identity

**Ready to deploy!** Push to main or trigger the workflow manually.
