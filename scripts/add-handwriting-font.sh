#!/bin/bash
# Add handwriting font to Ghost theme via Code Injection

set -e

GHOST_URL="https://commonplace.inquiry.institute"
PROJECT_ID="institute-481516"

echo "=========================================="
echo "Add Handwriting Font to Commonplace"
echo "=========================================="
echo ""
echo "This will add a handwriting font to your Ghost theme."
echo "Options:"
echo "  1. Google Fonts (e.g., Kalam, Caveat, Permanent Marker)"
echo "  2. Custom font URL"
echo ""

read -p "Enter Ghost Admin API Key: " API_KEY
if [ -z "$API_KEY" ]; then
  echo "❌ API key required"
  echo ""
  echo "To get your API key:"
  echo "  1. Visit ${GHOST_URL}/ghost"
  echo "  2. Go to Settings → Integrations"
  echo "  3. Create or use existing Custom Integration"
  echo "  4. Copy the Admin API Key"
  exit 1
fi

API_BASE="${GHOST_URL}/ghost/api/admin"

echo ""
echo "Popular handwriting fonts from Google Fonts:"
echo "  1. Kalam (casual, readable)"
echo "  2. Caveat (elegant, script-like)"
echo "  3. Permanent Marker (bold, marker-style)"
echo "  4. Shadows Into Light (casual, friendly)"
echo "  5. Indie Flower (playful, rounded)"
echo "  6. Custom font URL"
echo ""

read -p "Select font (1-6): " FONT_CHOICE

case $FONT_CHOICE in
  1)
    FONT_NAME="Kalam"
    FONT_FAMILY="'Kalam', cursive"
    FONT_URL="https://fonts.googleapis.com/css2?family=Kalam:wght@300;400;700&display=swap"
    ;;
  2)
    FONT_NAME="Caveat"
    FONT_FAMILY="'Caveat', cursive"
    FONT_URL="https://fonts.googleapis.com/css2?family=Caveat:wght@400;700&display=swap"
    ;;
  3)
    FONT_NAME="Permanent Marker"
    FONT_FAMILY="'Permanent Marker', cursive"
    FONT_URL="https://fonts.googleapis.com/css2?family=Permanent+Marker&display=swap"
    ;;
  4)
    FONT_NAME="Shadows Into Light"
    FONT_FAMILY="'Shadows Into Light', cursive"
    FONT_URL="https://fonts.googleapis.com/css2?family=Shadows+Into+Light&display=swap"
    ;;
  5)
    FONT_NAME="Indie Flower"
    FONT_FAMILY="'Indie Flower', cursive"
    FONT_URL="https://fonts.googleapis.com/css2?family=Indie+Flower&display=swap"
    ;;
  6)
    read -p "Enter font name: " FONT_NAME
    read -p "Enter font family CSS (e.g., 'Font Name', cursive): " FONT_FAMILY
    read -p "Enter Google Fonts URL or custom font URL: " FONT_URL
    ;;
  *)
    echo "Invalid choice, using Kalam as default"
    FONT_NAME="Kalam"
    FONT_FAMILY="'Kalam', cursive"
    FONT_URL="https://fonts.googleapis.com/css2?family=Kalam:wght@300;400;700&display=swap"
    ;;
esac

echo ""
echo "Selected font: $FONT_NAME"
echo "Font family: $FONT_FAMILY"
echo ""

# Get current settings
echo "Fetching current settings..."
CURRENT_SETTINGS=$(curl -s -X GET \
  "${API_BASE}/settings/" \
  -H "Authorization: Ghost ${API_KEY}")

# Extract current code injection
CURRENT_HEAD=$(echo "$CURRENT_SETTINGS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('settings', {}).get('codeinjection_head', '') or '')" 2>/dev/null || echo "")
CURRENT_FOOT=$(echo "$CURRENT_SETTINGS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('settings', {}).get('codeinjection_foot', '') or '')" 2>/dev/null || echo "")

# Create new code injection
NEW_HEAD="<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">
<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>
<link href=\"${FONT_URL}\" rel=\"stylesheet\">
<style>
/* Commonplace Handwriting Font - Essay Content Only */
:root {
  --font-handwriting: ${FONT_FAMILY};
}

/* Apply to essay/post titles */
.post-title,
.post-card-title,
.post-header h1,
.gh-post-title {
  font-family: var(--font-handwriting) !important;
}

/* Apply to essay/post content */
.post-content,
.post-content p,
.post-content h1,
.post-content h2,
.post-content h3,
.post-content h4,
.post-content h5,
.post-content h6,
.gh-content,
.gh-content p {
  font-family: var(--font-handwriting) !important;
}
</style>"

# Combine with existing head injection
if [ -n "$CURRENT_HEAD" ] && [ "$CURRENT_HEAD" != "null" ]; then
  FINAL_HEAD="${CURRENT_HEAD}\n${NEW_HEAD}"
else
  FINAL_HEAD="${NEW_HEAD}"
fi

# Escape for JSON
FINAL_HEAD_ESCAPED=$(echo "$FINAL_HEAD" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

# Update settings
echo "Updating theme with handwriting font..."
UPDATE_RESPONSE=$(curl -s -X PUT \
  "${API_BASE}/settings/" \
  -H "Authorization: Ghost ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"settings\": [
      {
        \"key\": \"codeinjection_head\",
        \"value\": \"${FINAL_HEAD_ESCAPED}\"
      }
    ]
  }")

if echo "$UPDATE_RESPONSE" | grep -q '"settings"'; then
  echo ""
  echo "✅ Handwriting font added successfully!"
  echo ""
  echo "Font: $FONT_NAME"
  echo "Applied to: Essay titles and content only"
  echo "Navigation and UI elements use default font"
  echo ""
  echo "Visit your site to see the changes:"
  echo "  ${GHOST_URL}"
  echo ""
  echo "To customize further:"
  echo "  1. Go to Settings → Code Injection"
  echo "  2. Edit the CSS in Site Header"
  echo "  3. Adjust selectors to target different elements"
else
  echo "❌ Failed to update settings"
  echo "Response: $UPDATE_RESPONSE"
  exit 1
fi
