# Ghost Installation Investigation Summary

**Date**: 2025-12-28  
**Status**: 503 Service Unavailable  
**Domain**: commonplace.inquiry.institute

## Current Status

### ✅ Working Components
- **Infrastructure**: All deployed (Cloud SQL, VPC, Storage, DNS)
- **DNS**: Resolving correctly (`commonplace.inquiry.institute` → `ghs.googlehosted.com`)
- **Cloud Run Service**: Created and exists

### ❌ Issues Found

#### 1. **503 Service Unavailable Error**
Both URLs return 503:
- `https://commonplace.inquiry.institute` → 503
- `https://ghost-p75o7lnhuq-uc.a.run.app` → 503

This indicates the service is deployed but not responding, likely due to:
- Container crashing on startup
- Database connection failures
- Configuration errors
- Missing environment variables

#### 2. **GitHub Actions Deployment Failures**
All recent deployments have failed due to **missing GitHub secrets**:

**Error**: 
```
google-github-actions/auth failed with: the GitHub Action workflow must specify exactly one of "workload_identity_provider" or "credentials_json"! If you are specifying input values via GitHub secrets, ensure the secret is being injected into the environment.
```

**Missing Secrets**:
- `GCP_PROJECT_ID` (empty in workflow)
- `GCP_SA_KEY` (empty in workflow)

**Recent Failed Runs**:
- 20558691946 (2025-12-28 19:44:59) - Failed
- 20558650272 (2025-12-28 19:40:35) - Failed
- 20558236049 (2025-12-28 19:04:12) - Failed
- 20558213012 (2025-12-28 19:02:26) - Failed
- 20558047222 (2025-12-28 18:47:36) - Failed

## Root Cause Analysis

The 503 error is likely from an **old deployment** that's still running but broken. The service exists but the container is either:
1. Crashing on startup
2. Unable to connect to the database
3. Missing required environment variables
4. Having configuration issues

## Fixes Applied

### 1. Improved Dockerfile Startup Script
Updated `/start-ghost.sh` to:
- Explicitly list variables for `envsubst` substitution
- Add error handling with `set -e`
- Add logging for debugging

**Changes**:
```dockerfile
RUN echo '#!/bin/sh' > /start-ghost.sh && \
    echo 'set -e' >> /start-ghost.sh && \
    echo 'echo "Starting Ghost with environment variable substitution..."' >> /start-ghost.sh && \
    echo 'envsubst '"'"'$DB_HOST $DB_PORT $DB_USER $DB_PASSWORD $DB_NAME $MAIL_USER $MAIL_PASSWORD'"'"' < /var/lib/ghost/config.production.json.template > /var/lib/ghost/config.production.json' >> /start-ghost.sh && \
    echo 'echo "Configuration file generated. Starting Ghost..."' >> /start-ghost.sh && \
    echo 'exec node current/index.js' >> /start-ghost.sh && \
    chmod +x /start-ghost.sh
```

### 2. Created Diagnostic Script
Created `scripts/check-ghost-logs.sh` to help diagnose issues.

## Next Steps

### Immediate Actions Required

#### 1. Configure GitHub Secrets
Add the following secrets to the GitHub repository:
- `GCP_PROJECT_ID`: `institute-481516`
- `GCP_SA_KEY`: Service account JSON key with Cloud Build and Cloud Run permissions
- `CLOUDSQL_CONNECTION_NAME`: `institute-481516:us-central1:ghost-db-instance`
- `VPC_CONNECTOR`: `projects/institute-481516/locations/us-central1/connectors/ghost-connector`
- `SERVICE_ACCOUNT`: `ghost-sa@institute-481516.iam.gserviceaccount.com`
- `GCS_BUCKET`: `institute-481516-ghost-content`

#### 2. Re-authenticate and Check Logs
```bash
# Re-authenticate
gcloud auth login custodian@inquiry.institute
gcloud config set project institute-481516

# Run diagnostic script
./scripts/check-ghost-logs.sh
```

#### 3. Review Logs to Identify Specific Error
The diagnostic script will show:
- Service status
- Recent logs
- Error logs
- Database connection issues
- Startup problems

#### 4. Fix Identified Issues
Based on log findings, fix:
- Missing environment variables
- Database connection problems
- Configuration errors
- Secret access issues

#### 5. Redeploy
Once issues are fixed:
- Option A: Push to main branch (triggers GitHub Actions)
- Option B: Manual deployment via Cloud Build:
  ```bash
  gcloud builds submit --config cloudbuild.yaml \
    --substitutions=_GCS_BUCKET=institute-481516-ghost-content,_CLOUDSQL_CONNECTION_NAME=institute-481516:us-central1:ghost-db-instance,_VPC_CONNECTOR=projects/institute-481516/locations/us-central1/connectors/ghost-connector,_SERVICE_ACCOUNT=ghost-sa@institute-481516.iam.gserviceaccount.com
  ```

## Files Created/Modified

1. **Dockerfile** - Improved startup script with explicit variable substitution
2. **scripts/check-ghost-logs.sh** - Diagnostic script for troubleshooting
3. **INVESTIGATE_503.md** - Detailed investigation guide
4. **INVESTIGATION_SUMMARY.md** - This summary document

## Expected Outcome

After fixing GitHub secrets and redeploying:
1. ✅ GitHub Actions workflow succeeds
2. ✅ New Docker image built with improved startup script
3. ✅ Cloud Run service updated with new revision
4. ✅ Service starts successfully
5. ✅ 503 error resolved
6. ✅ Site accessible at https://commonplace.inquiry.institute

## Additional Notes

- The infrastructure is fully deployed and working
- DNS is correctly configured
- The issue is with the application deployment/configuration
- Once logs are reviewed, the specific error will be clear
- The improved Dockerfile should help with environment variable substitution issues
