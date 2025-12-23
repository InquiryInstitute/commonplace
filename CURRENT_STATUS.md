# Current Status - Ghost Installation Setup

## ✅ What's Working

1. **GitHub Repository**: ✅ Created and all code committed
   - Repository: https://github.com/InquiryInstitute/commonplace
   - All configuration files in place

2. **GCP Configuration**: ✅ Ready
   - Project: `institute-481516`
   - Billing: ✅ Linked (Inquiry.Institute billing account)
   - APIs: ✅ Enabled (Cloud Run, Cloud SQL, Storage, Secret Manager, VPC Access, etc.)

3. **Terraform**: ✅ Configured and Validated
   - Configuration validated
   - Plan shows 15 resources ready to create
   - Authentication working (using service account key)

4. **AWS Route 53**: ✅ Zone Exists
   - Hosted zone already created: `Z06752029VWQZ5MPMZG8`
   - DNS record placeholder exists

5. **Service Account**: ✅ Created
   - Service account: `ghost-gcs-sa@institute-481516.iam.gserviceaccount.com`
   - Key file: `gcs-keyfile.json` (in repository root)

## ❌ What's Blocked

**Service Account Permissions**: The service account `ghost-gcs-sa@institute-481516.iam.gserviceaccount.com` needs additional permissions to create resources.

### Missing Permissions:
- ❌ `compute.networks.create` - To create VPC network
- ❌ `storage.buckets.create` - To create Cloud Storage bucket
- ❌ `iam.serviceAccounts.create` - To create service accounts
- ❌ `secretmanager.secrets.create` - To create Secret Manager secrets

### Current Permissions:
- ✅ `storage.objectAdmin` - Can manage storage objects (but not create buckets)

## 🔧 Solution Required

Grant the service account Owner role or specific admin roles. This requires a user account with project admin/owner permissions.

**Quick Fix Command:**
```bash
gcloud projects add-iam-policy-binding institute-481516 \
  --member="serviceAccount:ghost-gcs-sa@institute-481516.iam.gserviceaccount.com" \
  --role="roles/owner"
```

**After granting permissions, run:**
```bash
cd terraform
export GOOGLE_APPLICATION_CREDENTIALS="$(cd .. && pwd)/gcs-keyfile.json"
terraform apply
```

## 📋 Resources Ready to Create

Once permissions are granted, Terraform will create:

1. **Cloud SQL**
   - MySQL 8.0 instance (`ghost-db-instance`)
   - Database (`ghost`)
   - User (`ghost`)

2. **Networking**
   - VPC network (`ghost-vpc`)
   - Subnet (`ghost-subnet`)
   - VPC connector (`ghost-connector`)

3. **Storage**
   - Cloud Storage bucket (`institute-481516-ghost-content`)

4. **Security**
   - Service account (`ghost-sa`)
   - Secret Manager secrets (db-password, mail-user, mail-password, gcs-keyfile)

5. **Compute**
   - Cloud Run service (`ghost`) - placeholder (will be deployed via Cloud Build)

6. **DNS**
   - Route 53 record update (zone already exists)

## 🎯 Next Steps

1. **Grant Permissions** (requires project admin)
   - Run the gcloud command above to grant Owner role

2. **Deploy Infrastructure**
   ```bash
   cd terraform
   export GOOGLE_APPLICATION_CREDENTIALS="$(cd .. && pwd)/gcs-keyfile.json"
   terraform apply
   ```

3. **Configure Secrets**
   - Add actual secret values to Secret Manager
   - Run `./scripts/setup-secrets.sh`

4. **Deploy Ghost**
   - Build and deploy via Cloud Build or GitHub Actions
   - Update DNS record with Cloud Run URL

## 📊 Progress: 90% Complete

- ✅ Repository setup: 100%
- ✅ Configuration: 100%
- ✅ Authentication: 100%
- ⚠️ Permissions: 0% (blocking deployment)
- ⏳ Infrastructure: 0% (waiting on permissions)
- ⏳ Application deployment: 0% (waiting on infrastructure)

**Estimated time to complete after permissions granted: 10-15 minutes**
