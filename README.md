# Commonplace - Ghost Installation for Inquiry Institute

This repository contains the infrastructure and deployment configuration for the Ghost CMS installation at `commonplace.inquiry.institute`.

## Architecture

- **Hosting**: Google Cloud Platform
  - **Cloud Run**: Containerized Ghost application
  - **Cloud SQL**: MySQL database for Ghost
  - **Cloud Storage**: Content storage (images, themes, etc.)
  - **VPC Connector**: Secure connection between Cloud Run and Cloud SQL
  - **Secret Manager**: Secure storage for sensitive credentials

- **DNS**: AWS Route 53
  - Hosted zone for `inquiry.institute`
  - CNAME record pointing to Cloud Run service

## Prerequisites

1. **Google Cloud Platform**
   - GCP project with billing enabled
   - `gcloud` CLI installed and authenticated
   - Required APIs enabled:
     - Cloud Run API
     - Cloud SQL Admin API
     - Cloud Storage API
     - Secret Manager API
     - VPC Access API
     - Cloud Build API

2. **AWS**
   - AWS account with Route 53 access
   - AWS CLI configured with appropriate credentials
   - Domain `inquiry.institute` registered

3. **Terraform** (for infrastructure setup)
   - Terraform >= 1.0 installed

4. **GitHub**
   - Repository access to InquiryInstitute organization
   - GitHub Actions secrets configured

## Setup Instructions

### 1. Initial Infrastructure Setup with Terraform

```bash
cd terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply infrastructure
terraform apply
```

This will create:
- Cloud SQL MySQL instance
- VPC network and connector
- Cloud Storage bucket
- Service accounts and IAM roles
- Route 53 hosted zone and DNS records
- Secret Manager secrets (structure)

**Important**: After Terraform creates the infrastructure, note the outputs:
- `cloud_sql_connection_name`
- `vpc_connector_name`
- `route53_name_servers` (update your domain registrar with these)

### 2. Configure Secrets

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Create GCS service account and keyfile
./scripts/create-gcs-service-account.sh

# Setup all secrets in Secret Manager
./scripts/setup-secrets.sh
```

You'll need to provide:
- Database password
- Email credentials for Ghost mail
- GCS service account keyfile

### 3. Configure GitHub Secrets

Add the following secrets to your GitHub repository:

- `GCP_PROJECT_ID`: Your GCP project ID
- `GCP_SA_KEY`: Service account JSON key with Cloud Build and Cloud Run permissions
- `CLOUDSQL_CONNECTION_NAME`: Output from Terraform
- `VPC_CONNECTOR`: Output from Terraform

### 4. Update Domain Name Servers

After Terraform creates the Route 53 hosted zone, update your domain registrar (`inquiry.institute`) to use the name servers provided in the Terraform output.

### 5. Deploy Ghost

#### Option A: Manual Deployment via Cloud Build

```bash
gcloud builds submit --config cloudbuild.yaml
```

#### Option B: Automatic Deployment via GitHub Actions

Push to the `main` branch or manually trigger the workflow from GitHub Actions.

### 6. Initial Ghost Setup

1. Visit `https://commonplace.inquiry.institute`
2. Complete the Ghost setup wizard
3. Create your admin account
4. Configure your site settings

## Project Structure

```
.
├── config.production.json    # Ghost production configuration
├── Dockerfile                # Ghost container image
├── cloudbuild.yaml          # Cloud Build configuration
├── terraform/               # Infrastructure as Code
│   ├── main.tf             # Main Terraform configuration
│   ├── variables.tf        # Variable definitions
│   ├── outputs.tf          # Output values
│   └── terraform.tfvars.example
├── scripts/                 # Setup and utility scripts
│   ├── setup-secrets.sh    # Configure Secret Manager
│   └── create-gcs-service-account.sh
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions CI/CD
└── README.md
```

## Configuration

### Environment Variables

Ghost uses the following environment variables (managed via Secret Manager):

- `DB_HOST`: Cloud SQL private IP
- `DB_PORT`: Database port (3306)
- `DB_USER`: Database user
- `DB_PASSWORD`: Database password (secret)
- `DB_NAME`: Database name
- `MAIL_USER`: Email address (secret)
- `MAIL_PASSWORD`: Email password (secret)
- `GCS_BUCKET`: Cloud Storage bucket name
- `GCP_PROJECT_ID`: GCP project ID
- `GCS_KEYFILE`: Path to GCS service account keyfile (secret)

### Custom Domain

The domain `commonplace.inquiry.institute` is configured via:
1. Route 53 CNAME record pointing to Cloud Run service
2. Cloud Run custom domain mapping (configure via GCP Console or gcloud CLI)

## Maintenance

### Database Backups

Cloud SQL automatic backups are enabled (daily at 3:00 AM). Manual backups can be created via:

```bash
gcloud sql backups create --instance=ghost-db-instance
```

### Scaling

Cloud Run automatically scales based on traffic. Configured limits:
- Min instances: 1
- Max instances: 10
- Memory: 2Gi
- CPU: 2

### Monitoring

Monitor your Ghost installation via:
- Cloud Run logs: `gcloud logging read "resource.type=cloud_run_revision"`
- Cloud SQL metrics in GCP Console
- Ghost admin panel at `https://commonplace.inquiry.institute/ghost`

## Troubleshooting

### Cloud Run service not accessible

1. Check IAM permissions: `gcloud run services get-iam-policy ghost`
2. Verify VPC connector is active
3. Check Cloud SQL connection settings

### Database connection issues

1. Verify Cloud SQL instance is running
2. Check VPC connector configuration
3. Verify database credentials in Secret Manager

### DNS not resolving

1. Verify Route 53 name servers are configured at domain registrar
2. Check CNAME record in Route 53
3. Allow time for DNS propagation (up to 48 hours)

## Security Considerations

- All secrets are stored in Google Secret Manager
- Cloud SQL uses private IP (not publicly accessible)
- VPC connector provides secure communication
- Cloud Run service account has minimal required permissions
- HTTPS is enforced via Cloud Run

## Cost Optimization

- Cloud SQL uses `db-f1-micro` tier (can be upgraded for production)
- Cloud Run scales to zero when not in use
- Cloud Storage lifecycle rules delete old versions after 30 days

## Support

For issues or questions, please contact the Inquiry Institute technical team.

## License

[Add your license here]
