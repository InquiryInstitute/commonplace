# Tag Structure Quick Start

## Setup in 2 Steps

### 1. Run Setup Script

```bash
./scripts/setup-tag-structure.sh
```

You'll need your Ghost Admin API Key:
- Visit https://commonplace.inquiry.institute/ghost
- Settings → Integrations → Copy Admin API Key

This creates:
- ✅ Primary "Faculty" tag
- ✅ College tags (ARTS, SOCI, META, HIST, PHIL, LIT)
- ✅ Format tags (Essay, Salon, Review, Dialogue)

### 2. Create Individual Faculty Tags

**Via MCP Server** (recommended):
```
"Create a faculty tag for Arendt"
```

**Via Ghost Admin**:
1. Settings → Tags → New Tag
2. Name: "Arendt" (or "Hannah Arendt")
3. Slug: `faculty-arendt`
4. Parent: Select "Faculty"
5. Save

## Usage

### When Publishing Content

Always include these tags:
1. **Faculty** (primary)
2. **College** (e.g., ARTS, SOCI)
3. **Format** (e.g., Essay, Dialogue)
4. **Individual faculty tag** (e.g., faculty-arendt)

### URL Examples

After setup, content will be accessible at:
- `/tag/faculty/` - All faculty content
- `/tag/faculty-arendt/` - Arendt's content
- `/tag/faculty-arendt/dialogue/` - Arendt's dialogues
- `/tag/faculty/arts/` - All ARTS college content

## Done! ✅

Your tag structure is ready. See `TAG_STRUCTURE.md` for complete documentation.
