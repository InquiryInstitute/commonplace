# Ghost API Key Types

## Two Types of API Keys

Ghost provides two different API keys:

### 1. Content API Key (What you have)
- **Purpose**: Read-only access to published content
- **Use**: For public-facing applications, reading posts, etc.
- **Your key**: `355ef4b915a013dc3e1836ff0f`
- **Limitations**: Cannot create users, publish posts, or modify content

### 2. Admin API Key (What we need)
- **Purpose**: Full admin access - create users, publish posts, manage content
- **Use**: For MCP server to create accounts and publish essays
- **Where to get**: Same place (Integrations), but look for "Admin API Key" section
- **Required for**: 
  - Creating persona accounts
  - Publishing essays
  - Managing users
  - All MCP tools

## How to Get Admin API Key

1. Go to: https://commonplace.inquiry.institute/ghost/#/settings/integrations
2. Find your custom integration (or create one)
3. Look for **"Admin API Key"** (separate from Content API Key)
4. Copy the Admin API Key (usually longer than Content API Key)

## Current Status

✅ **Content API Key**: Added to config (for reading content)  
⚠️ **Admin API Key**: Still needed (for creating accounts and publishing)

## After Getting Admin API Key

Add to `mcp-server/.env`:

```bash
GHOST_ADMIN_API_KEY=your-admin-api-key-here
```

Then you can:
- Create persona accounts via MCP
- Publish essays automatically
- Use all MCP tools

## Note

Both keys are shown in the same integration settings page:
- **Content API Key**: For reading
- **Admin API Key**: For writing/managing

Make sure to get the **Admin API Key** for the MCP server.
