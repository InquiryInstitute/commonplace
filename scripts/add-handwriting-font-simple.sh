#!/bin/bash
# Simple script to add handwriting font - uses Ghost Admin UI instructions

set -e

echo "=========================================="
echo "Add Handwriting Font to Commonplace"
echo "=========================================="
echo ""
echo "This script provides instructions for adding a handwriting font."
echo "You'll need to add the code manually via Ghost Admin."
echo ""

echo "Popular handwriting fonts:"
echo "  1. Kalam (casual, readable) - RECOMMENDED"
echo "  2. Caveat (elegant, script-like)"
echo "  3. Permanent Marker (bold, marker-style)"
echo "  4. Shadows Into Light (casual, friendly)"
echo "  5. Indie Flower (playful, rounded)"
echo ""

read -p "Select font (1-5, default 1): " FONT_CHOICE
FONT_CHOICE=${FONT_CHOICE:-1}

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
  *)
    FONT_NAME="Kalam"
    FONT_FAMILY="'Kalam', cursive"
    FONT_URL="https://fonts.googleapis.com/css2?family=Kalam:wght@300;400;700&display=swap"
    ;;
esac

echo ""
echo "=========================================="
echo "Instructions for ${FONT_NAME}"
echo "=========================================="
echo ""
echo "1. Go to Ghost Admin:"
echo "   https://commonplace.inquiry.institute/ghost"
echo ""
echo "2. Navigate to: Settings → Code Injection"
echo ""
echo "3. Paste this code into 'Site Header':"
echo ""
echo "----------------------------------------"
cat <<EOF
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="${FONT_URL}" rel="stylesheet">
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

/* Keep navigation and other UI elements with default font */
.gh-head-title,
.gh-head-menu,
.gh-head-menu a,
.gh-head-actions,
.post-meta,
.post-author,
.post-date,
.gh-post-meta {
  /* Use default theme font - no override */
}
</style>
EOF
echo "----------------------------------------"
echo ""
echo "4. Click 'Save'"
echo ""
echo "5. Visit your site to see the changes!"
echo "   https://commonplace.inquiry.institute"
echo ""
echo "✅ Done! Your site now uses ${FONT_NAME} for essay content and titles only."
echo "   Navigation and UI elements remain with the default font."
echo ""
