# Ghost "We'll be right back" - Setup Guide

## What "We'll be right back" Means

This message appears when:
1. ✅ **Ghost is starting up** (normal during initial deployment)
2. ✅ **Ghost needs initial setup** (first-time installation)
3. ⚠️ **Database connection issue** (check logs)
4. ⚠️ **Configuration issue** (check environment variables)

## Step 1: Check Service Status

```bash
gcloud run services describe ghost \
  --region=us-central1 \
  --project=institute-481516 \
  --format="value(status.conditions[0].status)"
```

Should show: `True` (Ready)

## Step 2: Check Logs

```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost" \
  --limit=50 \
  --project=institute-481516 \
  --format="table(timestamp,severity,textPayload,jsonPayload.message)"
```

Look for:
- ✅ "Ghost is running" - Service is ready
- ⚠️ Database connection errors
- ⚠️ Configuration errors
- ⚠️ Secret access errors

## Step 3: Complete Ghost Setup

Once the service is running, you need to complete the Ghost setup wizard:

1. **Visit the setup URL:**
   - https://ghost-p75o7lnhuq-uc.a.run.app/ghost
   - OR https://commonplace.inquiry.institute/ghost

2. **Complete the setup wizard:**
   - Create your admin account
   - Enter site details
   - Choose a theme

## Step 4: Common Issues

### Database Connection Issues

If you see database errors in logs:

```bash
# Check database is running
gcloud sql instances describe ghost-db-instance \
  --project=institute-481516 \
  --format="value(state)"
```

Should show: `RUNNABLE`

### Secret Access Issues

If secrets aren't accessible:

```bash
# Check service account has secret access
gcloud projects get-iam-policy institute-481516 \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:ghost-sa@institute-481516.iam.gserviceaccount.com AND bindings.role:roles/secretmanager.secretAccessor"
```

### Environment Variables

Check environment variables are set:

```bash
gcloud run services describe ghost \
  --region=us-central1 \
  --project=institute-481516 \
  --format="yaml(spec.template.spec.containers[0].env)"
```

Should show:
- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_NAME`
- `GCS_BUCKET`
- `GCP_PROJECT_ID`

## Step 5: Wait for Service to Start

Cloud Run services can take 30-60 seconds to start, especially on first request (cold start).

**Check if it's ready:**
```bash
curl -I https://ghost-p75o7lnhuq-uc.a.run.app
```

Look for `HTTP/2 200` (not 503 or 502).

## Step 6: Access Ghost Admin

Once the service is running:

1. **Go to:** https://ghost-p75o7lnhuq-uc.a.run.app/ghost
2. **Or:** https://commonplace.inquiry.institute/ghost
3. **Complete the setup wizard**

## Troubleshooting

### Service Not Starting

```bash
# Check revision status
gcloud run revisions list \
  --service=ghost \
  --region=us-central1 \
  --project=institute-481516
```

### View Detailed Logs

```bash
# Stream logs in real-time
gcloud logging tail \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost" \
  --project=institute-481516
```

### Restart Service

```bash
# Update service to trigger restart
gcloud run services update ghost \
  --region=us-central1 \
  --project=institute-481516 \
  --no-traffic
```

## Next Steps

1. ✅ Wait 1-2 minutes for service to fully start
2. ✅ Check logs for any errors
3. ✅ Visit `/ghost` to complete setup
4. ✅ Create admin account
5. ✅ Configure your site

The "We'll be right back" message should disappear once Ghost is fully started and configured.
