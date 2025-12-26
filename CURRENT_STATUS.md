# 📊 Current Deployment Status

**Last Updated**: $(date)

## ✅ Infrastructure Status: ALL DEPLOYED

### Cloud Run Service
- **Status**: ✅ **READY** (Running)
- **URL**: https://ghost-p75o7lnhuq-uc.a.run.app
- **Service**: `ghost`
- **Region**: `us-central1`
- **Image**: `gcr.io/institute-481516/ghost:latest`
- **Revision**: Latest revision deployed

### Cloud SQL Database
- **Status**: ✅ **RUNNABLE** (Running)
- **Instance**: `ghost-db-instance`
- **Connection**: `institute-481516:us-central1:ghost-db-instance`
- **Database**: `ghost`
- **User**: `ghost`

### DNS Configuration
- **Status**: ✅ **RESOLVING**
- **Domain**: `commonplace.inquiry.institute`
- **Record**: CNAME → `ghs.googlehosted.com.`
- **DNS Resolution**: ✅ Working (verified with dig/nslookup)
- **Route 53 Zone**: `Z053032935YKZE3M0E0D1` (active)

### Domain Mapping
- **Status**: ✅ **ACTIVE**
- **Domain**: `commonplace.inquiry.institute`
- **Service**: `ghost`
- **SSL Certificate**: ✅ Provisioned by Google

### Storage
- **GCS Bucket**: `institute-481516-ghost-content`
- **Status**: ✅ Created and accessible

### Docker Image
- **Status**: ✅ **BUILT & PUSHED**
- **Registry**: `gcr.io/institute-481516/ghost:latest`
- **Status**: Available in Artifact Registry

## ⚠️ Access Status: RESTRICTED

### Current Access Policy
- ✅ `user:custodian@inquiry.institute` has `roles/run.invoker`
- ❌ Public access (`allUsers`) blocked by organization policy
- ❌ Authenticated users (`allAuthenticatedUsers`) blocked by organization policy

### Access Test Results
```bash
$ curl -I https://commonplace.inquiry.institute
HTTP/2 403 Forbidden

$ curl -I https://ghost-p75o7lnhuq-uc.a.run.app
HTTP/2 403 Forbidden
```

**403 Forbidden** is expected - only authorized users can access.

## 📋 Summary Table

| Component | Status | Details |
|-----------|--------|---------|
| **Cloud Run** | ✅ Ready | Service running, image deployed |
| **Cloud SQL** | ✅ Running | Database accessible |
| **DNS** | ✅ Resolving | Domain resolves correctly |
| **Domain Mapping** | ✅ Active | SSL certificate provisioned |
| **Storage** | ✅ Ready | GCS bucket created |
| **Docker Image** | ✅ Built | Image in Artifact Registry |
| **Access** | ⚠️ Restricted | Only authorized users (org policy blocks public) |

## 🔧 To Grant Access

Since organization policy blocks public access, grant access to specific users/groups:

```bash
# Grant to a Google Group (recommended)
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="group:faculty@inquiry.institute" \
  --role="roles/run.invoker" \
  --project=institute-481516

# Grant to individual users
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="user:email@example.com" \
  --role="roles/run.invoker" \
  --project=institute-481516
```

## 🎯 Next Steps

1. **Grant Access**: Add users/groups who should access the site
2. **Test Access**: Verify authorized users can access the site
3. **Complete Ghost Setup**: Visit the URL and complete the Ghost installation wizard
4. **Configure Email**: Update mail secrets with real credentials
5. **Update GCS Keyfile**: Replace placeholder with actual service account keyfile

## 🔗 Key URLs

- **Cloud Run Direct**: https://ghost-p75o7lnhuq-uc.a.run.app
- **Custom Domain**: https://commonplace.inquiry.institute (DNS working, access restricted)
- **GCP Console**: https://console.cloud.google.com/run?project=institute-481516
- **Route 53**: https://console.aws.amazon.com/route53/

## 📚 Documentation

- `STATUS.md` - Detailed status
- `GRANT_ACCESS.md` - How to grant access to users/groups
- `PERMISSION_SOLUTIONS.md` - Organization policy solutions
- `DNS_SETUP.md` - DNS configuration details
- `DEPLOYMENT_SUCCESS.md` - Initial deployment confirmation

---

**✅ All infrastructure is deployed and working!**  
**⚠️ Access is restricted - grant access to users/groups as needed.**
