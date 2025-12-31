# Essay Generation - Quick Start

## Setup in 3 Steps

### 1. Deploy Supabase Edge Function

```bash
# Install Supabase CLI
npm install -g supabase

# Link to your project
supabase link --project-ref your-project-ref

# Set OpenAI API key
supabase secrets set OPENAI_API_KEY=your-openai-api-key

# Deploy
supabase functions deploy write-essay
```

### 2. Configure MCP Server

Add to `mcp-server/.env`:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

Get these from: Supabase Dashboard → Settings → API

### 3. Restart MCP Server

Restart your MCP client (Claude Desktop, etc.)

## Usage

### Via Natural Language

**Generate essay**:
```
"Write an essay in Arendt's persona about the nature of political action"
```

**Generate and publish**:
```
"Write a dialogue as Marx about capitalism and publish it to Ghost for faculty@example.com"
```

**With specific format**:
```
"Write a salon piece in Austen's style about modern society"
```

### Available Faculty

- **arendt** - Hannah Arendt
- **marx** - Karl Marx  
- **austen** - Jane Austen

## Example

```
"Write a medium-length essay in Arendt's persona about 
'the relationship between thinking and political action' 
with style notes focusing on her concept of the vita activa"
```

## Response

You'll get:
- Generated essay title and content
- Word count
- Option to publish directly to Ghost (as draft)

## Done! ✅

You can now generate essays in faculty personas.

See `ESSAY_GENERATION_SETUP.md` for complete documentation.
