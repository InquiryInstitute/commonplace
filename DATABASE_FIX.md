# Database Connection Fix

## Problem

The logs showed:
```
Error: getaddrinfo ENOTFOUND ${DB_HOST}
Invalid database host.
```

Ghost was trying to connect to the literal string `"${DB_HOST}"` instead of the actual database host value because environment variables weren't being substituted in the JSON config file.

## Solution

Updated the Dockerfile to:
1. Install `gettext` package (provides `envsubst` command)
2. Copy `config.production.json` as a template
3. Create a startup script that uses `envsubst` to substitute environment variables before Ghost starts
4. Use the startup script as the container entrypoint

## Changes Made

### Dockerfile
- Added `gettext` package installation
- Renamed config file to `config.production.json.template`
- Created `/start-ghost.sh` script that:
  1. Substitutes environment variables using `envsubst`
  2. Starts Ghost

### How It Works

1. Container starts
2. `/start-ghost.sh` runs
3. `envsubst` reads the template and substitutes `${DB_HOST}`, `${DB_PORT}`, etc. with actual values
4. Creates final `config.production.json` with real values
5. Ghost starts with correct database configuration

## Verification

After the new image is deployed, check logs:

```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost AND textPayload=~\"Ghost is running|database\"" \
  --limit=10 \
  --project=institute-481516 \
  --format="table(timestamp,textPayload)" \
  --freshness=10m
```

You should see:
- ✅ "Ghost is running in production..."
- ✅ No "Invalid database host" errors
- ✅ Successful database connection

## Status

- ✅ Docker image rebuilt with fix
- ✅ Image pushed to Artifact Registry
- ✅ Cloud Run service updated
- ⏳ Waiting for new revision to deploy
