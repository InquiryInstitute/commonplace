#!/bin/bash
# Create Ghost account for John Locke persona

set -e

GHOST_URL="https://commonplace.inquiry.institute"

echo "Creating John Locke persona account..."

read -p "Enter Ghost Admin API Key: " API_KEY
if [ -z "$API_KEY" ]; then
  echo "❌ API key required"
  exit 1
fi

API_BASE="${GHOST_URL}/ghost/api/admin"

# Create a.locke account
echo "Creating account: a.locke@inquiry.institute..."

RESPONSE=$(curl -s -X POST \
  "${API_BASE}/users/" \
  -H "Authorization: Ghost ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "users": [{
      "name": "John Locke",
      "email": "a.locke@inquiry.institute",
      "roles": ["Author"],
      "bio": "Empiricist philosopher. Content generated in the persona of John Locke using AI.",
      "status": "active"
    }]
  }')

SUCCESS=$(echo "$RESPONSE" | python3 -c "import json, sys; d=json.load(sys.stdin); print('yes' if d.get('users') else 'no')" 2>/dev/null)

if [ "$SUCCESS" = "yes" ]; then
  USER=$(echo "$RESPONSE" | python3 -c "import json, sys; d=json.load(sys.stdin); u=d['users'][0]; print(f\"ID: {u['id']}, Email: {u['email']}, Name: {u['name']}\")" 2>/dev/null)
  echo "✅ Account created: $USER"
else
  ERROR=$(echo "$RESPONSE" | python3 -c "import json, sys; d=json.load(sys.stdin); print(d.get('errors', [{}])[0].get('message', 'Unknown error'))" 2>/dev/null)
  if [[ "$ERROR" == *"already exists"* ]] || [[ "$ERROR" == *"User already exists"* ]]; then
    echo "✅ Account already exists"
  else
    echo "❌ Failed: $ERROR"
    echo "Response: $RESPONSE"
    exit 1
  fi
fi

echo ""
echo "✅ John Locke persona account ready!"
echo "   Email: a.locke@inquiry.institute"
echo "   Can now publish essays and comment"
echo ""
