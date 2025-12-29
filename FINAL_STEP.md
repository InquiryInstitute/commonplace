# Final Step - Run This in Your Terminal

## ⚠️ Interactive Authentication Required

The final step requires **interactive browser authentication** that cannot be done automatically.

## Quick Command

Run this single command in your terminal:

```bash
cd /Users/danielmcshan/GitHub/commonplace && gcloud auth login custodian@inquiry.institute && gcloud config set project institute-481516 && ./QUICK_SETUP.sh
```

Or run the automated script:

```bash
cd /Users/danielmcshan/GitHub/commonplace
./RUN_THIS.sh
```

## What Will Happen

1. **Browser opens** for Google authentication
2. **Sign in** with `custodian@inquiry.institute`
3. **Script creates** service account key
4. **Script sets** `GCP_SA_KEY` GitHub secret
5. **Done!** All 6 secrets configured

## Verify

After running, verify all secrets:

```bash
gh secret list
```

Should show:
- ✅ GCP_PROJECT_ID
- ✅ GCP_SA_KEY
- ✅ CLOUDSQL_CONNECTION_NAME
- ✅ VPC_CONNECTOR
- ✅ GCS_BUCKET
- ✅ SERVICE_ACCOUNT

## Then Deploy

Once all secrets are set:

```bash
# Trigger deployment
git push origin main

# Or manually
gh workflow run "Deploy Ghost to Google Cloud"

# Monitor
gh run watch
```

## Current Status

✅ **5/6 secrets configured** (83% complete)
⏳ **1 remaining**: GCP_SA_KEY (needs interactive auth)

**Time to complete**: ~2 minutes
