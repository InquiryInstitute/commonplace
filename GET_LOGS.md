# Get Cloud Run Logs via gcloud CLI

## Re-authenticate First

```bash
gcloud auth login
```

## Get Recent Logs

### All Recent Logs (Last Hour)
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost" \
  --limit=50 \
  --project=institute-481516 \
  --format=json \
  --freshness=1h
```

### Error Logs Only
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost AND severity>=ERROR" \
  --limit=30 \
  --project=institute-481516 \
  --format="table(timestamp,severity,textPayload,jsonPayload.message)" \
  --freshness=1h
```

### Database-Related Errors
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost AND textPayload=~\"database|DB_HOST|ENOTFOUND\"" \
  --limit=20 \
  --project=institute-481516 \
  --format="table(timestamp,severity,textPayload)" \
  --freshness=1h
```

### Save Logs to File
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost" \
  --limit=100 \
  --project=institute-481516 \
  --format=json \
  --freshness=1h \
  > ghost-logs-$(date +%Y%m%d-%H%M%S).json
```

### Stream Logs in Real-Time
```bash
gcloud logging tail \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost" \
  --project=institute-481516
```

## Key Log Queries

### Find Database Connection Errors
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost AND (textPayload=~\"Invalid database host\" OR textPayload=~\"ENOTFOUND\")" \
  --limit=20 \
  --project=institute-481516 \
  --format="table(timestamp,textPayload)" \
  --freshness=24h
```

### Find All Errors
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost AND severity=ERROR" \
  --limit=50 \
  --project=institute-481516 \
  --format="table(timestamp,severity,textPayload)" \
  --freshness=24h
```

### Find Startup Messages
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=ghost AND textPayload=~\"Ghost is running|Ghost server started\"" \
  --limit=20 \
  --project=institute-481516 \
  --format="table(timestamp,textPayload)" \
  --freshness=1h
```

## Based on Your Logs

From the logs you shared, the key issue is:

**Error**: `Invalid database host.`
**Error Code**: `ENOTFOUND`
**Error Message**: `getaddrinfo ENOTFOUND ${DB_HOST}`

This means the environment variable `${DB_HOST}` is not being substituted in the config file. Ghost is trying to connect to the literal string "${DB_HOST}" instead of the actual database host value.

## Fix Required

The `config.production.json` file uses `${DB_HOST}` syntax, but Ghost doesn't automatically substitute environment variables in JSON files. We need to:

1. Either use a script to substitute variables before Ghost starts
2. Or use Ghost's native environment variable support

See the fix in the next steps.
