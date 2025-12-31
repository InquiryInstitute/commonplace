# MCP Server Setup Guide

## Quick Start

### 1. Install Dependencies

```bash
cd mcp-server
npm install
```

### 2. Get Ghost Admin API Key

1. Visit https://commonplace.inquiry.institute/ghost
2. Log in with admin credentials
3. Go to **Settings** → **Integrations**
4. Click **Add custom integration**
5. Name it "MCP Server"
6. Copy the **Admin API Key** (starts with something like `abc123...`)

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and add:
```
GHOST_URL=https://commonplace.inquiry.institute
GHOST_ADMIN_API_KEY=your-copied-api-key-here
```

### 4. Test the Server

```bash
npm start
```

The server should start without errors. Press Ctrl+C to stop.

## Configure MCP Client

### Claude Desktop

Edit `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or equivalent:

```json
{
  "mcpServers": {
    "commonplace-ghost": {
      "command": "node",
      "args": ["/Users/danielmcshan/GitHub/commonplace/mcp-server/src/index.js"],
      "env": {
        "GHOST_URL": "https://commonplace.inquiry.institute",
        "GHOST_ADMIN_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

### Cursor / Other MCP Clients

Refer to your client's documentation for MCP server configuration. The server communicates via stdio (standard input/output).

## Verify Setup

Once configured, you should be able to use tools like:
- "Create a faculty account for jane@example.com"
- "List all published essays"
- "Publish an essay titled 'My Essay'"

## Security Notes

- **Keep API key secure**: Don't commit `.env` to git
- **API Key Permissions**: The Admin API key has full access - protect it
- **Rotate Keys**: Regularly rotate API keys for security

## Troubleshooting

### "Cannot find module"
- Run `npm install` in the `mcp-server` directory

### "Authentication failed"
- Verify the API key is correct
- Check that the key hasn't been revoked in Ghost admin
- Ensure no extra spaces in the API key

### "Resource not found"
- Verify Ghost URL is correct
- Check that Ghost is accessible
- Ensure the site is fully set up
