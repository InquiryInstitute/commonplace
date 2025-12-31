#!/bin/bash
# Reset Ghost database to fix theme issue
# This will delete and recreate the database, allowing Ghost to initialize fresh

set -e

PROJECT="institute-481516"
INSTANCE="ghost-db-instance"
DATABASE="ghost"
USER="ghost"

echo "=========================================="
echo "Resetting Ghost Database"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will delete all existing Ghost data!"
echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
sleep 5
echo ""

# Check authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ ERROR: Not authenticated"
    echo "   Please run: gcloud auth login"
    exit 1
fi

echo "✅ Authenticated as: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
echo ""

# Set project
gcloud config set project $PROJECT
echo "✅ Project: $PROJECT"
echo ""

# Delete database
echo "1. Deleting existing database..."
gcloud sql databases delete $DATABASE \
  --instance=$INSTANCE \
  --project=$PROJECT \
  --quiet 2>&1 || {
    echo "⚠️  Database may not exist or already deleted"
}
echo "✅ Database deleted"
echo ""

# Wait a moment
sleep 5

# Recreate database
echo "2. Creating fresh database..."
gcloud sql databases create $DATABASE \
  --instance=$INSTANCE \
  --charset=utf8mb4 \
  --collation=utf8mb4_unicode_ci \
  --project=$PROJECT 2>&1 || {
    echo "❌ Failed to create database"
    exit 1
}
echo "✅ Database created"
echo ""

# Restart Cloud Run service
echo "3. Restarting Cloud Run service..."
gcloud run services update ghost \
  --region=us-central1 \
  --project=$PROJECT \
  --no-traffic 2>&1 | tail -2

echo ""
echo "Waiting 15 seconds for new revision..."
sleep 15

gcloud run services update-traffic ghost \
  --region=us-central1 \
  --project=$PROJECT \
  --to-latest 2>&1 | tail -2

echo ""
echo "=========================================="
echo "✅ Database reset complete!"
echo "=========================================="
echo ""
echo "Ghost will now:"
echo "  1. Run database migrations"
echo "  2. Install default theme"
echo "  3. Be ready for initial setup"
echo ""
echo "Wait 2-3 minutes, then visit:"
echo "  https://commonplace.inquiry.institute/ghost"
echo ""
echo "You should see the Ghost setup page!"
echo ""
