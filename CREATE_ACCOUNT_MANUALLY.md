# Create a.locke Account Manually

## Quick Steps

Since the API key has limited permissions, create the account via Ghost admin:

### 1. Go to Ghost Admin

Visit: https://commonplace.inquiry.institute/ghost

### 2. Create User

1. Click **Settings** (gear icon)
2. Click **Staff** in the sidebar
3. Click **"Invite people"** or **"Add user"**
4. Enter:
   - **Email**: `a.locke@inquiry.institute`
   - **Name**: John Locke
   - **Role**: Author
   - **Name**: John Locke
   - **Bio**: "Empiricist philosopher. Content generated in the persona of John Locke using AI."

5. Click **"Send invitation"** or **"Add user"**

### 3. After Account Created

Once the account exists, we can publish the essay using the API.

## Alternative: Use Existing Admin Account

If you prefer, we can publish the essay under your admin account and tag it with `faculty-locke` for attribution.

## Next Steps

After the account is created, run:
```bash
python3 publish-locke-essay.py
```

Or use the MCP tool to publish the essay.
