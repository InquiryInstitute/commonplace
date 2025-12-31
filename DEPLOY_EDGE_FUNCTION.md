# Deploy Edge Function - Alternative Methods

## Current Status

✅ Function code ready: `supabase/functions/write-essay/index.ts`  
✅ Project linked: `xougqdomkoisrxdnagcj`  
⚠️ Docker issue preventing CLI deployment

## Option 1: Deploy via Supabase Dashboard

1. **Go to Supabase Dashboard**:
   - https://supabase.com/dashboard/project/xougqdomkoisrxdnagcj
   - Navigate to **Edge Functions**

2. **Create New Function**:
   - Click "Create a new function"
   - Name: `write-essay`

3. **Copy Function Code**:
   - Copy contents of `supabase/functions/write-essay/index.ts`
   - Paste into the function editor

4. **Set Environment Variables**:
   - Go to **Settings** → **Edge Functions** → **Secrets**
   - Add secret: `OPENAI_API_KEY` = your OpenAI API key

5. **Deploy**:
   - Click "Deploy" in the dashboard

## Option 2: Fix Docker and Use CLI

If Docker is working:

```bash
cd /Users/danielmcshan/GitHub/commonplace
supabase functions deploy write-essay --project-ref xougqdomkoisrxdnagcj
```

## Option 3: Set Secret First

Set the OpenAI API key secret:

```bash
supabase secrets set OPENAI_API_KEY=your-key --project-ref xougqdomkoisrxdnagcj
```

## Verify Deployment

After deployment, test the function:

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

## Next Steps

1. Deploy function (via dashboard or CLI)
2. Set `OPENAI_API_KEY` secret
3. Update MCP server `.env` with Supabase URL and anon key
4. Test via MCP tool
