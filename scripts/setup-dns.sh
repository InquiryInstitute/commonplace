#!/bin/bash

# Script to update Route 53 DNS record with Cloud Run URL
# Usage: ./scripts/setup-dns.sh <cloud-run-url>

set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/setup-dns.sh <cloud-run-url>"
    echo "Example: ./scripts/setup-dns.sh https://ghost-abc123-uc.a.run.app"
    exit 1
fi

CLOUD_RUN_URL=$1
# Extract hostname from URL (remove https://)
CLOUD_RUN_HOST=$(echo $CLOUD_RUN_URL | sed 's|https\?://||' | sed 's|/.*||')

ZONE_NAME="inquiry.institute"
RECORD_NAME="commonplace.inquiry.institute"

echo "Updating Route 53 DNS record..."
echo "Zone: $ZONE_NAME"
echo "Record: $RECORD_NAME"
echo "Target: $CLOUD_RUN_HOST"

# Get the hosted zone ID
ZONE_ID=$(aws route53 list-hosted-zones-by-name \
    --dns-name $ZONE_NAME \
    --query "HostedZones[0].Id" \
    --output text | sed 's|/hostedzone/||')

if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" == "None" ]; then
    echo "Error: Could not find hosted zone for $ZONE_NAME"
    echo "Please create the hosted zone first using Terraform"
    exit 1
fi

echo "Found zone ID: $ZONE_ID"

# Create or update the CNAME record
CHANGE_BATCH=$(cat <<EOF
{
    "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "$RECORD_NAME",
            "Type": "CNAME",
            "TTL": 300,
            "ResourceRecords": [{"Value": "$CLOUD_RUN_HOST"}]
        }
    }]
}
EOF
)

CHANGE_ID=$(aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch "$CHANGE_BATCH" \
    --query "ChangeInfo.Id" \
    --output text | sed 's|/change/||')

echo "DNS record update initiated. Change ID: $CHANGE_ID"
echo ""
echo "Note: DNS changes may take a few minutes to propagate."
echo "You can check the status with:"
echo "  aws route53 get-change --id $CHANGE_ID"
