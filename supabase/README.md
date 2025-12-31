# Supabase Setup for Commonplace

## Current Status

✅ **Edge Function Code Created**: `functions/write-essay/index.ts`

⚠️ **Not Yet Deployed**: The function needs to be deployed to a Supabase project.

## Setup Options

### Option 1: Create New Supabase Project

1. **Create Supabase Project**:
   - Go to https://supabase.com
   - Create a new project
   - Note your project URL and anon key

2. **Initialize Supabase CLI**:
   ```bash
   cd supabase
   supabase init
   ```

3. **Link to Project**:
   ```bash
   supabase link --project-ref your-project-ref
   ```

4. **Set Secrets**:
   ```bash
   supabase secrets set OPENAI_API_KEY=your-openai-api-key
   ```

5. **Deploy Function**:
   ```bash
   supabase functions deploy write-essay
   ```

### Option 2: Use Existing Supabase Project

If you already have a Supabase project:

1. **Link to Existing Project**:
   ```bash
   cd supabase
   supabase link --project-ref your-existing-project-ref
   ```

2. **Set Secrets**:
   ```bash
   supabase secrets set OPENAI_API_KEY=your-openai-api-key
   ```

3. **Deploy Function**:
   ```bash
   supabase functions deploy write-essay
   ```

## What Exists

- ✅ Edge function code: `functions/write-essay/index.ts`
- ✅ Function documentation: `functions/write-essay/README.md`
- ✅ MCP tool integration: `mcp-server/src/index.js`

## What's Needed

- ⚠️ Supabase project (create new or use existing)
- ⚠️ Supabase CLI installed and linked
- ⚠️ OpenAI API key set as secret
- ⚠️ Function deployed to Supabase

## Quick Check

To see if Supabase is already set up:

```bash
cd supabase
supabase status
```

If you see project info, you're linked. If not, follow setup above.

## Next Steps

1. Check if you have a Supabase project
2. If not, create one at https://supabase.com
3. Follow deployment steps above
4. Update MCP server `.env` with Supabase credentials

See `ESSAY_GENERATION_SETUP.md` for complete instructions.
