# Grant Access to Cloud Run Service

## Current Status

- ✅ You have project owner access
- ✅ You already have access: `user:custodian@inquiry.institute`
- ❌ Organization policy blocks public access (`allUsers`)

## Solution: Grant Access to Specific Users/Groups

Since the organization policy blocks public access, grant access to specific users or Google Groups. This is actually **better** for a faculty/member site!

## Grant Access Commands

### Grant to Individual Users

```bash
# Grant to a specific user
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="user:email@example.com" \
  --role="roles/run.invoker" \
  --project=institute-481516
```

### Grant to Google Groups (Recommended)

```bash
# Grant to a faculty group
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="group:faculty@inquiry.institute" \
  --role="roles/run.invoker" \
  --project=institute-481516

# Grant to a members group
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="group:members@inquiry.institute" \
  --role="roles/run.invoker" \
  --project=institute-481516
```

### Grant to Service Accounts

```bash
# Grant to a service account
gcloud run services add-iam-policy-binding ghost \
  --region=us-central1 \
  --member="serviceAccount:sa@project.iam.gserviceaccount.com" \
  --role="roles/run.invoker" \
  --project=institute-481516
```

## View Current Access

```bash
gcloud run services get-iam-policy ghost \
  --region=us-central1 \
  --project=institute-481516
```

## Remove Access

```bash
# Remove a user
gcloud run services remove-iam-policy-binding ghost \
  --region=us-central1 \
  --member="user:email@example.com" \
  --role="roles/run.invoker" \
  --project=institute-481516
```

## Recommended Setup for Faculty/Member Site

1. **Create Google Groups** (if not already created):
   - `faculty@inquiry.institute`
   - `members@inquiry.institute`

2. **Grant access to groups:**
   ```bash
   gcloud run services add-iam-policy-binding ghost \
     --region=us-central1 \
     --member="group:faculty@inquiry.institute" \
     --role="roles/run.invoker" \
     --project=institute-481516
   
   gcloud run services add-iam-policy-binding ghost \
     --region=us-central1 \
     --member="group:members@inquiry.institute" \
     --role="roles/run.invoker" \
     --project=institute-481516
   ```

3. **Add users to groups** via Google Admin Console or Groups interface

4. **Users can then access:**
   - https://commonplace.inquiry.institute
   - https://ghost-p75o7lnhuq-uc.a.run.app

## Benefits of This Approach

✅ **Better Security**: Only authorized users can access  
✅ **Easy Management**: Add/remove users via Google Groups  
✅ **No Org Policy Changes**: Works within current constraints  
✅ **Audit Trail**: Clear who has access  
✅ **Scalable**: Easy to add more groups/users

## Test Access

After granting access, test:

```bash
# Test with authenticated user
curl -I https://commonplace.inquiry.institute

# Or open in browser while logged in as authorized user
open https://commonplace.inquiry.institute
```
