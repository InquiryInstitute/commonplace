# Setup Persona Accounts - Quick Guide

## The MCP Tool Can Create Accounts ✅

The `create_persona_account` MCP tool is ready to create Ghost accounts for faculty personas.

## To Use It

### 1. Configure MCP Server

Add Ghost API key to `mcp-server/.env`:

```bash
GHOST_ADMIN_API_KEY=your-ghost-admin-api-key
```

Get the key from: Ghost Admin → Settings → Integrations → Custom Integration → Admin API Key

### 2. Restart MCP Server

After updating `.env`, restart your MCP client.

### 3. Create Accounts via MCP

Simply ask your MCP client:

```
"Create a persona account for John Locke"
```

Or create all at once:
```
"Create persona accounts for Locke, Arendt, Marx, and Austen"
```

## What Gets Created

For each persona:
- **Name**: Full name (e.g., "John Locke")
- **Email**: Persona email (e.g., "a.locke@inquiry.institute")
- **Role**: Author
- **Bio**: Description indicating it's AI-generated persona content
- **Status**: Active

## After Creation

Persona accounts can:
- ✅ Publish essays (automatically when using `write_essay_in_persona` with `auto_publish=true`)
- ✅ Comment on posts
- ✅ Have author pages
- ✅ Be used for all Ghost operations

## Current Status

- ✅ MCP tool `create_persona_account` implemented
- ✅ Auto-publish uses persona accounts by default
- ⚠️ Need to add `GHOST_ADMIN_API_KEY` to `mcp-server/.env`
- ⚠️ Need to create accounts (via MCP tool once configured)

## Next Steps

1. Add Ghost API key to `mcp-server/.env`
2. Restart MCP server
3. Use MCP tool to create persona accounts
4. Publish essays - they'll automatically use persona accounts!
