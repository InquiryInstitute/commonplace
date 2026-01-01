# How to Get Ghost Admin API Key

## Step-by-Step Instructions

### 1. Log in to Ghost Admin

Go to: **https://commonplace.inquiry.institute/ghost**

Log in with your admin credentials.

### 2. Navigate to Integrations

1. Click **Settings** (gear icon in bottom left)
2. Click **Integrations** in the sidebar

### 3. Create or Use Custom Integration

**Option A: Create New Integration**
1. Click **"Add custom integration"** button
2. Name it: "MCP Server" (or any name you prefer)
3. Click **"Create"**
4. The API key will be displayed

**Option B: Use Existing Integration**
1. Find an existing custom integration
2. Click on it to view details
3. Copy the **Admin API Key**

### 4. Copy the Admin API Key

You'll see something like:
```
Admin API Key
abc123def456ghi789jkl012mno345pqr678stu901vwx234yz
```

Copy this entire key.

### 5. Add to MCP Server Config

Add it to `mcp-server/.env`:

```bash
GHOST_ADMIN_API_KEY=abc123def456ghi789jkl012mno345pqr678stu901vwx234yz
```

### 6. Restart MCP Server

After adding the key, restart your MCP client (Claude Desktop, etc.)

## Visual Guide

```
Ghost Admin → Settings → Integrations → Add custom integration
                                              ↓
                                    Name: "MCP Server"
                                              ↓
                                    Copy Admin API Key
                                              ↓
                          Add to mcp-server/.env file
```

## Security Notes

- **Admin API Key** has full access to Ghost - protect it
- Don't commit `.env` to git (already gitignored)
- Can revoke/regenerate keys in Integrations settings
- Each integration has its own key

## Quick Access

Direct link: **https://commonplace.inquiry.institute/ghost/#/settings/integrations**

## After Getting the Key

1. Add to `mcp-server/.env`
2. Restart MCP server
3. Use MCP tools to create persona accounts and publish essays!
