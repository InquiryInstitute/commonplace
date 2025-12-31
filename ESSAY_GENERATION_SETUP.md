# Essay Generation Setup

## Overview

The essay generation system allows faculty to create essays in the persona of historical thinkers using AI. It consists of:

1. **Supabase Edge Function** - Generates essays using OpenAI
2. **MCP Tool** - `write_essay_in_persona` - Calls the edge function and optionally publishes to Ghost

## Architecture

```
MCP Client → MCP Server → Supabase Edge Function → OpenAI API
                                    ↓
                              Generated Essay
                                    ↓
                              (Optional) Ghost CMS
```

## Setup

### 1. Supabase Edge Function

#### Deploy the Function

```bash
# Install Supabase CLI
npm install -g supabase

# Link to your project
supabase link --project-ref your-project-ref

# Set OpenRouter API key
supabase secrets set OPENROUTER_API_KEY=your-openrouter-api-key
```
Get your key from: https://openrouter.ai/keys

# Deploy
supabase functions deploy write-essay
```

#### Test the Function

```bash
curl -X POST https://your-project.supabase.co/functions/v1/write-essay \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "faculty_lastname": "arendt",
    "topic": "The nature of political action",
    "format": "essay",
    "length": "medium"
  }'
```

### 2. MCP Server Configuration

Add Supabase credentials to your MCP server `.env`:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

Get these from:
- Supabase Dashboard → Settings → API
- Project URL → `SUPABASE_URL`
- anon/public key → `SUPABASE_ANON_KEY`

### 3. Restart MCP Server

After updating `.env`, restart your MCP server.

## Usage

### Via MCP Client (Claude, etc.)

**Basic usage**:
```
"Write an essay in the persona of Arendt about the nature of political action"
```

**With format**:
```
"Write a dialogue in Marx's persona about capitalism and alienation"
```

**With auto-publish**:
```
"Write an essay as Austen about modern society and publish it to Ghost for jane@example.com"
```

### Via MCP Tool Directly

```json
{
  "tool": "write_essay_in_persona",
  "arguments": {
    "faculty_lastname": "arendt",
    "topic": "The nature of political action in modern times",
    "format": "essay",
    "length": "medium",
    "style_notes": "Focus on the relationship between thinking and action",
    "additional_context": "Consider contemporary examples",
    "auto_publish": true,
    "author_email": "faculty@inquiry.institute"
  }
}
```

## Parameters

### Required
- `faculty_lastname`: Last name of faculty (e.g., "arendt", "marx", "austen")
- `topic`: Essay topic/subject

### Optional
- `format`: "essay" | "salon" | "review" | "dialogue" (default: "essay")
- `length`: "short" | "medium" | "long" (default: "medium")
- `style_notes`: Additional style instructions
- `additional_context`: Additional context for the topic
- `auto_publish`: Automatically publish to Ghost (default: false)
- `author_email`: Email of author (required if auto_publish is true)

## Available Faculty Personas

Currently configured:
- **arendt**: Hannah Arendt
- **marx**: Karl Marx
- **austen**: Jane Austen

### Adding New Personas

Edit `supabase/functions/write-essay/index.ts`:

```typescript
const FACULTY_PERSONAS: Record<string, FacultyPersona> = {
  'newfaculty': {
    name: 'First',
    lastname: 'Last',
    style: 'Description of their style',
    themes: ['theme1', 'theme2'],
    writing_characteristics: [
      'Characteristic 1',
      'Characteristic 2',
    ]
  },
  // ... existing personas
}
```

Then redeploy:
```bash
supabase functions deploy write-essay
```

## Response Format

```json
{
  "success": true,
  "message": "Essay generated successfully",
  "essay": {
    "title": "Generated Title",
    "content": "Essay content in HTML...",
    "faculty": {
      "name": "Hannah",
      "lastname": "Arendt",
      "full_name": "Hannah Arendt"
    },
    "format": "essay",
    "length": "medium",
    "topic": "The nature of political action",
    "word_count": 1245
  },
  "published": {
    "post_id": "67890abcdef",
    "slug": "generated-title",
    "url": "https://commonplace.inquiry.institute/generated-title/",
    "status": "draft"
  },
  "metadata": {
    "persona_used": {...},
    "generated_at": "2025-12-31T..."
  }
}
```

## Workflow

### 1. Generate Only
- Essay is generated and returned
- Not published to Ghost
- Faculty can review and edit before publishing

### 2. Generate and Auto-Publish
- Essay is generated
- Automatically created in Ghost as draft
- Tagged with faculty tag and format tag
- Faculty can review before making public

### 3. Manual Publishing
- Generate essay (auto_publish: false)
- Review the content
- Use `publish_essay` tool to publish manually

## Best Practices

1. **Start with drafts**: Use `auto_publish: true` but essays are created as drafts
2. **Review before publishing**: Always review AI-generated content
3. **Edit as needed**: Generated essays are starting points, not final products
4. **Add context**: Use `additional_context` to guide the generation
5. **Specify style**: Use `style_notes` for specific stylistic requirements

## Troubleshooting

### "Supabase not configured"
- Check that `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set in `.env`
- Restart MCP server after updating `.env`

### "Faculty persona not found"
- Check available personas in edge function
- Use lowercase lastname (e.g., "arendt" not "Arendt")

### "OpenRouter API error"
- Verify `OPENROUTER_API_KEY` is set in Supabase secrets
- Check OpenRouter API quota/limits
- Verify you have credits in your OpenRouter account

### "Author not found" (when auto_publish)
- Ensure author email exists in Ghost
- Create faculty account first using `create_faculty_account`

## Security

- OpenRouter API key stored in Supabase secrets (not exposed)
- Supabase anon key is safe for client-side use
- Essays are created as drafts by default (requires review)
- Faculty must have Ghost account to publish

## Cost Considerations

- OpenRouter API usage: Varies by model (Claude 3.5 Sonnet ~$0.003-0.015 per 1K tokens)
- Supabase Edge Functions: Free tier includes 500K invocations/month
- Monitor usage in Supabase dashboard and OpenRouter dashboard

## Related Documentation

- Supabase Edge Functions: https://supabase.com/docs/guides/functions
- MCP Server: `mcp-server/README.md`
- Ghost Publishing: See `publish_essay` tool documentation
