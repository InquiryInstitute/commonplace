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
/* Commonplace Handwriting Font - Essay Content Only */
:root {
  --font-handwriting: 'Kalam', cursive;
}

/* Apply to essay/post titles */
.post-title,
.post-card-title,
.post-header h1,
.gh-post-title {
  font-family: var(--font-handwriting) !important;
}

/* Apply to essay/post content */
.post-content,
.post-content p,
.post-content h1,
.post-content h2,
.post-content h3,
.post-content h4,
.post-content h5,
.post-content h6,
.gh-content,
.gh-content p {
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

Your essay content and titles now use a handwriting font.
Navigation and UI elements remain with the default font.

See `HANDWRITING_FONT.md` for more customization options.
