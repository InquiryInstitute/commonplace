# Commonplace Tag Structure

## Overview

Commonplace uses a hierarchical tag structure to organize faculty content by college, format, and series.

## Tag Hierarchy

### Primary Tag
- **Faculty** (`/tag/faculty/`)
  - Primary tag for all faculty content
  - All other tags are children of Faculty

### Secondary Tags

#### Colleges
- **ARTS** (`/tag/faculty/arts/`) - College of Arts
- **SOCI** (`/tag/faculty/soci/`) - College of Social Sciences
- **META** (`/tag/faculty/meta/`) - College of Metaphysics
- **HIST** (`/tag/faculty/hist/`) - College of History
- **PHIL** (`/tag/faculty/phil/`) - College of Philosophy
- **LIT** (`/tag/faculty/lit/`) - College of Literature

#### Formats
- **Essay** (`/tag/faculty/essay/`) - Essay format
- **Salon** (`/tag/faculty/salon/`) - Salon format
- **Review** (`/tag/faculty/review/`) - Review format
- **Dialogue** (`/tag/faculty/dialogue/`) - Dialogue format

#### Series
- Created as needed for specific series
- Examples: "Dialogues on Democracy", "Modern Philosophy Series"

### Individual Faculty Tags
- Created per faculty member
- Format: `faculty-[lastname]` (e.g., `faculty-arendt`, `faculty-marx`)
- Child of "Faculty" tag
- Used for faculty-specific landing pages

## URL Patterns

### Tag URLs
- `/tag/faculty/` - All faculty content
- `/tag/faculty-arendt/` - Content by Arendt
- `/tag/faculty-marx/` - Content by Marx
- `/tag/faculty-arendt/dialogues/` - Arendt's dialogues
- `/tag/faculty-marx/essays/` - Marx's essays
- `/tag/faculty/arts/` - All ARTS college content
- `/tag/faculty/essay/` - All essays

### Custom Landing Pages
- `/faculty/austen` - Curated landing page for Austen
- `/faculty/marx` - Curated landing page for Marx

**Note**: Custom landing pages require theme customization or custom routes.

## Usage Guidelines

### When Publishing Content

1. **Always include "Faculty" tag** - This is the primary tag
2. **Add College tag** - Select appropriate college (ARTS, SOCI, META, etc.)
3. **Add Format tag** - Select format (Essay, Salon, Review, Dialogue)
4. **Add Faculty-specific tag** - Create or use existing (e.g., `faculty-arendt`)
5. **Add Series tag** (if applicable) - For content in a series

### Example: Publishing an Essay

**Title**: "On Revolution"  
**Author**: Hannah Arendt  
**Tags**:
- Faculty (primary)
- ARTS (college)
- Essay (format)
- faculty-arendt (individual)
- "Political Theory Series" (series, if applicable)

**Resulting URLs**:
- `/tag/faculty/` - Shows this essay
- `/tag/faculty-arendt/` - Shows all Arendt content
- `/tag/faculty/arts/` - Shows all ARTS content
- `/tag/faculty/essay/` - Shows all essays
- `/tag/faculty-arendt/essay/` - Shows Arendt's essays

## Setting Up Tags

### Initial Setup

Run the setup script:
```bash
./scripts/setup-tag-structure.sh
```

This creates:
- Primary "Faculty" tag
- All college tags
- All format tags

### Creating Individual Faculty Tags

**Via Ghost Admin**:
1. Go to Settings → Tags
2. Click "New Tag"
3. Name: "Arendt" (or "Hannah Arendt")
4. Slug: `faculty-arendt`
5. Parent: Select "Faculty"
6. Save

**Via MCP Server** (if available):
```javascript
{
  "tool": "create_tag",
  "arguments": {
    "name": "Arendt",
    "slug": "faculty-arendt",
    "parent": "faculty"
  }
}
```

### Creating Series Tags

Create as needed:
- Name: "Dialogues on Democracy"
- Slug: `dialogues-on-democracy`
- Parent: "Faculty" (or specific format tag)

## URL Structure Details

### Ghost's Default Tag URLs

Ghost automatically creates URLs based on tag slugs:
- Tag slug: `faculty-arendt` → `/tag/faculty-arendt/`
- Tag slug: `faculty` → `/tag/faculty/`

### Multiple Tags in URL

Ghost supports filtering by multiple tags:
- `/tag/faculty-arendt/` - Shows content with `faculty-arendt` tag
- `/tag/faculty-arendt/essay/` - Shows content with both `faculty-arendt` AND `essay` tags

### Custom Landing Pages

For custom routes like `/faculty/austen`, you'll need:
1. **Theme customization** - Add custom routes in theme
2. **Or custom routing** - Use Ghost's routing.yaml (if supported)
3. **Or static pages** - Create static pages that pull tagged content

## Best Practices

1. **Consistent Naming**: Use `faculty-[lastname]` format for faculty tags
2. **Always Use Primary Tag**: Every post should have "Faculty" tag
3. **Multiple Tags**: Use multiple tags to enable filtering
4. **Descriptive Slugs**: Use clear, lowercase slugs
5. **Parent Tags**: Set appropriate parent tags for hierarchy

## Examples

### Example 1: Essay by Arendt
```
Tags:
- Faculty (parent)
- ARTS (college)
- Essay (format)
- faculty-arendt (individual)
```

**Accessible at**:
- `/tag/faculty/`
- `/tag/faculty-arendt/`
- `/tag/faculty/arts/`
- `/tag/faculty/essay/`
- `/tag/faculty-arendt/essay/`

### Example 2: Dialogue by Marx
```
Tags:
- Faculty (parent)
- SOCI (college)
- Dialogue (format)
- faculty-marx (individual)
- "Dialogues on Democracy" (series)
```

**Accessible at**:
- `/tag/faculty/`
- `/tag/faculty-marx/`
- `/tag/faculty/soci/`
- `/tag/faculty/dialogue/`
- `/tag/faculty-marx/dialogue/`

## Maintenance

### Adding New Colleges
1. Go to Settings → Tags
2. Create new tag with college code (e.g., "STEM")
3. Set parent to "Faculty"
4. Update documentation

### Adding New Formats
1. Go to Settings → Tags
2. Create new tag (e.g., "Interview")
3. Set parent to "Faculty"
4. Update documentation

### Archiving Tags
- Don't delete tags (breaks URLs)
- Instead, mark as "Archived" or remove from active use

## Technical Notes

- Ghost uses tag slugs for URLs
- Multiple tags can be combined in URLs
- Parent-child relationships affect tag hierarchy
- Tag visibility can be set to public/private
- Tags can have descriptions and meta data

## Related Documentation

- Ghost Tags: https://ghost.org/docs/content/themes/#tags
- Ghost Routing: https://ghost.org/docs/themes/routing/
- Setup Script: `scripts/setup-tag-structure.sh`
