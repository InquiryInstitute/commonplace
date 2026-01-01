#!/bin/bash
# Directly publish essay to Ghost using API

set -e

GHOST_URL="https://commonplace.inquiry.institute"
ESSAY_FILE="locke-essay-response.json"

if [ ! -f "$ESSAY_FILE" ]; then
  echo "❌ Essay file not found"
  exit 1
fi

# Get API key from environment or prompt
API_KEY="${GHOST_ADMIN_API_KEY}"
if [ -z "$API_KEY" ]; then
  read -p "Enter Ghost Admin API Key: " API_KEY
fi

AUTHOR_EMAIL="${1:-}"  # First argument or empty

API_BASE="${GHOST_URL}/ghost/api/admin"

# Extract essay data using Python
TITLE=$(python3 -c "import json; d=json.load(open('$ESSAY_FILE')); print(d['essay']['title'])")
CONTENT=$(python3 -c "import json; d=json.load(open('$ESSAY_FILE')); print(d['essay']['content'].replace('\\n', '\\\\n').replace('\"', '\\\"'))")

# Get author
if [ -z "$AUTHOR_EMAIL" ]; then
  # Get first admin
  USERS_JSON=$(curl -s -X GET "${API_BASE}/users/?filter=roles:Administrator&limit=1" -H "Authorization: Ghost ${API_KEY}")
  AUTHOR_EMAIL=$(python3 -c "import json, sys; d=json.loads('$USERS_JSON'); print(d['users'][0]['email'] if d.get('users') else '')")
fi

AUTHOR_JSON=$(curl -s -X GET "${API_BASE}/users/?filter=email:'${AUTHOR_EMAIL}'" -H "Authorization: Ghost ${API_KEY}")
AUTHOR_ID=$(python3 -c "import json, sys; d=json.loads('$AUTHOR_JSON'); print(d['users'][0]['id'] if d.get('users') else '')")

# Get/create tags
FACULTY_LOCKE_JSON=$(curl -s -X GET "${API_BASE}/tags/?filter=slug:faculty-locke" -H "Authorization: Ghost ${API_KEY}")
FACULTY_LOCKE_ID=$(python3 -c "import json, sys; d=json.loads('$FACULTY_LOCKE_JSON'); print(d['tags'][0]['id'] if d.get('tags') else '')")

if [ -z "$FACULTY_LOCKE_ID" ]; then
  CREATE_TAG_JSON=$(curl -s -X POST "${API_BASE}/tags/" \
    -H "Authorization: Ghost ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{"tags":[{"name":"John Locke","slug":"faculty-locke","description":"Content by John Locke","visibility":"public"}]}')
  FACULTY_LOCKE_ID=$(python3 -c "import json, sys; d=json.loads('$CREATE_TAG_JSON'); print(d['tags'][0]['id'] if d.get('tags') else '')")
fi

ESSAY_TAG_JSON=$(curl -s -X GET "${API_BASE}/tags/?filter=slug:essay" -H "Authorization: Ghost ${API_KEY}")
ESSAY_TAG_ID=$(python3 -c "import json, sys; d=json.loads('$ESSAY_TAG_JSON'); print(d['tags'][0]['id'] if d.get('tags') else '')")

# Build tags array
TAGS="[{\"id\":\"${FACULTY_LOCKE_ID}\"}]"
if [ -n "$ESSAY_TAG_ID" ]; then
  TAGS="[{\"id\":\"${FACULTY_LOCKE_ID}\"},{\"id\":\"${ESSAY_TAG_ID}\"}]"
fi

# Publish
POST_DATA=$(python3 << PYEOF
import json
title = """$TITLE"""
content = """$CONTENT"""
tags = $TAGS
author_id = """$AUTHOR_ID"""

post = {
    "posts": [{
        "title": title,
        "html": content,
        "status": "draft",
        "authors": [{"id": author_id}],
        "tags": tags
    }]
}
print(json.dumps(post))
PYEOF
)

RESPONSE=$(curl -s -X POST "${API_BASE}/posts/" \
  -H "Authorization: Ghost ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$POST_DATA")

POST_ID=$(python3 -c "import json, sys; d=json.loads('$RESPONSE'); print(d['posts'][0]['id'] if d.get('posts') else '')")
POST_URL=$(python3 -c "import json, sys; d=json.loads('$RESPONSE'); print(d['posts'][0]['url'] if d.get('posts') else '')")

if [ -n "$POST_ID" ]; then
  echo "✅ Essay published!"
  echo "Post ID: $POST_ID"
  echo "URL: $POST_URL"
  echo "Status: draft"
else
  echo "❌ Failed to publish"
  echo "$RESPONSE"
fi
