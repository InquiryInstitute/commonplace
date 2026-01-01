# Ghost API Key Format

## Admin API Key Format

Ghost Admin API keys can be in different formats:

### Format 1: Simple String
```
abc123def456ghi789...
```
Use as: `Authorization: Ghost abc123def456ghi789...`

### Format 2: ID:Secret Format
```
6955d801e022c30001e49c4f:632c918ff1fcacd89c582212b1c253e391e0ff3eb8d366f000b229830fbf2741
```
This appears to be in `id:secret` format.

**Try using just the secret part** (after the colon):
```
632c918ff1fcacd89c582212b1c253e391e0ff3eb8d366f000b229830fbf2741
```

Or use the full string as provided.

## Testing the Key

Test if the key works:

```bash
curl -X GET "https://commonplace.inquiry.institute/ghost/api/admin/site/" \
  -H "Authorization: Ghost YOUR_KEY"
```

If you get site info, the key works. If you get "Invalid token", try:
1. Just the part after the colon
2. The full string as-is
3. Check if the key was copied correctly (no extra spaces)

## Common Issues

- **Extra spaces**: Make sure no spaces before/after the key
- **Wrong key type**: Make sure it's Admin API Key, not Content API Key
- **Key revoked**: Check if the integration still exists in Ghost admin

## Where to Find It

Ghost Admin → Settings → Integrations → Your Integration → **Admin API Key**

The key should be a long string (usually 64+ characters).
