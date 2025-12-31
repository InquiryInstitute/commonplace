# Fix Ghost Theme Issue

## Problem

The frontend shows: **"The currently active theme 'source' is missing."**

This happens because the database references a theme that doesn't exist in the filesystem.

## Quick Fix (Easiest - Do This First!)

Since you're logged into Ghost admin:

1. **Go to Settings → Design**:
   - Visit: https://commonplace.inquiry.institute/ghost
   - Click **Settings** (gear icon)
   - Click **Design** in the sidebar

2. **Change Active Theme**:
   - You should see "Casper" theme available (Ghost's default)
   - Click **Activate** on Casper theme
   - Click **Save** at the top

3. **Verify**:
   - Visit: https://commonplace.inquiry.institute/
   - Should now load without 500 error!

## Alternative: Via API

If you have a Ghost Admin API key:

```bash
./scripts/fix-theme.sh
```

Or manually:

```bash
curl -X PUT "https://commonplace.inquiry.institute/ghost/api/admin/settings/" \
  -H "Authorization: Ghost YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "settings": [
      {
        "key": "active_theme",
        "value": "casper"
      }
    ]
  }'
```

## Why This Happened

When we reset the database earlier, Ghost may have set a theme reference that doesn't match the actual theme files. The default Ghost theme is "Casper" and should be available.

## After Fixing

The site should work normally. You can:
- View the frontend at https://commonplace.inquiry.institute/
- Access admin at https://commonplace.inquiry.institute/ghost
- Install additional themes from Settings → Design → Change theme
