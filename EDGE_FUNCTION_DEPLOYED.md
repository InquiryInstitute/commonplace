# Edge Function Deployed! ✅

## Status

✅ **Function Deployed**: `write-essay` is now live on Supabase  
✅ **Project**: `xougqdomkoisrxdnagcj`  
✅ **Deployed via CLI**: Used `--use-api` flag (no Docker needed)

## Next Steps

### 1. Set OpenRouter API Key Secret

```bash
supabase secrets set OPENROUTER_API_KEY=your-openrouter-api-key --project-ref xougqdomkoisrxdnagcj
```

Get your API key from: https://openrouter.ai/keys

### 2. Test the Function

```bash
curl -X POST https://xougqdomkoisrxdnagcj.supabase.co/functions/v1/write-essay \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "faculty_lastname": "arendt",
    "topic": "The nature of political action",
    "format": "essay",
    "length": "medium"
  }'
```

### 3. Configure MCP Server

Add to `mcp-server/.env`:

```bash
SUPABASE_URL=https://xougqdomkoisrxdnagcj.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Get the anon key from: Supabase Dashboard → Settings → API → anon/public key

### 4. Restart MCP Server

After updating `.env`, restart your MCP client.

## Function URL

- **Endpoint**: `https://xougqdomkoisrxdnagcj.supabase.co/functions/v1/write-essay`
- **Dashboard**: https://supabase.com/dashboard/project/xougqdomkoisrxdnagcj/functions

## Usage

Once configured, you can use the MCP tool:

```
"Write an essay in Arendt's persona about political action"
```

## Note

The `--use-api` flag uses Supabase's Management API to bundle functions remotely, so Docker is not required for deployment.
