# Update Organization Policy via GCP Console

## Step-by-Step Instructions

### 1. Open Organization Policies

**Direct Link**: https://console.cloud.google.com/iam-admin/org-policies?project=institute-481516

Or navigate manually:
1. Go to: https://console.cloud.google.com
2. Select project: `institute-481516`
3. In the left menu, go to: **IAM & Admin** → **Organization Policies**

### 2. Find the Policy

1. In the search box, type: `allowedPolicyMemberDomains`
2. Or scroll to find: **IAM allowed policy member domains**
3. Click on the policy name

### 3. Edit the Policy

1. Click the **"Edit"** button (top right)
2. Select: **"Allow all domains"** or **"Allow all"**
3. Click **"Save"**

### 4. Verify the Change

After saving, the policy should show:
- **Status**: Enforced
- **Rule**: Allow all domains

### 5. Test Access

After updating the policy, run:

```bash
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="allUsers" \
  --role="roles/run.invoker" \
  --project=institute-481516
```

Then test:
```bash
curl -I https://commonplace.inquiry.institute
```

## Alternative: Update at Organization Level

If the policy is set at the organization level (not project level):

1. Go to: https://console.cloud.google.com/iam-admin/org-policies
2. At the top, select: **Organization** → `inquiry.institute`
3. Find: **IAM allowed policy member domains**
4. Click **Edit**
5. Set to: **Allow all domains**
6. Click **Save**

## Quick Links

- **Organization Policies**: https://console.cloud.google.com/iam-admin/org-policies
- **Project Policies**: https://console.cloud.google.com/iam-admin/org-policies?project=institute-481516
- **Cloud Run Service**: https://console.cloud.google.com/run?project=institute-481516

## What to Look For

The policy constraint name is:
- **Constraint**: `constraints/iam.allowedPolicyMemberDomains`
- **Display Name**: "IAM allowed policy member domains"

After updating, it should allow `allUsers` and `allAuthenticatedUsers` to be added to IAM policies.
