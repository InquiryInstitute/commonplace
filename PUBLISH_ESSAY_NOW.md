# Publish Locke Essay - Current Status

## Issue

The Ghost Admin API key has limited permissions:
- ✅ Works: Reading site info (`/site/`)
- ❌ Doesn't work: Creating users (`/users/`)
- ❌ Doesn't work: Reading users list

This suggests the integration may have restricted permissions.

## Solutions

### Option 1: Create Account Manually (Fastest)

1. Go to: https://commonplace.inquiry.institute/ghost
2. Settings → Staff → Invite people
3. Create account:
   - Email: `a.locke@inquiry.institute`
   - Name: John Locke
   - Role: Author
   - Bio: "Empiricist philosopher. Content generated in the persona of John Locke using AI."

### Option 2: Check Integration Permissions

The integration might need additional permissions. Check:
- Ghost Admin → Settings → Integrations
- Your integration settings
- May need to regenerate the key or check permissions

### Option 3: Publish Under Admin Account

We can publish the essay under your admin account and tag it with `faculty-locke`. You can change the author later in Ghost admin.

## After Account is Created

Once `a.locke@inquiry.institute` exists, the essay can be published using:
- MCP tool: `write_essay_in_persona` with `auto_publish=true`
- Or manually via Ghost admin

## Essay Ready

The essay is ready in `locke-essay-response.json`:
- Title: "On the Nature and Utility of the Common‑place Book..."
- Word Count: 2,651 words
- Content: Full essay in Locke's persona
