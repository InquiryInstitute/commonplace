# Create Persona Accounts

## Using MCP Tool

The MCP server has a `create_persona_account` tool that can create Ghost accounts for faculty personas.

### Via MCP Client (Claude, etc.)

Simply ask:
```
"Create a persona account for John Locke"
```

Or:
```
"Create persona accounts for all faculty (Locke, Arendt, Marx, Austen)"
```

### Tool Details

**Tool**: `create_persona_account`

**Parameters**:
- `faculty_lastname` (required): e.g., "locke", "arendt", "marx", "austen"
- `full_name` (required): e.g., "John Locke"
- `bio` (optional): Custom bio, defaults to persona description

**Example**:
```json
{
  "tool": "create_persona_account",
  "arguments": {
    "faculty_lastname": "locke",
    "full_name": "John Locke",
    "bio": "Empiricist philosopher. Content generated in the persona of John Locke using AI."
  }
}
```

## Persona Email Mapping

The system automatically maps faculty to persona emails:
- `locke` → `a.locke@inquiry.institute`
- `arendt` → `h.arendt@inquiry.institute`
- `marx` → `k.marx@inquiry.institute`
- `austen` → `j.austen@inquiry.institute`

## After Creating Accounts

Once persona accounts are created, they can:
- ✅ Publish essays (via `write_essay_in_persona` with `auto_publish=true`)
- ✅ Comment on posts
- ✅ Have their own author pages
- ✅ Be tagged in content

## Setup Required

The MCP server needs `GHOST_ADMIN_API_KEY` in `mcp-server/.env`:

```bash
GHOST_ADMIN_API_KEY=your-api-key-here
```

Get it from: Ghost Admin → Settings → Integrations → Custom Integration → Admin API Key
