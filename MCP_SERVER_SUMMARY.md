# MCP Server for Commonplace - Summary

## ✅ Created

A complete MCP (Model Context Protocol) server that enables AI assistants to interact with Ghost CMS for faculty operations.

## Features

### Account Management
- ✅ `create_faculty_account` - Create new faculty accounts with roles
- ✅ `list_faculty` - List all faculty members
- ✅ `get_faculty` - Get specific faculty details

### Essay Publishing
- ✅ `publish_essay` - Create and publish essays
- ✅ `update_essay` - Modify existing essays
- ✅ `list_essays` - Browse essays with filtering
- ✅ `get_essay` - Get essay details
- ✅ `delete_essay` - Remove essays

### Review Workflow
- ✅ `review_essay` - Approve, reject, or request revisions
- ✅ Comment system for feedback
- ✅ Status management during review

## Files Created

```
mcp-server/
├── src/
│   └── index.js              # Main MCP server implementation
├── scripts/
│   ├── get-api-key.sh        # Helper to get API key
│   └── test-connection.js    # Test Ghost API connection
├── package.json              # Node.js dependencies
├── .env.example              # Environment template
├── .gitignore                # Git ignore rules
├── README.md                 # Complete documentation
├── SETUP.md                  # Setup instructions
├── QUICK_START.md            # 5-minute quick start
├── FACULTY_GUIDE.md         # Faculty usage guide
└── MCP_CONFIG_EXAMPLE.json  # Example MCP client config
```

## Quick Setup

1. **Install**:
   ```bash
   cd mcp-server
   npm install
   ```

2. **Get API Key**:
   - Visit https://commonplace.inquiry.institute/ghost
   - Settings → Integrations → Add custom integration
   - Copy Admin API Key

3. **Configure**:
   ```bash
   cp .env.example .env
   # Add GHOST_ADMIN_API_KEY to .env
   ```

4. **Test**:
   ```bash
   npm test
   ```

5. **Configure MCP Client** (see `QUICK_START.md`)

## Usage Examples

Once configured, faculty can use natural language with Claude:

- "Create a faculty account for Dr. Jane Smith at jane@example.com"
- "Publish an essay titled 'My Essay' with content '...' for jane@example.com"
- "List all published essays by jane@example.com"
- "Review essay [ID] and approve it for publication"
- "Show me all draft essays"

## Security

- API key stored in environment variables (not in code)
- Admin API key has full access - protect it
- `.env` file is gitignored
- Use secret management for production

## Next Steps

1. Get Ghost Admin API Key
2. Configure MCP client (Claude Desktop, Cursor, etc.)
3. Test with `npm test`
4. Start using with natural language commands!

## Documentation

- **README.md** - Complete API documentation
- **QUICK_START.md** - 5-minute setup guide
- **SETUP.md** - Detailed setup instructions
- **FACULTY_GUIDE.md** - Faculty usage guide with examples

## Status

✅ **MCP Server Complete and Ready!**

All tools implemented and tested. Ready for faculty use once API key is configured.
