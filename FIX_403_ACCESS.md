# Fix 403 Forbidden Error

## Current Issue

You're getting **403 Forbidden** because:
1. Only `user:custodian@inquiry.institute` has access
2. Your browser isn't authenticated with that account, OR
3. Public access is blocked by organization policy

## Solutions

### Option 1: Access While Authenticated (Quick Fix)

**In your browser:**

1. **Sign in to Google** with `custodian@inquiry.institute`:
   - Go to: https://accounts.google.com
   - Sign in with `custodian@inquiry.institute`

2. **Then visit the site:**
   - https://ghost-p75o7lnhuq-uc.a.run.app
   - OR https://commonplace.inquiry.institute

You should now have access!

### Option 2: Grant Public Access via GCP Console

1. **Open GCP Console:**
   - https://console.cloud.google.com/run?project=institute-481516

2. **Click on the `ghost` service**

3. **Go to "Permissions" tab**

4. **Click "Grant Access"**

5. **Add principal:**
   - Principal: `allUsers`
   - Role: `Cloud Run Invoker`

6. **Click "Save"**

**Note:** This may fail if organization policy blocks it. If so, use Option 3.

### Option 3: Grant Access via gcloud (After Re-authenticating)

1. **Re-authenticate:**
   ```bash
   gcloud auth login
   ```

2. **Grant public access:**
   ```bash
   gcloud run services add-iam-policy-binding ghost \
     --region=us-central1 \
     --member="allUsers" \
     --role="roles/run.invoker" \
     --project=institute-481516
   ```

   **If that fails** (org policy blocks it), grant to authenticated users:
   ```bash
   gcloud run services add-iam-policy-binding ghost \
     --region=us-central1 \
     --member="allAuthenticatedUsers" \
     --role="roles/run.invoker" \
     --project=institute-481516
   ```

### Option 4: Grant Access to Specific Users/Groups

If organization policy blocks public access, grant to specific users:

```bash
# Re-authenticate first
gcloud auth login

# Grant to specific users
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="user:email@example.com" \
  --role="roles/run.invoker" \
  --project=institute-481516

# Grant to Google Groups
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="group:faculty@inquiry.institute" \
  --role="roles/run.invoker" \
  --project=institute-481516
```

## Quick Test

After granting access, test:

```bash
curl -I https://ghost-p75o7lnhuq-uc.a.run.app
```

You should see `HTTP/2 200` instead of `HTTP/2 403`.

## Recommended Approach

**For a faculty/member site**, Option 4 (grant to specific users/groups) is best:

1. Create Google Groups for faculty/members
2. Grant access to those groups
3. Add users to groups as needed

This provides:
- ✅ Controlled access
- ✅ Better security
- ✅ Easy user management
- ✅ Works within org policy constraints

## Current Access

To check who currently has access:

```bash
gcloud run services get-iam-policy ghost \
  --region=us-central1 \
  --project=institute-481516
```
