# Mailgun Setup for Ghost

## Overview

Mailgun is configured as the email service for Ghost. This provides reliable email delivery for:
- Login authentication codes
- Password resets
- User invitations
- Notification emails

## Quick Setup

### 1. Get Mailgun Account

1. **Sign up**: https://www.mailgun.com/
2. **Verify your domain** (or use sandbox domain for testing):
   - Go to Mailgun Dashboard → Sending → Domains
   - Add your domain (e.g., `inquiry.institute`)
   - Follow DNS setup instructions
   - Or use the sandbox domain for testing (limited to authorized recipients)

### 2. Get SMTP Credentials

1. **Go to Mailgun Dashboard** → Sending → Domains
2. **Select your domain** (or sandbox)
3. **Click "SMTP credentials"** or find "SMTP" section
4. **Note down**:
   - **SMTP Username**: Usually `postmaster@your-domain.com` or a specific SMTP user
   - **SMTP Password**: The password for SMTP authentication
   - **From Address**: Use a verified email like `noreply@inquiry.institute` or `ghost@inquiry.institute`

### 3. Run Setup Script

```bash
./scripts/setup-mailgun.sh
```

The script will prompt for:
- Mailgun SMTP username
- Mailgun SMTP password
- From email address

### 4. Manual Setup (Alternative)

If you prefer to set secrets manually:

```bash
# Set SMTP username
echo -n "postmaster@your-domain.com" | gcloud secrets versions add mail-user --project=institute-481516 --data-file=-

# Set SMTP password
echo -n "your-smtp-password" | gcloud secrets versions add mail-password --project=institute-481516 --data-file=-

# Set from address
echo -n "noreply@inquiry.institute" | gcloud secrets versions add mail-from --project=institute-481516 --data-file=-
```

### 5. Redeploy

After setting secrets, redeploy Ghost:

```bash
git add config.production.json Dockerfile cloudbuild.yaml .github/workflows/deploy.yml
git commit -m "Configure Mailgun for email"
git push origin main
```

Or manually trigger GitHub Actions deployment.

## Configuration Details

### Current Settings

The `config.production.json` is configured with:

```json
"mail": {
  "transport": "SMTP",
  "options": {
    "host": "smtp.mailgun.org",
    "port": 587,
    "secure": false,
    "requireTLS": true,
    "auth": {
      "user": "${MAIL_USER}",
      "pass": "${MAIL_PASSWORD}"
    },
    "from": "${MAIL_FROM}"
  }
}
```

### Environment Variables

- `MAIL_USER`: Mailgun SMTP username
- `MAIL_PASSWORD`: Mailgun SMTP password
- `MAIL_FROM`: Email address to send from (must be verified domain)

All stored in Google Secret Manager.

## Testing

After deployment:

1. **Test login**:
   - Visit https://commonplace.inquiry.institute/ghost
   - Try logging in (should receive auth code email)

2. **Check Mailgun Dashboard**:
   - Go to https://app.mailgun.com/
   - Check "Logs" for sent emails
   - Verify delivery status

3. **Check Ghost Logs**:
   ```bash
   gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=ghost" --limit=20 --project=institute-481516 | grep -i mail
   ```

## Troubleshooting

### "Failed to send email" error

1. **Verify secrets are set**:
   ```bash
   gcloud secrets versions access latest --secret=mail-user --project=institute-481516
   gcloud secrets versions access latest --secret=mail-password --project=institute-481516
   gcloud secrets versions access latest --secret=mail-from --project=institute-481516
   ```

2. **Check Mailgun domain status**:
   - Domain must be verified
   - DNS records must be correct
   - For sandbox: recipient must be authorized

3. **Check Ghost logs** for specific error messages

### "EAUTH" error

- Verify SMTP username and password are correct
- Check that credentials match Mailgun dashboard
- Ensure using SMTP credentials, not API keys

### Emails not arriving

1. **Check Mailgun logs** for delivery status
2. **Check spam folder**
3. **Verify from address** is from verified domain
4. **For sandbox domain**: Ensure recipient is authorized

## Mailgun Limits

### Free Tier
- 5,000 emails/month
- Sandbox domain (limited recipients)
- Good for testing and small sites

### Paid Plans
- Higher limits
- Custom domains
- Better deliverability
- Advanced features

## Security Notes

- SMTP credentials are stored in Google Secret Manager
- Never commit credentials to git
- Rotate passwords regularly
- Use domain verification for production

## Additional Resources

- Mailgun Documentation: https://documentation.mailgun.com/
- Ghost Email Configuration: https://ghost.org/docs/config/#mail
- Mailgun Dashboard: https://app.mailgun.com/
