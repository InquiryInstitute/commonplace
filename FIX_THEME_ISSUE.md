# Fix "We'll be right back" - Missing Theme Issue

## Current Status

✅ **Ghost is running** - Server started successfully  
✅ **Database connected** - Using private IP 10.133.0.2  
❌ **Theme missing** - "The currently active theme 'source' is missing"  
❌ **Maintenance mode** - Showing "We'll be right back" page

## Root Cause

Ghost is in maintenance mode because it can't find the default theme "source". This typically happens when:
1. Ghost hasn't completed initial database migrations
2. The theme directory is empty or missing
3. Database was partially initialized

## Solution Options

### Option 1: Reset Database and Let Ghost Initialize Fresh (Recommended)

This will clear the database and let Ghost start from scratch:

```bash
# Connect to database and drop/recreate
gcloud sql connect ghost-db-instance --user=ghost --database=ghost --project=institute-481516

# In MySQL:
DROP DATABASE ghost;
CREATE DATABASE ghost CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

Then restart the Cloud Run service - Ghost will reinitialize and install the default theme.

### Option 2: Check Database State

Check if Ghost has completed migrations:

```bash
# Check if tables exist
gcloud sql connect ghost-db-instance --user=ghost --database=ghost --project=institute-481516
# Then run: SHOW TABLES;
```

### Option 3: Access Setup Directly

Try accessing the setup page directly in a browser:
- https://commonplace.inquiry.institute/ghost
- This should trigger Ghost to complete initialization

### Option 4: Update Config to Remove Theme Reference

If the database has a theme reference but the theme doesn't exist, we may need to:
1. Clear the theme setting from the database
2. Let Ghost use its default theme

## Quick Fix to Try

1. **Restart the service** to trigger fresh initialization:
   ```bash
   gcloud run services update ghost --region=us-central1 --project=institute-481516 --no-traffic
   sleep 10
   gcloud run services update-traffic ghost --region=us-central1 --project=institute-481516 --to-latest
   ```

2. **Wait 2-3 minutes** for Ghost to complete database migrations

3. **Check logs**:
   ```bash
   gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=ghost" --limit=20 --project=institute-481516 --format="table(timestamp,textPayload)" --freshness=5m
   ```

4. **Visit the site** - it should either show the setup page or be working

## Expected Behavior

After Ghost completes initialization:
- Database migrations complete
- Default theme installed
- Setup page accessible at `/ghost`
- Site becomes live after setup completion

## Current Configuration

- **Database**: Connected ✅
- **Storage**: LocalFileStorage ✅
- **Directories**: Created ✅
- **Theme**: Missing ❌ (needs initialization)

The "We'll be right back" page is Ghost's maintenance mode, which it exits once initialization is complete.
