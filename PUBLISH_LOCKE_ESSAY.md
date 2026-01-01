# Publish Locke Essay to Ghost

## Essay Ready

The Locke essay has been generated and is ready to publish:
- **File**: `locke-essay-response.json`
- **Title**: "On the Nature and Utility of the Common‑place Book, and a Proposal for a Modern Digital Repository for the Faculty"
- **Word Count**: 2,651 words
- **Author**: John Locke (persona)

## To Publish

### Option 1: Using MCP Tool (Recommended)

If your MCP server is configured with Ghost API key:

```
"Publish the Locke essay from locke-essay-response.json to Ghost"
```

Or use the tool directly:
```json
{
  "tool": "publish_essay",
  "arguments": {
    "title": "On the Nature and Utility of the Common‑place Book...",
    "content": "[essay content from JSON]",
    "author_email": "your-email@inquiry.institute",
    "tags": ["faculty-locke", "essay"],
    "status": "draft"
  }
}
```

### Option 2: Using Python Script

```bash
export GHOST_ADMIN_API_KEY=your-api-key
python3 publish-locke-essay.py
```

### Option 3: Manual via Ghost Admin

1. Go to https://commonplace.inquiry.institute/ghost
2. Click "New post"
3. Copy title and content from `locke-essay.txt`
4. Add tags: `faculty-locke`, `essay`, `Faculty`
5. Save as draft or publish

## Tags Needed

- `faculty-locke` (will be created if doesn't exist)
- `essay` (format tag)
- `Faculty` (primary tag)

## Next Steps After Publishing

1. Review the essay in Ghost admin
2. Edit title if desired
3. Add excerpt/summary
4. Publish when ready
