#!/bin/bash
# Setup Mailgun for Ghost email

set -e

PROJECT_ID="institute-481516"

echo "=========================================="
echo "Mailgun Setup for Ghost"
echo "=========================================="
echo ""
echo "This script will help you configure Mailgun for Ghost email."
echo ""
echo "Prerequisites:"
echo "  1. Mailgun account (sign up at https://www.mailgun.com/)"
echo "  2. Verified domain in Mailgun (or use sandbox domain for testing)"
echo "  3. SMTP credentials from Mailgun dashboard"
echo ""

# Get Mailgun SMTP username
read -p "Enter Mailgun SMTP username (usually 'postmaster@your-domain.com' or 'SMTP Username' from Mailgun): " MAIL_USER
if [ -z "$MAIL_USER" ]; then
  echo "❌ SMTP username required"
  exit 1
fi

# Get Mailgun SMTP password
read -sp "Enter Mailgun SMTP password (from Mailgun dashboard): " MAIL_PASSWORD
echo ""
if [ -z "$MAIL_PASSWORD" ]; then
  echo "❌ SMTP password required"
  exit 1
fi

# Get from address
read -p "Enter 'from' email address (e.g., noreply@inquiry.institute or your verified Mailgun domain): " MAIL_FROM
if [ -z "$MAIL_FROM" ]; then
  echo "❌ From address required"
  exit 1
fi

echo ""
echo "Updating secrets in Google Secret Manager..."

# Update mail-user secret
if gcloud secrets describe mail-user --project=$PROJECT_ID &>/dev/null; then
  echo -n "$MAIL_USER" | gcloud secrets versions add mail-user --project=$PROJECT_ID --data-file=-
  echo "✅ Updated mail-user secret"
else
  echo -n "$MAIL_USER" | gcloud secrets create mail-user --project=$PROJECT_ID --data-file=-
  echo "✅ Created mail-user secret"
fi

# Update mail-password secret
if gcloud secrets describe mail-password --project=$PROJECT_ID &>/dev/null; then
  echo -n "$MAIL_PASSWORD" | gcloud secrets versions add mail-password --project=$PROJECT_ID --data-file=-
  echo "✅ Updated mail-password secret"
else
  echo -n "$MAIL_PASSWORD" | gcloud secrets create mail-password --project=$PROJECT_ID --data-file=-
  echo "✅ Created mail-password secret"
fi

# Update mail-from secret
if gcloud secrets describe mail-from --project=$PROJECT_ID &>/dev/null; then
  echo -n "$MAIL_FROM" | gcloud secrets versions add mail-from --project=$PROJECT_ID --data-file=-
  echo "✅ Updated mail-from secret"
else
  echo -n "$MAIL_FROM" | gcloud secrets create mail-from --project=$PROJECT_ID --data-file=-
  echo "✅ Created mail-from secret"
fi

echo ""
echo "=========================================="
echo "✅ Mailgun Configuration Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. The config.production.json has been updated for Mailgun"
echo ""
echo "2. Redeploy Ghost to apply changes:"
echo "   git add config.production.json Dockerfile cloudbuild.yaml"
echo "   git commit -m 'Configure Mailgun for email'"
echo "   git push origin main"
echo ""
echo "   Or manually trigger deployment via GitHub Actions"
echo ""
echo "3. After deployment, test email:"
echo "   - Try logging in at https://commonplace.inquiry.institute/ghost"
echo "   - Check Mailgun dashboard for sent emails"
echo "   - Check Ghost logs for email errors"
echo ""
echo "Mailgun Dashboard: https://app.mailgun.com/"
echo ""
