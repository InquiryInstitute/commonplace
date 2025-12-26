# Permission Solutions: Organization Policy Access

## ❌ Current Issue

You're getting: **"You need additional access to the organization: inquiry.institute"**

This means `custodian@inquiry.institute` doesn't have organization-level permissions to update policies.

## ✅ Solutions

### Option 1: Request Organization Admin Access

**Contact your GCP organization admin** and ask them to:

1. **Grant you organization policy admin role:**
   ```bash
   ORG_ID=82170808256
   gcloud organizations add-iam-policy-binding $ORG_ID \
     --member="user:custodian@inquiry.institute" \
     --role="roles/orgpolicy.policyAdmin"
   ```

2. **OR grant you organization admin role:**
   ```bash
   gcloud organizations add-iam-policy-binding $ORG_ID \
     --member="user:custodian@inquiry.institute" \
     --role="roles/resourcemanager.organizationAdmin"
   ```

3. **OR have them update the policy themselves** (see instructions below)

### Option 2: Work Around - Grant Access to Specific Users

Instead of public access, grant access to specific users/groups:

```bash
# Grant to yourself (already done)
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="user:custodian@inquiry.institute" \
  --role="roles/run.invoker" \
  --project=institute-481516

# Grant to specific users
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="user:email@example.com" \
  --role="roles/run.invoker" \
  --project=institute-481516

# Grant to a Google Group (recommended for multiple users)
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="group:faculty@inquiry.institute" \
  --role="roles/run.invoker" \
  --project=institute-481516
```

### Option 3: Organization Admin Updates Policy

If you have an organization admin, they can update the policy:

1. **Via GCP Console:**
   - Go to: https://console.cloud.google.com/iam-admin/org-policies
   - Select: **Organization** → `inquiry.institute`
   - Find: **IAM allowed policy member domains**
   - Click **Edit**
   - Select: **Allow all domains**
   - Click **Save**

2. **Via gcloud (if they have access):**
   ```bash
   cat > /tmp/policy.yaml << 'EOF'
   constraint: constraints/iam.allowedPolicyMemberDomains
   listPolicy:
     allValues: ALLOW
   EOF
   
   gcloud resource-manager org-policies set-policy /tmp/policy.yaml \
     --organization=82170808256
   ```

## 🔍 Check Current Permissions

To see who has organization admin access:

```bash
ORG_ID=82170808256
gcloud organizations get-iam-policy $ORG_ID \
  --flatten="bindings[].members" \
  --filter="bindings.role:roles/resourcemanager.organizationAdmin OR bindings.role:roles/orgpolicy.policyAdmin" \
  --format="table(bindings.members,bindings.role)"
```

## 📋 Recommended Approach

**For a faculty/member site**, Option 2 (grant access to specific users/groups) is often better than public access:

1. **Create a Google Group** for faculty/members (e.g., `faculty@inquiry.institute`)
2. **Grant the group access** to Cloud Run
3. **Add users to the group** as needed

This provides:
- ✅ Controlled access
- ✅ No need to modify organization policies
- ✅ Easy user management
- ✅ Better security

## 🎯 Next Steps

1. **If you have org admin access**: Update the policy via GCP Console
2. **If you don't**: 
   - Request org admin to grant you permissions, OR
   - Use Option 2 to grant access to specific users/groups

Once access is configured, `https://commonplace.inquiry.institute` will be accessible to authorized users.
