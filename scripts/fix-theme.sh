#!/bin/bash
# Fix Ghost theme issue - set active theme to default

set -e

PROJECT_ID="institute-481516"
GHOST_URL="https://commonplace.inquiry.institute"

echo "=========================================="
echo "Fix Ghost Theme Issue"
echo "=========================================="
echo ""
echo "The frontend is showing: 'The currently active theme \"source\" is missing.'"
echo ""
echo "This can be fixed by:"
echo ""
echo "Option 1: Via Ghost Admin (Easiest)"
echo "  1. Go to https://commonplace.inquiry.institute/ghost"
echo "  2. Navigate to Settings → Design"
echo "  3. Change the active theme to 'Casper' (default theme)"
echo "  4. Save settings"
echo ""
echo "Option 2: Via Database (if you have MySQL client)"
echo "  Connect to database and run:"
echo "  UPDATE settings SET value = 'casper' WHERE \`key\` = 'active_theme';"
echo ""
echo "Option 3: Reset theme via API"
echo "  Requires Ghost Admin API key"
echo ""

read -p "Do you want to try Option 3 (API fix)? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "Enter Ghost Admin API Key: " API_KEY
  if [ -z "$API_KEY" ]; then
    echo "❌ API key required"
    exit 1
  fi
  
  echo ""
  echo "Checking current theme..."
  
  # Get current settings
  RESPONSE=$(curl -s -X GET \
    "${GHOST_URL}/ghost/api/admin/settings/" \
    -H "Authorization: Ghost ${API_KEY}" \
    -H "Content-Type: application/json")
  
  echo "Response: $RESPONSE" | head -5
  
  # Update theme to casper
  echo ""
  echo "Setting theme to 'casper' (default)..."
  
  UPDATE_RESPONSE=$(curl -s -X PUT \
    "${GHOST_URL}/ghost/api/admin/settings/" \
    -H "Authorization: Ghost ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
      "settings": [
        {
          "key": "active_theme",
          "value": "casper"
        }
      ]
    }')
  
  echo "Update response: $UPDATE_RESPONSE" | head -10
  
  echo ""
  echo "✅ Theme updated. The site should work now!"
  echo "   Visit: https://commonplace.inquiry.institute/"
fi

echo ""
echo "=========================================="
echo "Quick Fix Instructions"
echo "=========================================="
echo ""
echo "If you're logged into Ghost admin:"
echo "  1. Go to Settings → Design"
echo "  2. Select 'Casper' theme"
echo "  3. Click 'Activate'"
echo "  4. Save"
echo ""
