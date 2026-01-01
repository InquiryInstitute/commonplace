#!/bin/bash
# Create Ghost accounts for faculty personas

set -e

GHOST_URL="https://commonplace.inquiry.institute"

echo "=========================================="
echo "Create Faculty Persona Accounts"
echo "=========================================="
echo ""

read -p "Enter Ghost Admin API Key: " API_KEY
if [ -z "$API_KEY" ]; then
  echo "❌ API key required"
  exit 1
fi

API_BASE="${GHOST_URL}/ghost/api/admin"

# Function to create persona account
create_persona_account() {
  local name=$1
  local email=$2
  local slug=$3
  local bio=$4
  
  echo "Creating account for $name ($email)..."
  
  # Check if user exists
  CHECK_RESPONSE=$(curl -s -X GET \
    "${API_BASE}/users/?filter=email:'${email}'" \
    -H "Authorization: Ghost ${API_KEY}")
  
  EXISTS=$(echo "$CHECK_RESPONSE" | python3 -c "import json, sys; d=json.load(sys.stdin); print('yes' if d.get('users') else 'no')" 2>/dev/null)
  
  if [ "$EXISTS" = "yes" ]; then
    echo "  ✅ Account already exists"
    return
  fi
  
  # Create user (without invitation - they won't actually log in)
  CREATE_RESPONSE=$(curl -s -X POST \
    "${API_BASE}/users/" \
    -H "Authorization: Ghost ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"users\": [{
        \"name\": \"${name}\",
        \"email\": \"${email}\",
        \"roles\": [\"Author\"],
        \"bio\": \"${bio}\",
        \"status\": \"active\"
      }]
    }")
  
  SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import json, sys; d=json.load(sys.stdin); print('yes' if d.get('users') else 'no')" 2>/dev/null)
  
  if [ "$SUCCESS" = "yes" ]; then
    echo "  ✅ Account created"
  else
    echo "  ❌ Failed: $CREATE_RESPONSE"
  fi
}

# Create persona accounts
echo "Creating persona accounts..."
echo ""

create_persona_account \
  "John Locke" \
  "a.locke@inquiry.institute" \
  "john-locke" \
  "Empiricist philosopher. Content generated in the persona of John Locke using AI."

create_persona_account \
  "Hannah Arendt" \
  "h.arendt@inquiry.institute" \
  "hannah-arendt" \
  "Political theorist and philosopher. Content generated in the persona of Hannah Arendt using AI."

create_persona_account \
  "Karl Marx" \
  "k.marx@inquiry.institute" \
  "karl-marx" \
  "Philosopher, economist, and revolutionary. Content generated in the persona of Karl Marx using AI."

create_persona_account \
  "Jane Austen" \
  "j.austen@inquiry.institute" \
  "jane-austen" \
  "Novelist and social commentator. Content generated in the persona of Jane Austen using AI."

echo ""
echo "=========================================="
echo "✅ Persona Accounts Created"
echo "=========================================="
echo ""
echo "Accounts created:"
echo "  - a.locke@inquiry.institute (John Locke)"
echo "  - h.arendt@inquiry.institute (Hannah Arendt)"
echo "  - k.marx@inquiry.institute (Karl Marx)"
echo "  - j.austen@inquiry.institute (Jane Austen)"
echo ""
echo "These accounts can now publish essays and comment."
echo "Note: These are persona accounts for AI-generated content."
echo ""
