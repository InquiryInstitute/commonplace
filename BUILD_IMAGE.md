# Build Ghost Docker Image

## Current Status

Infrastructure is complete, but the Ghost Docker image needs to be built and pushed to Google Container Registry.

## Quick Fix

Run the permission fix and build script:

```bash
./scripts/fix-build-permissions.sh
```

This will:
1. Grant Storage Admin permissions to Cloud Build service accounts
2. Build and push the Ghost Docker image to `gcr.io/institute-481516/ghost:latest`

## Manual Steps

If you prefer to do it manually:

### 1. Fix Permissions

```bash
PROJECT_ID="institute-481516"
PROJECT_NUMBER="584409871588"

# Grant Storage Admin to Cloud Build
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/storage.admin"

# Grant to Compute service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/storage.admin"
```

### 2. Build Image

```bash
cd /Users/danielmcshan/GitHub/commonplace
gcloud builds submit --tag gcr.io/institute-481516/ghost:latest
```

### 3. Complete Deployment

After the image is built, run terraform apply:

```bash
cd terraform
ACCESS_TOKEN=$(gcloud auth print-access-token)
terraform apply -auto-approve -var="gcp_access_token=$ACCESS_TOKEN"
```

## Alternative: Build Locally with Docker

If Cloud Build continues to have issues, you can build locally:

```bash
# Build the image
docker build -t gcr.io/institute-481516/ghost:latest .

# Authenticate Docker to GCR
gcloud auth configure-docker

# Push the image
docker push gcr.io/institute-481516/ghost:latest
```

## After Image is Built

Once the image is in Container Registry:
1. Terraform will automatically use it for Cloud Run
2. Run `terraform apply` to complete the deployment
3. Cloud Run service will become active
4. Update DNS with the Cloud Run URL

## Current Blockers

- ⚠️ Cloud Build service account needs storage permissions
- ⚠️ Docker image not yet built/pushed
- ⏳ Cloud Run waiting for image

## Expected Outcome

After building the image:
- Cloud Run service will deploy successfully
- Ghost application will be accessible
- DNS can be updated to point to Cloud Run URL
