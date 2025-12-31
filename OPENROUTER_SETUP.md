# OpenRouter Setup

## Updated to Use OpenRouter ✅

The edge function now uses OpenRouter instead of OpenAI directly. This provides:
- Access to multiple high-quality models (Claude, GPT-4, Gemini, etc.)
- Unified API for all models
- Better pricing options
- Model flexibility

## Current Configuration

- **Default Model**: `anthropic/claude-3.5-sonnet`
- **API Endpoint**: `https://openrouter.ai/api/v1/chat/completions`

## Setup

### 1. Get OpenRouter API Key

1. Go to https://openrouter.ai/keys
2. Sign up or log in
3. Create a new API key
4. Copy the key

### 2. Set Secret in Supabase

```bash
supabase secrets set OPENROUTER_API_KEY=your-openrouter-api-key --project-ref xougqdomkoisrxdnagcj
```

### 3. Function Already Deployed ✅

The function has been updated and redeployed with OpenRouter support.

## Available Models

You can change the model in `supabase/functions/write-essay/index.ts`:

- `anthropic/claude-3.5-sonnet` (default, excellent quality)
- `openai/gpt-4-turbo`
- `anthropic/claude-3-opus` (highest quality, more expensive)
- `google/gemini-pro`
- See https://openrouter.ai/models for full list

## Pricing

OpenRouter pricing varies by model:
- Claude 3.5 Sonnet: ~$0.003-0.015 per 1K tokens
- GPT-4 Turbo: ~$0.01-0.03 per 1K tokens
- Check https://openrouter.ai/models for current pricing

## Benefits of OpenRouter

1. **Model Flexibility**: Easy to switch between models
2. **Unified API**: Same interface for all models
3. **Cost Optimization**: Choose models based on cost/quality needs
4. **Reliability**: Multiple model providers as backup

## Testing

Test the function:

```bash
curl -X POST https://xougqdomkoisrxdnagcj.supabase.co/functions/v1/write-essay \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "faculty_lastname": "arendt",
    "topic": "The nature of political action",
    "format": "essay"
  }'
```

## Next Steps

1. ✅ Function updated and deployed
2. Set `OPENROUTER_API_KEY` secret
3. Test the function
4. Configure MCP server with Supabase credentials
