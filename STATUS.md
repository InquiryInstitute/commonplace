# Setup Status

## ✅ Completed

1. **GitHub Repository Created**
   - Repository: https://github.com/InquiryInstitute/commonplace
   - All code committed and pushed to `main` branch

2. **GCP APIs Partially Enabled**
   - ✅ SQL Admin API enabled
   - ✅ IAM API enabled
   - ⚠️ Other APIs require billing to be enabled

3. **Project Structure**
   - All configuration files created
   - Terraform infrastructure code ready
   - CI/CD workflows configured
   - Setup scripts created and executable

## ⚠️ Requires Action

### 1. Enable GCP Billing
The following APIs require billing to be enabled:
- Cloud Run API
- Secret Manager API
- VPC Access API
- Cloud Build API
- Compute Engine API

**Action**: Enable billing for project `naphome-korvo1` in GCP Console, then re-run:
```bash
export GCP_PROJECT_ID=naphome-korvo1
./scripts/enable-gcp-apis.sh
```

### 2. Configure Terraform Variables
Create `terraform/terraform.tfvars`:
```hcl
gcp_project_id = "naphome-korvo1"
gcp_region     = "us-central1"
aws_region     = "us-east-1"
db_password    = "your-secure-database-password"
```

### 3. Configure AWS Credentials
Ensure AWS CLI is configured with Route 53 permissions:
```bash
aws configure
# Or set environment variables:
# export AWS_ACCESS_KEY_ID=...
# export AWS_SECRET_ACCESS_KEY=...
```

### 4. Deploy Infrastructure
After billing is enabled:
```bash
cd terraform
terraform plan
terraform apply
```

### 5. Configure Secrets
```bash
# Create GCS service account
./scripts/create-gcs-service-account.sh

# Setup all secrets
./scripts/setup-secrets.sh
```

### 6. Configure GitHub Secrets
Add the following secrets in GitHub repository settings:
- `GCP_PROJECT_ID`: naphome-korvo1
- `GCP_SA_KEY`: Service account JSON key (create with script below)
- `CLOUDSQL_CONNECTION_NAME`: (from Terraform output)
- `VPC_CONNECTOR`: (from Terraform output)
- `GCS_BUCKET`: (from Terraform output)
- `SERVICE_ACCOUNT`: (from Terraform output)
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `DB_PASSWORD`: Database password

### 7. Create GitHub Actions Service Account
```bash
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions Service Account" \
  --project=naphome-korvo1

gcloud projects add-iam-policy-binding naphome-korvo1 \
  --member="serviceAccount:github-actions@naphome-korvo1.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.editor"

gcloud projects add-iam-policy-binding naphome-korvo1 \
  --member="serviceAccount:github-actions@naphome-korvo1.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding naphome-korvo1 \
  --member="serviceAccount:github-actions@naphome-korvo1.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding naphome-korvo1 \
  --member="serviceAccount:github-actions@naphome-korvo1.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=github-actions@naphome-korvo1.iam.gserviceaccount.com \
  --project=naphome-korvo1

# Copy the contents of github-actions-key.json to GitHub secret GCP_SA_KEY
cat github-actions-key.json
```

### 8. Update Domain Name Servers
After Terraform creates the Route 53 hosted zone:
```bash
cd terraform
terraform output route53_name_servers
```
Update your domain registrar (`inquiry.institute`) with these name servers.

### 9. Deploy Ghost
Either:
- Push to `main` branch (triggers GitHub Actions)
- Or manually: `gcloud builds submit --config cloudbuild.yaml`

### 10. Update DNS Record
After Cloud Run is deployed:
```bash
CLOUD_RUN_URL=$(gcloud run services describe ghost --region=us-central1 --format="value(status.url)")
./scripts/setup-dns.sh $CLOUD_RUN_URL
```

## Current Project Configuration

- **GCP Project**: naphome-korvo1
- **GitHub Repo**: https://github.com/InquiryInstitute/commonplace
- **Domain**: commonplace.inquiry.institute

## Next Immediate Steps

1. Enable billing in GCP Console
2. Re-run `./scripts/enable-gcp-apis.sh`
3. Configure `terraform/terraform.tfvars`
4. Run `terraform apply` in the terraform directory

See `SETUP.md` for detailed instructions.
