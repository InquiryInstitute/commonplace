# Mailgun Quick Start

## Setup in 3 Steps

### 1. Get Mailgun Credentials

1. Sign up at https://www.mailgun.com/
2. Go to Dashboard → Sending → Domains
3. Use sandbox domain (for testing) or add your domain
4. Get SMTP credentials:
   - **Username**: Usually `postmaster@your-domain.com`
   - **Password**: SMTP password from Mailgun
   - **From**: Verified email like `noreply@inquiry.institute`

### 2. Run Setup Script

```bash
./scripts/setup-mailgun.sh
```

Enter your Mailgun credentials when prompted.

### 3. Deploy

```bash
git add .
git commit -m "Configure Mailgun"
git push origin main
```

Wait for GitHub Actions to deploy (2-3 minutes).

## Test

1. Visit https://commonplace.inquiry.institute/ghost
2. Try logging in
3. Check Mailgun dashboard for sent emails

## Done! ✅

Your Ghost site now uses Mailgun for reliable email delivery.
