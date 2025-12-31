# Fixing Ghost Email Configuration

## Problem

Ghost is returning 500 errors because:
1. Email configuration is missing the `from` field
2. Email credentials are set to placeholder values
3. Gmail authentication is failing (EAUTH error)

## Solution

### Option 1: Fix with Gmail (Recommended)

1. **Get Gmail App Password**:
   - Go to https://myaccount.google.com/apppasswords
   - Sign in with your Gmail account
   - Select "Mail" and "Other (Custom name)"
   - Name it "Ghost Commonplace"
   - Copy the 16-character password (no spaces)

2. **Update Email Secrets**:
   ```bash
   ./scripts/fix-email-config.sh
   ```
   
   Or manually:
   ```bash
   # Set mail user
   echo -n "your-email@gmail.com" | gcloud secrets versions add mail-user --project=institute-481516 --data-file=-
   
   # Set mail password (Gmail App Password)
   echo -n "your-16-char-app-password" | gcloud secrets versions add mail-password --project=institute-481516 --data-file=-
   ```

3. **Redeploy**:
   ```bash
   git add config.production.json
   git commit -m "Fix email configuration"
   git push origin main
   ```

### Option 2: Use SendGrid or Another SMTP Service

If you prefer not to use Gmail, update `config.production.json`:

```json
"mail": {
  "transport": "SMTP",
  "options": {
    "host": "smtp.sendgrid.net",
    "port": 587,
    "secure": false,
    "requireTLS": true,
    "auth": {
      "user": "apikey",
      "pass": "${MAIL_PASSWORD}"
    },
    "from": "${MAIL_USER}"
  }
}
```

### Option 3: Temporary Fix - Disable Email (Not Recommended)

This will allow login but disable email features:

```json
"mail": {
  "transport": "Direct",
  "options": {}
}
```

**Note**: This disables password reset emails and notifications.

## Current Status

✅ `config.production.json` has been updated with:
- `mail.from` field
- Proper Gmail SMTP settings (host, port, secure, requireTLS)

⚠️ **Action Required**: Update email secrets with real credentials and redeploy.

## Testing

After fixing and redeploying:

1. Check logs:
   ```bash
   gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=ghost" --limit=20 --project=institute-481516
   ```

2. Test login:
   - Visit https://commonplace.inquiry.institute/ghost
   - Try logging in
   - Check for email errors in logs

3. Test site:
   - Visit https://commonplace.inquiry.institute/
   - Should load without 500 errors
