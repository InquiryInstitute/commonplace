# Quick Fix: Grant Permissions

## The Issue
The service account needs Owner role to create infrastructure resources.

## One-Line Fix

Run this command (requires authenticated user with project admin):

```bash
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/owner"
```

## If You Need to Authenticate First

```bash
# Authenticate
gcloud auth login

# Set project
gcloud config set project institute-481516

# Grant permissions
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/owner"
```

## Or Use the Script

```bash
./scripts/fix-permissions.sh
```

## Then Deploy

```bash
cd terraform
export GOOGLE_APPLICATION_CREDENTIALS="$(cd .. && pwd)/gcs-keyfile.json"
terraform apply
```

That's it! 🚀
