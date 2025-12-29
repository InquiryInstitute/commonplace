# Investigating 503 Service Unavailable Error

## Current Status
- **URL**: https://commonplace.inquiry.institute → **503 Service Unavailable**
- **Direct URL**: https://ghost-p75o7lnhuq-uc.a.run.app → **503 Service Unavailable**
- **DNS**: ✅ Resolving correctly

## Diagnostic Steps

### 1. Re-authenticate gcloud
```bash
gcloud auth login custodian@inquiry.institute
gcloud config set project institute-481516
```

### 2. Check Service Status
```bash
gcloud run services describe ghost \
  --region=us-central1 \
  --project=institute-481516 \
  --format="yaml(status,spec.template.spec.containers[0])"
```

### 3. Check Recent Logs
```bash
# All recent logs
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost" \
  --limit=50 \
  --project=institute-481516 \
  --format="table(timestamp,severity,textPayload)" \
  --freshness=1h

# Error logs only
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost AND severity>=ERROR" \
  --limit=30 \
  --project=institute-481516 \
  --format="table(timestamp,severity,textPayload)" \
  --freshness=1h
```

### 4. Check Database Connection Issues
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost AND textPayload=~\"database|DB_HOST|ENOTFOUND|connection|Invalid\"" \
  --limit=20 \
  --project=institute-481516 \
  --format="table(timestamp,textPayload)" \
  --freshness=24h
```

### 5. Check Container Startup
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost AND textPayload=~\"start|error|failed|crash\"" \
  --limit=20 \
  --project=institute-481516 \
  --format="table(timestamp,textPayload)" \
  --freshness=1h
```

### 6. Check Revision Status
```bash
gcloud run revisions list \
  --service=ghost \
  --region=us-central1 \
  --project=institute-481516 \
  --format="table(name,status.conditions[0].status,status.conditions[0].reason)"
```

### 7. Verify Environment Variables
```bash
gcloud run services describe ghost \
  --region=us-central1 \
  --project=institute-481516 \
  --format="yaml(spec.template.spec.containers[0].env)"
```

## Potential Issues Identified

### Issue 1: Startup Script - envsubst Variable List
The current startup script uses `envsubst` without specifying which variables to substitute. This should work, but if any variables are missing, it might cause issues.

**Current script:**
```sh
envsubst < /var/lib/ghost/config.production.json.template > /var/lib/ghost/config.production.json
```

**Potential fix:** Explicitly list variables:
```sh
envsubst '$DB_HOST $DB_PORT $DB_USER $DB_PASSWORD $DB_NAME $MAIL_USER $MAIL_PASSWORD' < /var/lib/ghost/config.production.json.template > /var/lib/ghost/config.production.json
```

### Issue 2: Database Connection Method Mismatch
- **Terraform** sets `DB_HOST` to private IP address (requires VPC connector)
- **Cloud Build** sets `DB_HOST` to `127.0.0.1` (requires Cloud SQL proxy)

Both methods should work, but need to ensure:
- VPC connector is active and working
- Cloud SQL connection annotation is set correctly
- Service account has proper permissions

### Issue 3: Missing Environment Variables
Check if all required environment variables are set:
- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD` (from Secret Manager)
- `DB_NAME`
- `MAIL_USER` (from Secret Manager)
- `MAIL_PASSWORD` (from Secret Manager)

### Issue 4: Container Crash on Startup
The 503 could indicate the container is crashing immediately on startup. Check logs for:
- Startup errors
- Missing dependencies
- Permission issues
- Configuration errors

## Quick Fixes to Try

### Fix 1: Update Startup Script
Update the Dockerfile to explicitly list variables for envsubst.

### Fix 2: Add Error Handling to Startup Script
Add error checking and logging to the startup script to see what's failing.

### Fix 3: Verify Secrets Exist
```bash
gcloud secrets list --project=institute-481516
gcloud secrets versions access latest --secret=db-password --project=institute-481516
```

### Fix 4: Test Database Connection
Verify the database is accessible:
```bash
gcloud sql instances describe ghost-db-instance --project=institute-481516 --format="value(state,ipAddresses[0].ipAddress)"
```

## Next Steps

1. **Re-authenticate** and run diagnostic commands above
2. **Review logs** to identify the specific error
3. **Fix the issue** based on log findings
4. **Redeploy** if configuration changes are needed
