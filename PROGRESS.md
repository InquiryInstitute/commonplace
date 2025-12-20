# Setup Progress Report

## ✅ Successfully Completed

1. **GitHub Repository**
   - ✅ Repository created: https://github.com/InquiryInstitute/commonplace
   - ✅ All code committed and pushed to `main` branch
   - ✅ GitHub Actions workflows configured

2. **Terraform Configuration**
   - ✅ Terraform initialized with Google Cloud and AWS providers
   - ✅ Configuration validated and fixed (MySQL backup settings)
   - ✅ `terraform.tfvars` created with project ID and generated database password
   - ✅ Terraform plan shows 17 resources ready to be created:
     - Cloud SQL MySQL instance
     - Cloud SQL database and user
     - VPC network and subnet
     - VPC connector
     - Cloud Storage bucket
     - Service accounts and IAM bindings
     - Secret Manager secrets (structure)
     - Cloud Run service (placeholder)
     - Route 53 hosted zone and DNS record

3. **GCP Service Account**
   - ✅ GCS service account created: `ghost-gcs-sa@naphome-korvo1.iam.gserviceaccount.com`
   - ✅ Service account keyfile created: `gcs-keyfile.json`
   - ✅ IAM permissions granted (Storage Object Admin)

4. **AWS Configuration**
   - ✅ AWS CLI configured and authenticated
   - ✅ Account: 204181332839
   - ✅ User: dan-syzygyx

5. **Project Configuration**
   - ✅ GCP Project: `naphome-korvo1`
   - ✅ GCP Region: `us-central1`
   - ✅ AWS Region: `us-east-1`
   - ✅ Database password: Generated and saved (in terraform.tfvars)

## ⚠️ Blocked - Requires Billing

The following cannot proceed until billing is enabled for GCP project `naphome-korvo1`:

1. **GCP APIs** - These require billing:
   - Cloud Run API
   - Secret Manager API
   - VPC Access API
   - Cloud Build API
   - Compute Engine API

2. **Infrastructure Deployment**
   - Cannot run `terraform apply` until APIs are enabled
   - Most resources require billing-enabled APIs

## 📋 Next Steps (After Billing is Enabled)

### 1. Enable Remaining APIs
```bash
export GCP_PROJECT_ID=naphome-korvo1
./scripts/enable-gcp-apis.sh
```

### 2. Deploy Infrastructure
```bash
cd terraform
terraform apply
```

This will create:
- Cloud SQL database
- VPC network and connector
- Cloud Storage bucket
- Secret Manager secrets
- Route 53 hosted zone

### 3. Configure Secrets
```bash
# The GCS keyfile is already created
# Now add it and other secrets to Secret Manager
./scripts/setup-secrets.sh
```

You'll need:
- Database password (already in terraform.tfvars)
- Email credentials for Ghost
- GCS keyfile (already created at `gcs-keyfile.json`)

### 4. Configure GitHub Secrets
Add these to https://github.com/InquiryInstitute/commonplace/settings/secrets/actions:

- `GCP_PROJECT_ID`: naphome-korvo1
- `GCP_SA_KEY`: (Create GitHub Actions service account - see SETUP.md)
- `CLOUDSQL_CONNECTION_NAME`: (From `terraform output` after apply)
- `VPC_CONNECTOR`: (From `terraform output` after apply)
- `GCS_BUCKET`: naphome-korvo1-ghost-content
- `SERVICE_ACCOUNT`: ghost-sa@naphome-korvo1.iam.gserviceaccount.com
- `AWS_ACCESS_KEY_ID`: (Your AWS access key)
- `AWS_SECRET_ACCESS_KEY`: (Your AWS secret key)
- `DB_PASSWORD`: (From terraform.tfvars)

### 5. Deploy Ghost
After infrastructure is deployed:
```bash
# Get Cloud Run URL from Terraform output
cd terraform
terraform output cloud_run_url

# Or deploy via GitHub Actions by pushing to main branch
```

### 6. Update DNS
```bash
CLOUD_RUN_URL=$(gcloud run services describe ghost --region=us-central1 --format="value(status.url)")
./scripts/setup-dns.sh $CLOUD_RUN_URL
```

### 7. Update Domain Name Servers
After Route 53 hosted zone is created:
```bash
cd terraform
terraform output route53_name_servers
```
Update your domain registrar (`inquiry.institute`) with these name servers.

## 📁 Important Files

- `terraform/terraform.tfvars` - Contains project configuration and database password (DO NOT COMMIT)
- `gcs-keyfile.json` - GCS service account key (DO NOT COMMIT, add to .gitignore)
- `terraform/.terraform.lock.hcl` - Provider lock file (committed)

## 🔒 Security Notes

- `terraform.tfvars` contains sensitive data and is in `.gitignore`
- `gcs-keyfile.json` contains service account credentials and should be in `.gitignore`
- These files should be stored securely and uploaded to Secret Manager

## Current Status

**Ready to deploy**: ✅ Yes (after billing is enabled)
**Blocked on**: GCP billing account
**Estimated time to complete after billing**: 15-30 minutes
