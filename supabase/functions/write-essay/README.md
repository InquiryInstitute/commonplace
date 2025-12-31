# Write Essay Edge Function

Supabase Edge Function for generating essays in the persona of faculty members.

## Setup

### 1. Install Supabase CLI

```bash
npm install -g supabase
```

### 2. Link to Project

```bash
supabase link --project-ref your-project-ref
```

### 3. Set Environment Variables

```bash
supabase secrets set OPENAI_API_KEY=your-openai-api-key
```

### 4. Deploy

```bash
supabase functions deploy write-essay
```

## Usage

### API Endpoint

```
POST https://your-project.supabase.co/functions/v1/write-essay
```

### Request Body

```json
{
  "faculty_lastname": "arendt",
  "topic": "The nature of political action in modern times",
  "format": "essay",
  "length": "medium",
  "style_notes": "Focus on the relationship between thinking and action",
  "additional_context": "Consider contemporary examples"
}
```

### Parameters

- `faculty_lastname` (required): Last name of faculty member (e.g., "arendt", "marx", "austen")
- `topic` (required): Essay topic/subject
- `format` (optional): "essay" | "salon" | "review" | "dialogue" (default: "essay")
- `length` (optional): "short" | "medium" | "long" (default: "medium")
- `style_notes` (optional): Additional style instructions
- `additional_context` (optional): Additional context for the essay

### Response

```json
{
  "success": true,
  "essay": {
    "title": "The Nature of Political Action in Modern Times",
    "content": "...",
    "faculty": {
      "name": "Hannah",
      "lastname": "Arendt",
      "full_name": "Hannah Arendt"
    },
    "format": "essay",
    "length": "medium",
    "topic": "The nature of political action in modern times",
    "word_count": 1245
  },
  "metadata": {
    "persona_used": {...},
    "generated_at": "2025-12-31T..."
  }
}
```

## Available Faculty Personas

- **arendt**: Hannah Arendt
- **marx**: Karl Marx
- **austen**: Jane Austen

Add more personas by updating `FACULTY_PERSONAS` in `index.ts`.

## Environment Variables

- `OPENAI_API_KEY`: OpenAI API key for GPT-4
- `SUPABASE_URL`: Supabase project URL (auto-set)
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key (auto-set)

## Local Development

```bash
supabase functions serve write-essay
```

## Testing

```bash
curl -X POST https://your-project.supabase.co/functions/v1/write-essay \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "faculty_lastname": "arendt",
    "topic": "The banality of evil",
    "format": "essay",
    "length": "medium"
  }'
```
