# Faculty Guide: Using Commonplace MCP

This guide explains how faculty can use the Commonplace MCP (Model Context Protocol) server to manage accounts, publish essays, and review content.

## What is MCP?

MCP (Model Context Protocol) allows AI assistants (like Claude) to interact with Commonplace directly. You can ask Claude to:
- Create faculty accounts
- Publish your essays
- Review other faculty's essays
- Manage content

## Getting Started

### 1. Ensure MCP Server is Configured

The MCP server should already be set up by your administrator. If not, see `SETUP.md`.

### 2. Using with Claude Desktop

Once configured, you can simply ask Claude:

**Create an account:**
> "Create a faculty account for Dr. Jane Smith at jane.smith@inquiry.institute with Author role"

**Publish an essay:**
> "Publish an essay titled 'The Future of Inquiry' with this content: [your essay content] as a draft for jane.smith@inquiry.institute"

**Review an essay:**
> "Review essay [ID] and approve it for publication with the comment 'Excellent work!'"

**List essays:**
> "Show me all published essays by jane.smith@inquiry.institute"

## Common Tasks

### Creating Faculty Accounts

**Request:**
> "Create a faculty account for [Name] at [email] with [Role]"

**Roles available:**
- **Administrator**: Full access
- **Editor**: Can edit all content
- **Author**: Can publish their own content
- **Contributor**: Can write but needs approval

### Publishing Essays

**Request:**
> "Publish an essay titled '[Title]' with content '[your content]' for [author-email]"

**Options:**
- Status: `draft`, `published`, or `scheduled`
- Tags: Add tags like "pedagogy", "research", etc.
- Excerpt: Short summary
- Featured: Make it a featured post

**Example:**
> "Publish an essay titled 'Inquiry-Based Learning' with content '<p>This is my essay...</p>' for jane.smith@inquiry.institute as a draft with tags 'pedagogy' and 'teaching'"

### Reviewing Essays

**Actions:**
- **Approve**: Approve for publication
- **Reject**: Reject with feedback
- **Request Revision**: Ask for changes
- **Update**: Make edits directly

**Request:**
> "Review essay [ID] and [action] with comment '[your feedback]'"

**Example:**
> "Review essay 67890abcdef and approve it for publication with the comment 'Great work! Ready to publish.'"

### Listing Content

**List all essays:**
> "Show me all essays"

**Filter by author:**
> "Show me all essays by jane.smith@inquiry.institute"

**Filter by status:**
> "Show me all draft essays"

**Filter by tag:**
> "Show me all essays tagged 'pedagogy'"

### Getting Essay Details

**Request:**
> "Get details for essay [ID]" or "Get essay with slug [slug]"

### Updating Essays

**Request:**
> "Update essay [ID] with [changes]"

**Example:**
> "Update essay 67890abcdef to change the title to 'New Title' and add tag 'updated'"

## Best Practices

1. **Always specify author email** when publishing - this ensures the essay is attributed correctly
2. **Use draft status first** - Publish as draft, then review before making public
3. **Add meaningful tags** - Helps organize and find content
4. **Include excerpts** - Makes essays more discoverable
5. **Review before publishing** - Use the review workflow for quality control

## Workflow Example

1. **Faculty writes essay** → Uses MCP to publish as draft
2. **Editor reviews** → Uses MCP to review and provide feedback
3. **Revisions made** → Faculty updates essay based on feedback
4. **Final approval** → Editor approves and publishes
5. **Essay goes live** → Available on Commonplace

## Troubleshooting

### "Author not found"
- Verify the email address is correct
- Ensure the faculty account exists in Ghost
- Check that the account hasn't been deleted

### "Permission denied"
- Verify you have the correct API key
- Check that the API key has admin permissions
- Contact administrator if issues persist

### "Essay not found"
- Verify the essay ID is correct
- Check that the essay hasn't been deleted
- Ensure you're using the correct ID format

## Support

For issues or questions:
- Check the main README.md
- Review SETUP.md for configuration
- Contact the Inquiry Institute technical team
