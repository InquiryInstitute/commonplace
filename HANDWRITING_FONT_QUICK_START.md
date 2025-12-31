# Handwriting Font - Quick Start

## Easiest Method

### Run the Simple Script

```bash
./scripts/add-handwriting-font-simple.sh
```

This will show you exactly what code to paste into Ghost Admin.

### Manual Steps

1. **Go to Ghost Admin**:
   - Visit https://commonplace.inquiry.institute/ghost
   - Settings → Code Injection

2. **Paste this code into "Site Header"**:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Kalam:wght@300;400;700&display=swap" rel="stylesheet">
<style>
:root {
  --font-handwriting: 'Kalam', cursive;
}

h1, h2, h3, h4, h5, h6,
.post-title,
.post-card-title,
.gh-head-title,
.gh-head-menu a {
  font-family: var(--font-handwriting) !important;
}
</style>
```

3. **Click "Save"**

4. **Visit your site** - The handwriting font is now active!

## Other Font Options

Replace the font URL and family name:

- **Caveat**: `https://fonts.googleapis.com/css2?family=Caveat:wght@400;700&display=swap` → `'Caveat', cursive`
- **Permanent Marker**: `https://fonts.googleapis.com/css2?family=Permanent+Marker&display=swap` → `'Permanent Marker', cursive`
- **Shadows Into Light**: `https://fonts.googleapis.com/css2?family=Shadows+Into+Light&display=swap` → `'Shadows Into Light', cursive`

## Done! ✅

Your headings and titles now use a handwriting font.

See `HANDWRITING_FONT.md` for more customization options.
