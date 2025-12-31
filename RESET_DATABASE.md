# Reset Database to Fix Theme Issue

## Problem

Ghost is showing "We'll be right back" because the theme "source" is missing. The database was partially initialized but the theme files don't exist.

## Solution: Reset Database

Run these commands to reset the database and let Ghost start fresh:

```bash
# 1. Delete the existing database
gcloud sql databases delete ghost \
  --instance=ghost-db-instance \
  --project=institute-481516 \
  --quiet

# 2. Recreate the database
gcloud sql databases create ghost \
  --instance=ghost-db-instance \
  --charset=utf8mb4 \
  --collation=utf8mb4_unicode_ci \
  --project=institute-481516

# 3. Restart Cloud Run service to trigger fresh initialization
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

## What This Does

1. **Deletes the database** - Removes all existing data including the broken theme reference
2. **Creates fresh database** - New empty database for Ghost to initialize
3. **Restarts service** - Forces Ghost to run migrations and install default theme

## After Reset

Ghost will:
- ✅ Run database migrations
- ✅ Install default theme
- ✅ Be ready for initial setup
- ✅ Show setup page at `/ghost`

## Alternative: Manual Database Fix

If you prefer not to reset, you can manually fix the database:

```bash
gcloud sql connect ghost-db-instance --user=ghost --database=ghost --project=institute-481516

# In MySQL:
UPDATE settings SET value = NULL WHERE key = 'active_theme';
# Or:
DELETE FROM settings WHERE key = 'active_theme';
EXIT;
```

Then restart the service.

## Expected Result

After reset and restart:
- Ghost completes initialization
- Default theme installed
- Setup page accessible
- Site ready for configuration
