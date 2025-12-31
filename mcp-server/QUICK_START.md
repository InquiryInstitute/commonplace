# Quick Start: Commonplace MCP Server

## 5-Minute Setup

### Step 1: Install
```bash
cd mcp-server
npm install
```

### Step 2: Get API Key

1. Visit: https://commonplace.inquiry.institute/ghost
2. Settings → Integrations → Add custom integration
3. Name: "MCP Server"
4. Copy the **Admin API Key**

### Step 3: Configure

Create `.env` file:
```bash
cp .env.example .env
```

Edit `.env`:
```
GHOST_URL=https://commonplace.inquiry.institute
GHOST_ADMIN_API_KEY=your-api-key-here
```

### Step 4: Test

```bash
npm test
```

Should show: ✅ Connection successful!

### Step 5: Configure MCP Client

**Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json`):

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

Restart Claude Desktop.

## Done! 

You can now ask Claude:
- "Create a faculty account for..."
- "Publish an essay..."
- "List all essays..."
- "Review essay..."

See `FACULTY_GUIDE.md` for usage examples.
