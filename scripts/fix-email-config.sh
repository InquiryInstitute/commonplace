#!/bin/bash
# Script to fix Ghost email configuration

set -e

PROJECT_ID="institute-481516"
REGION="us-central1"
SERVICE="ghost"

echo "=========================================="
echo "Ghost Email Configuration Fix"
echo "=========================================="
echo ""

# Check if secrets exist
echo "Checking current email configuration..."
MAIL_USER=$(gcloud secrets versions access latest --secret=mail-user --project=$PROJECT_ID 2>/dev/null || echo "")
MAIL_PASSWORD_EXISTS=$(gcloud secrets describe mail-password --project=$PROJECT_ID 2>/dev/null || echo "not found")

if [ -z "$MAIL_USER" ] || [ "$MAIL_USER" == "placeholder@example.com" ] || [ "$MAIL_PASSWORD_EXISTS" == "not found" ]; then
  echo "⚠️  Email configuration needs to be set up."
  echo ""
  echo "For Gmail, you need:"
  echo "  1. A Gmail account"
  echo "  2. An App Password (not your regular password)"
  echo ""
  echo "To create a Gmail App Password:"
  echo "  1. Go to https://myaccount.google.com/apppasswords"
  echo "  2. Select 'Mail' and 'Other (Custom name)'"
  echo "  3. Name it 'Ghost Commonplace'"
  echo "  4. Copy the 16-character password"
  echo ""
  
  read -p "Enter Gmail address for sending emails: " NEW_MAIL_USER
  if [ -z "$NEW_MAIL_USER" ]; then
    echo "❌ Email address required"
    exit 1
  fi
  
  read -sp "Enter Gmail App Password (16 characters): " NEW_MAIL_PASSWORD
  echo ""
  if [ -z "$NEW_MAIL_PASSWORD" ]; then
    echo "❌ App password required"
    exit 1
  fi
  
  # Update secrets
  echo ""
  echo "Updating email secrets..."
  
  # Update mail-user
  if gcloud secrets describe mail-user --project=$PROJECT_ID &>/dev/null; then
    echo -n "$NEW_MAIL_USER" | gcloud secrets versions add mail-user --project=$PROJECT_ID --data-file=-
  else
    echo -n "$NEW_MAIL_USER" | gcloud secrets create mail-user --project=$PROJECT_ID --data-file=-
  fi
  
  # Update mail-password
  if gcloud secrets describe mail-password --project=$PROJECT_ID &>/dev/null; then
    echo -n "$NEW_MAIL_PASSWORD" | gcloud secrets versions add mail-password --project=$PROJECT_ID --data-file=-
  else
    echo -n "$NEW_MAIL_PASSWORD" | gcloud secrets create mail-password --project=$PROJECT_ID --data-file=-
  fi
  
  echo "✅ Email secrets updated"
else
  echo "✅ Email secrets already configured"
  echo "   Mail user: $MAIL_USER"
fi

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. The config.production.json has been updated with:"
echo "   - mail.from field"
echo "   - Proper Gmail SMTP settings"
echo ""
echo "2. Redeploy Ghost to apply changes:"
echo "   git add config.production.json"
echo "   git commit -m 'Fix email configuration'"
echo "   git push origin main"
echo ""
echo "   Or manually trigger deployment via GitHub Actions"
echo ""
echo "3. After deployment, test login at:"
echo "   https://commonplace.inquiry.institute/ghost"
echo ""
