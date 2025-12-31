# Commonplace Ghost MCP Server

MCP (Model Context Protocol) server for Ghost CMS operations, enabling faculty to create accounts, publish essays, review content, and manage the Commonplace site.

## Features

### Account Management
- **Create Faculty Accounts**: Create new faculty member accounts with appropriate roles
- **List Faculty**: View all faculty members with filtering options
- **Get Faculty Details**: Retrieve specific faculty member information

### Essay Publishing
- **Publish Essay**: Create and publish new essays/posts
- **Update Essay**: Modify existing essays
- **List Essays**: Browse essays with filtering (author, status, tags, date)
- **Get Essay**: Retrieve specific essay details
- **Delete Essay**: Remove essays (with caution)

### Review Workflow
- **Review Essay**: Approve, reject, or request revisions on essays
- **Add Comments**: Include review feedback and comments
- **Status Management**: Change publication status during review

## Installation

### Prerequisites

- Node.js >= 18.0.0
- Ghost Admin API Key (see setup below)

### Setup

1. **Install dependencies**:
   ```bash
   cd mcp-server
   npm install
   ```

2. **Get Ghost Admin API Key**:
   - Log in to Ghost admin: https://commonplace.inquiry.institute/ghost
   - Go to **Settings** > **Integrations**
   - Click **Add custom integration**
   - Name it "MCP Server" or similar
   - Copy the **Admin API Key**

3. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env and add your GHOST_ADMIN_API_KEY
   ```

4. **Test the server**:
   ```bash
   npm start
   ```

## MCP Client Configuration

Add this to your MCP client configuration (e.g., Claude Desktop):

```json
{
  "mcpServers": {
    "commonplace-ghost": {
      "command": "node",
      "args": ["/path/to/commonplace/mcp-server/src/index.js"],
      "env": {
        "GHOST_URL": "https://commonplace.inquiry.institute",
        "GHOST_ADMIN_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

Or use environment variables from `.env` file.

## Available Tools

### `create_faculty_account`
Create a new faculty account in Ghost.

**Parameters**:
- `name` (string, required): Full name of the faculty member
- `email` (string, required): Email address
- `role` (string, optional): Role - "Administrator", "Editor", "Author", or "Contributor" (default: "Author")
- `send_invite` (boolean, optional): Send invitation email (default: true)

**Example**:
```json
{
  "name": "Dr. Jane Smith",
  "email": "jane.smith@inquiry.institute",
  "role": "Author",
  "send_invite": true
}
```

### `publish_essay`
Publish a new essay/post.

**Parameters**:
- `title` (string, required): Essay title
- `content` (string, required): HTML or Markdown content
- `author_email` (string, required): Author's email (must be existing Ghost user)
- `status` (string, optional): "draft", "published", or "scheduled" (default: "draft")
- `tags` (array, optional): Array of tag names
- `excerpt` (string, optional): Short excerpt
- `featured` (boolean, optional): Feature this essay (default: false)
- `published_at` (string, optional): ISO 8601 date for scheduling

**Example**:
```json
{
  "title": "The Future of Inquiry-Based Learning",
  "content": "<p>This is the essay content...</p>",
  "author_email": "jane.smith@inquiry.institute",
  "status": "draft",
  "tags": ["pedagogy", "inquiry"],
  "excerpt": "Exploring new approaches to inquiry-based learning"
}
```

### `review_essay`
Review an essay with actions like approve, reject, or request revision.

**Parameters**:
- `post_id` (string, required): Post ID
- `action` (string, required): "approve", "reject", "request_revision", or "update"
- `comment` (string, optional): Review comment/feedback
- `status` (string, optional): New status for approve/update actions
- `content_updates` (object, optional): Partial content updates

**Example**:
```json
{
  "post_id": "67890abcdef",
  "action": "approve",
  "comment": "Excellent work! Ready for publication.",
  "status": "published"
}
```

### `list_essays`
List essays with filtering options.

**Parameters**:
- `author_email` (string, optional): Filter by author
- `status` (string, optional): "all", "draft", "published", "scheduled" (default: "all")
- `tag` (string, optional): Filter by tag name
- `limit` (number, optional): Max results (default: 15, max: 100)
- `page` (number, optional): Page number (default: 1)
- `order` (string, optional): Sort order (default: "published_at DESC")

### `get_essay`
Get details of a specific essay.

**Parameters**:
- `post_id` (string, optional): Post ID
- `slug` (string, optional): Post slug (alternative to post_id)
- `include` (array, optional): Additional data to include

### `update_essay`
Update an existing essay.

**Parameters**:
- `post_id` (string, required): Post ID
- `title` (string, optional): New title
- `content` (string, optional): Updated content
- `status` (string, optional): New status
- `tags` (array, optional): Updated tags
- `excerpt` (string, optional): Updated excerpt
- `featured` (boolean, optional): Featured status

### `delete_essay`
Delete an essay (use with caution).

**Parameters**:
- `post_id` (string, required): Post ID

### `list_faculty`
List all faculty members.

**Parameters**:
- `role` (string, optional): Filter by role (default: "all")
- `status` (string, optional): Filter by status (default: "all")
- `limit` (number, optional): Max results (default: 15)

### `get_faculty`
Get details of a specific faculty member.

**Parameters**:
- `email` (string, optional): Email address
- `user_id` (string, optional): User ID (alternative to email)

## Usage Examples

### Create a Faculty Account
```javascript
// Via MCP client
{
  "tool": "create_faculty_account",
  "arguments": {
    "name": "Dr. John Doe",
    "email": "john.doe@inquiry.institute",
    "role": "Author",
    "send_invite": true
  }
}
```

### Publish an Essay
```javascript
{
  "tool": "publish_essay",
  "arguments": {
    "title": "My First Essay",
    "content": "<h1>Introduction</h1><p>This is my essay...</p>",
    "author_email": "john.doe@inquiry.institute",
    "status": "draft",
    "tags": ["essay", "first-post"]
  }
}
```

### Review and Approve Essay
```javascript
{
  "tool": "review_essay",
  "arguments": {
    "post_id": "67890abcdef",
    "action": "approve",
    "comment": "Great work! Approved for publication.",
    "status": "published"
  }
}
```

## Security

- **API Key**: Store the Ghost Admin API Key securely (use environment variables or secret management)
- **Permissions**: The API key has full admin access - protect it accordingly
- **Rate Limiting**: Ghost API has rate limits - be mindful of request frequency

## Troubleshooting

### "Resource not found" errors
- Verify the Ghost URL is correct
- Check that the API key is valid
- Ensure the Ghost site is accessible

### "User not found" errors
- Verify the email address is correct
- Check that the user exists in Ghost
- Ensure proper role permissions

### Authentication errors
- Verify the Admin API Key is correct
- Check that the key hasn't been revoked
- Ensure the key format is correct (no extra spaces)

## Development

### Run in development mode
```bash
npm run dev
```

### Test individual tools
Use an MCP client or test directly with the Ghost API.

## License

MIT
