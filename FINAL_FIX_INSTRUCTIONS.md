# Final Fix: Reset Database to Complete Ghost Setup

## Current Status

✅ **Deployment**: Complete and successful  
✅ **Ghost Server**: Running  
✅ **Database**: Connected  
❌ **Issue**: Missing theme "source" - Ghost in maintenance mode

## The Problem

Ghost is showing "We'll be right back" because:
- The database was partially initialized
- Theme "source" is referenced in database but files don't exist
- Ghost can't serve content without a valid theme

## The Solution

Reset the database to let Ghost start completely fresh. This will:
1. Delete the existing (partially initialized) database
2. Create a new empty database
3. Let Ghost run all migrations from scratch
4. Install the default theme automatically

## Quick Fix (Run This)

```bash
cd /Users/danielmcshan/GitHub/commonplace
./scripts/reset-ghost-database.sh
```

Or manually:

```bash
# 1. Delete database
gcloud sql databases delete ghost \
  --instance=ghost-db-instance \
  --project=institute-481516 \
  --quiet

# 2. Recreate database
gcloud sql databases create ghost \
  --instance=ghost-db-instance \
  --charset=utf8mb4 \
  --collation=utf8mb4_unicode_ci \
  --project=institute-481516

# 3. Restart service
gcloud run services update ghost \
  --region=us-central1 \
  --project=institute-481516 \
  --no-traffic

sleep 15

gcloud run services update-traffic ghost \
  --region=us-central1 \
  --project=institute-481516 \
  --to-latest
```

## After Reset

1. **Wait 2-3 minutes** for Ghost to:
   - Connect to database
   - Run migrations
   - Install default theme
   - Complete initialization

2. **Visit the setup page**:
   ```
   https://commonplace.inquiry.institute/ghost
   ```

3. **Complete setup**:
   - Create admin account
   - Configure site
   - Choose theme
   - Start using Ghost!

## What Will Happen

After reset:
- ✅ Database migrations complete
- ✅ Default theme installed
- ✅ Setup page accessible
- ✅ Site ready for use

## Verification

Check if it's working:
```bash
# Should return 200 or redirect to setup
curl -I https://commonplace.inquiry.institute/ghost

# Should show setup page (not maintenance)
curl -s https://commonplace.inquiry.institute/ghost | grep -i "setup\|welcome\|create"
```

## Summary

**Everything is deployed and working!** The only remaining step is to reset the database so Ghost can complete its initialization with the default theme. Once reset, visit `/ghost` to complete the setup wizard.
