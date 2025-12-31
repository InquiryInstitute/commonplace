#!/bin/bash
# Setup Commonplace tag structure in Ghost

set -e

GHOST_URL="https://commonplace.inquiry.institute"
PROJECT_ID="institute-481516"

echo "=========================================="
echo "Commonplace Tag Structure Setup"
echo "=========================================="
echo ""
echo "This will create the tag structure:"
echo "  Primary: Faculty"
echo "  Secondary: College (ARTS, SOCI, META...), Format (Essay, Salon, Review, Dialogue), Series"
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
echo "Creating tag structure..."

# Function to create tag
create_tag() {
  local name=$1
  local slug=$2
  local description=$3
  local parent_slug=$4
  
  echo "Creating tag: $name ($slug)"
  
  local parent_json=""
  if [ -n "$parent_slug" ]; then
    # Get parent tag ID
    local parent_response=$(curl -s -X GET \
      "${API_BASE}/tags/?filter=slug:${parent_slug}" \
      -H "Authorization: Ghost ${API_KEY}")
    
    local parent_id=$(echo "$parent_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$parent_id" ]; then
      echo "⚠️  Warning: Parent tag '${parent_slug}' not found, creating without parent"
    else
      parent_json="\"parent_id\":\"${parent_id}\","
    fi
  fi
  
  # Check if tag already exists
  local existing=$(curl -s -X GET \
    "${API_BASE}/tags/?filter=slug:${slug}" \
    -H "Authorization: Ghost ${API_KEY}")
  
  local existing_id=$(echo "$existing" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
  
  if [ -n "$existing_id" ]; then
    echo "  Tag already exists, updating..."
    local response=$(curl -s -X PUT \
      "${API_BASE}/tags/${existing_id}/" \
      -H "Authorization: Ghost ${API_KEY}" \
      -H "Content-Type: application/json" \
      -d "{
        \"tags\": [{
          \"name\": \"${name}\",
          \"slug\": \"${slug}\",
          \"description\": \"${description}\",
          ${parent_json}
          \"visibility\": \"public\"
        }]
      }")
  else
    local response=$(curl -s -X POST \
      "${API_BASE}/tags/" \
      -H "Authorization: Ghost ${API_KEY}" \
      -H "Content-Type: application/json" \
      -d "{
        \"tags\": [{
          \"name\": \"${name}\",
          \"slug\": \"${slug}\",
          \"description\": \"${description}\",
          ${parent_json}
          \"visibility\": \"public\"
        }]
      }")
  fi
  
  if echo "$response" | grep -q '"tags"'; then
    echo "  ✅ Created/Updated: $name"
  else
    echo "  ❌ Failed: $response"
  fi
}

# Create primary tag: Faculty
create_tag "Faculty" "faculty" "Primary tag for all faculty content" ""

# Create College tags
echo ""
echo "Creating College tags..."
create_tag "ARTS" "arts" "College of Arts" "faculty"
create_tag "SOCI" "soci" "College of Social Sciences" "faculty"
create_tag "META" "meta" "College of Metaphysics" "faculty"
create_tag "HIST" "hist" "College of History" "faculty"
create_tag "PHIL" "phil" "College of Philosophy" "faculty"
create_tag "LIT" "lit" "College of Literature" "faculty"

# Create Format tags
echo ""
echo "Creating Format tags..."
create_tag "Essay" "essay" "Essay format" "faculty"
create_tag "Salon" "salon" "Salon format" "faculty"
create_tag "Review" "review" "Review format" "faculty"
create_tag "Dialogue" "dialogue" "Dialogue format" "faculty"

# Note: Series tags will be created as needed for specific series

echo ""
echo "=========================================="
echo "✅ Tag Structure Created!"
echo "=========================================="
echo ""
echo "Tags created:"
echo "  Primary: Faculty"
echo "  Colleges: ARTS, SOCI, META, HIST, PHIL, LIT"
echo "  Formats: Essay, Salon, Review, Dialogue"
echo ""
echo "URL patterns:"
echo "  /tag/faculty-arendt/"
echo "  /tag/faculty-marx/dialogues/"
echo ""
echo "Note: Individual faculty tags (e.g., 'faculty-arendt') should be"
echo "created when publishing content. They will be child tags of 'Faculty'."
echo ""
echo "To create a faculty-specific tag:"
echo "  - Use Ghost admin: Settings → Tags → New Tag"
echo "  - Or use MCP server: create_faculty_tag tool"
echo ""
