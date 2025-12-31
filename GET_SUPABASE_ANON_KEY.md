# Get Supabase Anon Key (7a2...)

## To Get the Anon Key

The Supabase anon key (which starts with "7a2" or similar) is needed for the MCP server configuration.

### Option 1: Supabase Dashboard

1. Go to: https://supabase.com/dashboard/project/xougqdomkoisrxdnagcj/settings/api
2. Look for **"anon"** or **"public"** key
3. Copy the key (it's a JWT token, typically starts with `eyJ` but can vary)

### Option 2: Check if Already in ~/.env

```bash
grep -i "supabase.*anon\|7a2" ~/.env
```

### Option 3: Use Supabase CLI (if available)

The anon key is stored as a secret but the CLI doesn't show the value directly for security.

## Once You Have It

Add to `mcp-server/.env`:

```bash
SUPABASE_URL=https://xougqdomkoisrxdnagcj.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

The anon key is safe to use client-side - it's designed for public use with Row Level Security (RLS) policies.
