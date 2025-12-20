# Setup Guide for Commonplace Ghost Installation

This guide walks you through the complete setup process for deploying Ghost CMS to Google Cloud with AWS Route 53 DNS.

## Prerequisites Checklist

- [ ] Google Cloud Platform account with billing enabled
- [ ] AWS account with Route 53 access
- [ ] Domain `inquiry.institute` registered
- [ ] GitHub account with access to InquiryInstitute organization
- [ ] `gcloud` CLI installed and authenticated
- [ ] `aws` CLI installed and configured
- [ ] `gh` CLI installed and authenticated (for GitHub)
- [ ] `terraform` >= 1.0 installed

## Step-by-Step Setup

### 1. Enable Google Cloud APIs

```bash
export GCP_PROJECT_ID="your-gcp-project-id"
chmod +x scripts/enable-gcp-apis.sh
./scripts/enable-gcp-apis.sh
```

### 2. Create GitHub Repository

```bash
chmod +x scripts/create-github-repo.sh
./scripts/create-github-repo.sh
```

This will:
- Create the repository in the InquiryInstitute organization
- Set up the git remote
- Provide instructions for pushing code

### 3. Initialize Terraform Infrastructure

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
gcp_project_id = "your-gcp-project-id"
gcp_region     = "us-central1"
aws_region     = "us-east-1"
db_password    = "your-secure-database-password"
```

Initialize and apply Terraform:
```bash
terraform init
terraform plan
terraform apply
```

**Important**: Save the Terraform outputs:
- `cloud_sql_connection_name`
- `vpc_connector_name`
- `cloud_run_url` (will be available after first deployment)
- `route53_name_servers`

### 4. Update Domain Name Servers

After Terraform creates the Route 53 hosted zone, update your domain registrar (`inquiry.institute`) to use the name servers from the Terraform output.

You can get them with:
```bash
terraform output route53_name_servers
```

### 5. Create GCS Service Account

```bash
chmod +x scripts/create-gcs-service-account.sh
export GCP_PROJECT_ID="your-gcp-project-id"
./scripts/create-gcs-service-account.sh
```

This creates a service account and downloads a keyfile. Save this keyfile securely.

### 6. Configure Secrets

```bash
chmod +x scripts/setup-secrets.sh
export GCP_PROJECT_ID="your-gcp-project-id"
./scripts/setup-secrets.sh
```

You'll be prompted for:
- Database password (use the same one from terraform.tfvars)
- Email address for Ghost mail
- Email password/app password
- Path to the GCS keyfile from step 5

### 7. Configure GitHub Secrets

Go to your GitHub repository settings and add these secrets:

**Required Secrets:**
- `GCP_PROJECT_ID`: Your GCP project ID
- `GCP_SA_KEY`: Service account JSON key with these roles:
  - Cloud Build Service Account
  - Cloud Run Admin
  - Service Account User
  - Secret Manager Secret Accessor
- `CLOUDSQL_CONNECTION_NAME`: From Terraform output
- `VPC_CONNECTOR`: From Terraform output (format: `projects/PROJECT_ID/locations/REGION/connectors/CONNECTOR_NAME`)
- `GCS_BUCKET`: From Terraform output or `gcp-project-id-ghost-content`
- `SERVICE_ACCOUNT`: Service account email (format: `ghost-sa@PROJECT_ID.iam.gserviceaccount.com`)
- `AWS_ACCESS_KEY_ID`: AWS access key for Route 53
- `AWS_SECRET_ACCESS_KEY`: AWS secret key for Route 53
- `DB_PASSWORD`: Database password (for Terraform workflow)

### 8. Create GCP Service Account for CI/CD

Create a service account for GitHub Actions:

```bash
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions Service Account" \
  --project=$GCP_PROJECT_ID

# Grant necessary roles
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:github-actions@$GCP_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.editor"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:github-actions@$GCP_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:github-actions@$GCP_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:github-actions@$GCP_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

# Create and download key
gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=github-actions@$GCP_PROJECT_ID.iam.gserviceaccount.com \
  --project=$GCP_PROJECT_ID

# Add this JSON content to GitHub secret GCP_SA_KEY
cat github-actions-key.json
```

### 9. Initial Deployment

#### Option A: Deploy via GitHub Actions

1. Commit and push your code:
```bash
git add .
git commit -m "Initial commit: Ghost installation setup"
git push -u origin main
```

2. The GitHub Actions workflow will automatically build and deploy.

#### Option B: Manual Deployment

```bash
# Get values from Terraform
export CLOUDSQL_CONNECTION_NAME=$(cd terraform && terraform output -raw cloud_sql_connection_name)
export VPC_CONNECTOR=$(cd terraform && terraform output -raw vpc_connector_name)
export GCS_BUCKET=$(cd terraform && terraform output -raw gcs_bucket_name)
export SERVICE_ACCOUNT="ghost-sa@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

# Submit build
gcloud builds submit \
  --config cloudbuild.yaml \
  --substitutions=_GCS_BUCKET=$GCS_BUCKET,_CLOUDSQL_CONNECTION_NAME=$CLOUDSQL_CONNECTION_NAME,_VPC_CONNECTOR=$VPC_CONNECTOR,_SERVICE_ACCOUNT=$SERVICE_ACCOUNT
```

### 10. Update DNS Record

After the Cloud Run service is deployed, get its URL:

```bash
gcloud run services describe ghost --region=us-central1 --format="value(status.url)"
```

Then update the Route 53 DNS record:

```bash
chmod +x scripts/setup-dns.sh
./scripts/setup-dns.sh <cloud-run-url>
```

Or manually update via Terraform:
```bash
cd terraform
terraform apply -var="cloud_run_url=<cloud-run-url>"
```

### 11. Configure Custom Domain in Cloud Run

Map the custom domain to your Cloud Run service:

```bash
gcloud run domain-mappings create \
  --service ghost \
  --domain commonplace.inquiry.institute \
  --region us-central1
```

This will provide DNS records that need to be added to Route 53. You can also verify the domain ownership through Google Search Console.

### 12. Complete Ghost Setup

1. Visit `https://commonplace.inquiry.institute`
2. Complete the Ghost setup wizard
3. Create your admin account
4. Configure your site settings

## Verification

Verify everything is working:

```bash
# Check Cloud Run service
gcloud run services describe ghost --region=us-central1

# Check Cloud SQL instance
gcloud sql instances describe ghost-db-instance

# Check DNS
dig commonplace.inquiry.institute

# Check Route 53 records
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>
```

## Troubleshooting

### Cloud Run deployment fails

- Check Cloud Build logs: `gcloud builds list --limit=1`
- Verify all secrets exist in Secret Manager
- Check service account permissions

### Database connection errors

- Verify VPC connector is active: `gcloud compute networks vpc-access connectors describe ghost-connector --region=us-central1`
- Check Cloud SQL instance is running
- Verify connection name format

### DNS not resolving

- Verify name servers are updated at domain registrar
- Check Route 53 hosted zone records
- Allow time for DNS propagation (up to 48 hours)

### Ghost setup page not loading

- Check Cloud Run service logs: `gcloud logging read "resource.type=cloud_run_revision" --limit=50`
- Verify environment variables are set correctly
- Check database connectivity

## Next Steps

- [ ] Configure Ghost themes and content
- [ ] Set up monitoring and alerts
- [ ] Configure backup schedules
- [ ] Set up SSL certificate (handled by Cloud Run)
- [ ] Configure email settings in Ghost admin panel
- [ ] Add team members to Ghost

## Support

For issues, check:
- Cloud Run logs in GCP Console
- Cloud SQL metrics
- Route 53 health checks
- GitHub Actions workflow logs
