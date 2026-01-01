#!/bin/bash
# Publish Locke essay to Ghost

set -e

GHOST_URL="https://commonplace.inquiry.institute"
ESSAY_FILE="locke-essay-response.json"

echo "=========================================="
echo "Publishing Locke Essay to Ghost"
echo "=========================================="
echo ""

# Check if essay file exists
if [ ! -f "$ESSAY_FILE" ]; then
  echo "❌ Essay file not found: $ESSAY_FILE"
  exit 1
fi

# Get Ghost API key
read -p "Enter Ghost Admin API Key: " API_KEY
if [ -z "$API_KEY" ]; then
  echo "❌ API key required"
  exit 1
fi

API_BASE="${GHOST_URL}/ghost/api/admin"

# Extract essay data
TITLE=$(cat "$ESSAY_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin)['essay']['title'])" 2>/dev/null)
CONTENT=$(cat "$ESSAY_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin)['essay']['content'])" 2>/dev/null)

if [ -z "$TITLE" ] || [ -z "$CONTENT" ]; then
  echo "❌ Failed to extract essay data"
  exit 1
fi

echo "Title: $TITLE"
echo ""

# Get author email
read -p "Enter author email (or press Enter to use first admin user): " AUTHOR_EMAIL

if [ -z "$AUTHOR_EMAIL" ]; then
  echo "Fetching first admin user..."
  USERS_RESPONSE=$(curl -s -X GET \
    "${API_BASE}/users/?filter=roles:Administrator&limit=1" \
    -H "Authorization: Ghost ${API_KEY}")
  
  AUTHOR_EMAIL=$(echo "$USERS_RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['users'][0]['email'] if d.get('users') else '')" 2>/dev/null)
  
  if [ -z "$AUTHOR_EMAIL" ]; then
    echo "❌ No admin user found. Please provide author email."
    exit 1
  fi
  echo "Using author: $AUTHOR_EMAIL"
fi

# Get author ID
echo "Getting author ID..."
AUTHOR_RESPONSE=$(curl -s -X GET \
  "${API_BASE}/users/?filter=email:'${AUTHOR_EMAIL}'" \
  -H "Authorization: Ghost ${API_KEY}")

AUTHOR_ID=$(echo "$AUTHOR_RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['users'][0]['id'] if d.get('users') else '')" 2>/dev/null)

if [ -z "$AUTHOR_ID" ]; then
  echo "❌ Author not found: $AUTHOR_EMAIL"
  exit 1
fi

# Get or create tags
echo "Setting up tags..."

# Faculty tag
FACULTY_TAG_SLUG="faculty"
FACULTY_TAG_RESPONSE=$(curl -s -X GET \
  "${API_BASE}/tags/?filter=slug:${FACULTY_TAG_SLUG}" \
  -H "Authorization: Ghost ${API_KEY}")

FACULTY_TAG_ID=$(echo "$FACULTY_TAG_RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['tags'][0]['id'] if d.get('tags') else '')" 2>/dev/null)

# faculty-locke tag
FACULTY_LOCKE_SLUG="faculty-locke"
FACULTY_LOCKE_RESPONSE=$(curl -s -X GET \
  "${API_BASE}/tags/?filter=slug:${FACULTY_LOCKE_SLUG}" \
  -H "Authorization: Ghost ${API_KEY}")

FACULTY_LOCKE_ID=$(echo "$FACULTY_LOCKE_RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['tags'][0]['id'] if d.get('tags') else '')" 2>/dev/null)

if [ -z "$FACULTY_LOCKE_ID" ]; then
  echo "Creating faculty-locke tag..."
  CREATE_TAG_RESPONSE=$(curl -s -X POST \
    "${API_BASE}/tags/" \
    -H "Authorization: Ghost ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"tags\": [{
        \"name\": \"John Locke\",
        \"slug\": \"faculty-locke\",
        \"description\": \"Content by John Locke\",
        \"visibility\": \"public\"
      }]
    }")
  
  FACULTY_LOCKE_ID=$(echo "$CREATE_TAG_RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['tags'][0]['id'] if d.get('tags') else '')" 2>/dev/null)
  
  if [ -n "$FACULTY_TAG_ID" ] && [ -n "$FACULTY_LOCKE_ID" ]; then
    # Set parent
    curl -s -X PUT \
      "${API_BASE}/tags/${FACULTY_LOCKE_ID}/" \
      -H "Authorization: Ghost ${API_KEY}" \
      -H "Content-Type: application/json" \
      -d "{
        \"tags\": [{
          \"id\": \"${FACULTY_LOCKE_ID}\",
          \"parent_id\": \"${FACULTY_TAG_ID}\"
        }]
      }" > /dev/null
  fi
fi

# Essay format tag
ESSAY_TAG_SLUG="essay"
ESSAY_TAG_RESPONSE=$(curl -s -X GET \
  "${API_BASE}/tags/?filter=slug:${ESSAY_TAG_SLUG}" \
  -H "Authorization: Ghost ${API_KEY}")

ESSAY_TAG_ID=$(echo "$ESSAY_TAG_RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['tags'][0]['id'] if d.get('tags') else '')" 2>/dev/null)

# Build tags array
TAG_IDS="[]"
if [ -n "$FACULTY_LOCKE_ID" ]; then
  TAG_IDS="[{\"id\":\"${FACULTY_LOCKE_ID}\"}]"
fi
if [ -n "$ESSAY_TAG_ID" ]; then
  TAG_IDS="[{\"id\":\"${FACULTY_LOCKE_ID}\"},{\"id\":\"${ESSAY_TAG_ID}\"}]"
fi

# Publish post
echo ""
echo "Publishing essay..."
PUBLISH_RESPONSE=$(curl -s -X POST \
  "${API_BASE}/posts/" \
  -H "Authorization: Ghost ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"posts\": [{
      \"title\": $(python3 -c "import sys, json; print(json.dumps('$TITLE'))"),
      \"html\": $(python3 -c "import sys, json; print(json.dumps('$CONTENT'))"),
      \"status\": \"draft\",
      \"authors\": [{\"id\": \"${AUTHOR_ID}\"}],
      \"tags\": ${TAG_IDS}
    }]
  }")

POST_ID=$(echo "$PUBLISH_RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['posts'][0]['id'] if d.get('posts') else '')" 2>/dev/null)

if [ -z "$POST_ID" ]; then
  echo "❌ Failed to publish"
  echo "Response: $PUBLISH_RESPONSE"
  exit 1
fi

POST_URL=$(echo "$PUBLISH_RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['posts'][0]['url'] if d.get('posts') else '')" 2>/dev/null)

echo ""
echo "✅ Essay published successfully!"
echo ""
echo "Post ID: $POST_ID"
echo "Status: draft (ready for review)"
echo "URL: $POST_URL"
echo ""
echo "You can now:"
echo "  1. Review the essay in Ghost admin"
echo "  2. Edit if needed"
echo "  3. Publish when ready"
echo ""
