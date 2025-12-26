# Organization Policy Update

## Current Situation

The organization policy `constraints/iam.allowedPolicyMemberDomains` is blocking public access (`allUsers`) to Cloud Run services.

## Permission Issue

The current user (`custodian@inquiry.institute`) does **not** have permission to modify organization policies. This requires:
- **Organization Admin** role, or
- **Organization Policy Admin** role

## Required Permissions

To update the organization policy, you need one of these roles:
- `roles/resourcemanager.organizationAdmin`
- `roles/orgpolicy.policyAdmin`
- `roles/resourcemanager.projectIamAdmin` (may work for project-level policies)

## How to Update the Policy

### Option 1: Using GCP Console (Recommended)

1. Go to: https://console.cloud.google.com/iam-admin/org-policies
2. Select organization: `inquiry.institute` (ID: 82170808256)
3. Find constraint: `iam.allowedPolicyMemberDomains`
4. Click "Edit"
5. Set to: **Allow all domains**
6. Save

### Option 2: Using gcloud (Requires Org Admin)

```bash
# Create policy file
cat > /tmp/policy.yaml << 'EOF'
spec:
  rules:
  - allowAll: true
EOF

# Set the policy (requires org admin)
gcloud resource-manager org-policies set-policy /tmp/policy.yaml \
  --project=institute-481516 \
  --constraint=constraints/iam.allowedPolicyMemberDomains
```

### Option 3: Grant Required Permissions

If you have organization admin access, grant the policy admin role:

```bash
ORG_ID=82170808256
gcloud organizations add-iam-policy-binding $ORG_ID \
  --member="user:custodian@inquiry.institute" \
  --role="roles/orgpolicy.policyAdmin"
```

## Alternative: Work Around the Policy

If you cannot modify the organization policy, you can:

1. **Grant access to specific users/groups** instead of `allUsers`
2. **Use Identity-Aware Proxy (IAP)** for controlled access
3. **Use a service account** for programmatic access

### Grant Access to Specific Users

```bash
# Grant to individual users
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="user:email@example.com" \
  --role="roles/run.invoker" \
  --project=institute-481516

# Grant to a Google Group
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="group:group@example.com" \
  --role="roles/run.invoker" \
  --project=institute-481516
```

## Current Status

- ✅ Infrastructure: Deployed and running
- ✅ DNS: Resolving correctly
- ❌ Public Access: Blocked by organization policy
- ⚠️ Policy Update: Requires organization admin permissions

## Next Steps

1. **Contact your GCP organization admin** to update the policy
2. **OR** grant access to specific users/groups instead of public access
3. **OR** set up IAP for controlled access

Once the policy is updated or access is granted, `https://commonplace.inquiry.institute` will be accessible.
