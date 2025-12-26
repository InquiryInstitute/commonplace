# DNS Setup Status

## ✅ DNS Configuration Complete

### Route 53 Record
- **Record**: `commonplace.inquiry.institute`
- **Type**: CNAME
- **Value**: `ghs.googlehosted.com.`
- **Status**: ✅ Configured correctly

### Cloud Run Domain Mapping
- **Domain**: `commonplace.inquiry.institute`
- **Service**: `ghost`
- **Region**: `us-central1`
- **Status**: ✅ Created

## ⚠️ Important: Multiple Route 53 Hosted Zones

There are **two** Route 53 hosted zones for `inquiry.institute`:
1. **Z053032935YKZE3M0E0D1** - Original zone (ACTIVE - configured at registrar)
2. **Z06752029VWQZ5MPMZG8** - Terraform-created zone (NOT active)

The DNS record has been added to the **active hosted zone** (Z053032935YKZE3M0E0D1).

### Active Route 53 Name Servers (configured at registrar):
```
ns-1532.awsdns-63.org
ns-2003.awsdns-58.co.uk
ns-65.awsdns-08.com
ns-959.awsdns-55.net
```

### To Check Current Name Servers:
```bash
dig +short NS inquiry.institute
```

### If Name Servers Don't Match:
1. Log into your domain registrar (where you registered `inquiry.institute`)
2. Update the name servers to the Route 53 name servers listed above
3. Wait 24-48 hours for full propagation

## DNS Propagation

DNS changes typically take:
- **5-15 minutes** for initial propagation
- **24-48 hours** for full global propagation

### Check DNS Propagation:
```bash
# Check with Google DNS
dig +short commonplace.inquiry.institute @8.8.8.8

# Check with Cloudflare DNS
dig +short commonplace.inquiry.institute @1.1.1.1

# Check current Route 53 record
aws route53 list-resource-record-sets --hosted-zone-id Z06752029VWQZ5MPMZG8 \
  --query "ResourceRecordSets[?Name=='commonplace.inquiry.institute.']"
```

### Expected Result:
Once DNS propagates, you should see:
```
ghs.googlehosted.com.
```

## Cloud Run Domain Mapping Status

Check the domain mapping status:
```bash
gcloud beta run domain-mappings list --region=us-central1 --project=institute-481516
```

Once DNS is correctly configured and propagated, Google will automatically provision an SSL certificate for `https://commonplace.inquiry.institute`.

## Troubleshooting

### If DNS doesn't resolve:

1. **Verify name servers are correct** at your domain registrar
2. **Wait for propagation** (can take up to 48 hours)
3. **Check Route 53 record** is correct (should point to `ghs.googlehosted.com.`)
4. **Verify domain mapping exists** in Cloud Run

### Current Status:
- ✅ Route 53 CNAME record: `commonplace.inquiry.institute` → `ghs.googlehosted.com.`
- ✅ Cloud Run domain mapping: Created
- ⏳ DNS propagation: In progress (may take 5-48 hours)
- ⏳ SSL certificate: Will be provisioned automatically once DNS propagates

## Direct Access

While waiting for DNS to propagate, you can access Ghost directly at:
**https://ghost-p75o7lnhuq-uc.a.run.app**
