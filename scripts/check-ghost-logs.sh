#!/bin/bash
# Script to check Ghost Cloud Run logs and diagnose 503 errors

set -e

PROJECT="institute-481516"
REGION="us-central1"
SERVICE="ghost"

echo "=========================================="
echo "Ghost Cloud Run Diagnostic Script"
echo "=========================================="
echo ""

# Check authentication
echo "1. Checking gcloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ ERROR: No active gcloud authentication found"
    echo "   Please run: gcloud auth login"
    exit 1
fi
echo "✅ Authenticated as: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
echo ""

# Set project
echo "2. Setting project..."
gcloud config set project $PROJECT
echo "✅ Project set to: $PROJECT"
echo ""

# Check service status
echo "3. Checking Cloud Run service status..."
echo "----------------------------------------"
gcloud run services describe $SERVICE \
  --region=$REGION \
  --project=$PROJECT \
  --format="yaml(status.conditions,status.latestReadyRevisionName,status.url)" 2>&1 || {
    echo "❌ ERROR: Could not describe service. Service may not exist."
    exit 1
}
echo ""

# Check revision status
echo "4. Checking latest revision status..."
echo "----------------------------------------"
LATEST_REVISION=$(gcloud run services describe $SERVICE \
  --region=$REGION \
  --project=$PROJECT \
  --format="value(status.latestReadyRevisionName)" 2>/dev/null || echo "")

if [ -n "$LATEST_REVISION" ]; then
    echo "Latest revision: $LATEST_REVISION"
    gcloud run revisions describe $LATEST_REVISION \
      --region=$REGION \
      --project=$PROJECT \
      --format="yaml(status.conditions)" 2>&1
else
    echo "⚠️  No ready revision found"
fi
echo ""

# Check environment variables
echo "5. Checking environment variables..."
echo "----------------------------------------"
gcloud run services describe $SERVICE \
  --region=$REGION \
  --project=$PROJECT \
  --format="table(spec.template.spec.containers[0].env[].name,spec.template.spec.containers[0].env[].value)" 2>&1 | head -20
echo ""

# Check recent logs
echo "6. Recent logs (last 20 entries)..."
echo "----------------------------------------"
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE" \
  --limit=20 \
  --project=$PROJECT \
  --format="table(timestamp,severity,textPayload)" \
  --freshness=1h 2>&1 || echo "⚠️  Could not retrieve logs"
echo ""

# Check error logs
echo "7. Error logs (last 10 entries)..."
echo "----------------------------------------"
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE AND severity>=ERROR" \
  --limit=10 \
  --project=$PROJECT \
  --format="table(timestamp,severity,textPayload)" \
  --freshness=24h 2>&1 || echo "⚠️  No error logs found or could not retrieve"
echo ""

# Check database connection errors
echo "8. Database connection related logs..."
echo "----------------------------------------"
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE AND (textPayload=~\"database\" OR textPayload=~\"DB_HOST\" OR textPayload=~\"ENOTFOUND\" OR textPayload=~\"connection\" OR textPayload=~\"Invalid\")" \
  --limit=15 \
  --project=$PROJECT \
  --format="table(timestamp,textPayload)" \
  --freshness=24h 2>&1 || echo "⚠️  No database-related logs found"
echo ""

# Check startup logs
echo "9. Startup and initialization logs..."
echo "----------------------------------------"
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE AND (textPayload=~\"start\" OR textPayload=~\"Ghost\" OR textPayload=~\"Starting\" OR textPayload=~\"error\" OR textPayload=~\"failed\")" \
  --limit=15 \
  --project=$PROJECT \
  --format="table(timestamp,textPayload)" \
  --freshness=1h 2>&1 || echo "⚠️  No startup logs found"
echo ""

# Check Cloud SQL instance
echo "10. Checking Cloud SQL instance status..."
echo "----------------------------------------"
gcloud sql instances describe ghost-db-instance \
  --project=$PROJECT \
  --format="yaml(state,ipAddresses[0].ipAddress,settings.ipConfiguration.privateNetwork)" 2>&1 || echo "⚠️  Could not describe Cloud SQL instance"
echo ""

# Check VPC connector
echo "11. Checking VPC connector status..."
echo "----------------------------------------"
gcloud compute networks vpc-access connectors describe ghost-connector \
  --region=$REGION \
  --project=$PROJECT \
  --format="yaml(state)" 2>&1 || echo "⚠️  Could not describe VPC connector"
echo ""

echo "=========================================="
echo "Diagnostic complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review the logs above to identify the specific error"
echo "2. Check if environment variables are set correctly"
echo "3. Verify database connectivity"
echo "4. Check if secrets are accessible"
echo ""
