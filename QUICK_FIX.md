# Quick Fix: Grant Permissions

## The Issue
The service account needs Owner role to create infrastructure resources.

## One-Line Fix

Run this command (requires authenticated user with project admin):

```bash
gcloud projects add-iam-policy-binding naphome-korvo1 \
  --member="serviceAccount:ghost-gcs-sa@naphome-korvo1.iam.gserviceaccount.com" \
  --role="roles/owner"
```

## If You Need to Authenticate First

```bash
# Authenticate
gcloud auth login

# Set project
gcloud config set project naphome-korvo1

# Grant permissions
gcloud projects add-iam-policy-binding naphome-korvo1 \
  --member="serviceAccount:ghost-gcs-sa@naphome-korvo1.iam.gserviceaccount.com" \
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
