# Quick Fix: Reset Database

## The Issue

Ghost is showing "We'll be right back" because the theme "source" is missing. The database needs to be reset to let Ghost initialize fresh.

## Quick Fix (2 commands)

```bash
cd /Users/danielmcshan/GitHub/commonplace
./scripts/reset-ghost-database.sh
```

This will:
1. Delete the existing database
2. Create a fresh database
3. Restart the service
4. Let Ghost initialize with default theme

## After Running

Wait 2-3 minutes, then visit:
- https://commonplace.inquiry.institute/ghost

You should see the Ghost setup page!

## What's Working

✅ All infrastructure deployed  
✅ Ghost server running  
✅ Database connected  
✅ Deployment pipeline working  
⏳ Just needs database reset to complete initialization

## Full Instructions

See `FINAL_FIX_INSTRUCTIONS.md` for complete details.
