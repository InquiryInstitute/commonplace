# Handwriting Font Setup for Commonplace

## Overview

Commonplace uses a handwriting font to give the site a more personal, literary feel. This document explains how to set up and customize the handwriting font.

## Quick Setup

### Option 1: Automated Script (Recommended)

```bash
./scripts/add-handwriting-font.sh
```

The script will:
1. Prompt for Ghost Admin API Key
2. Let you choose from popular handwriting fonts
3. Automatically inject CSS into your theme
4. Apply font to headings and titles

### Option 2: Manual Setup via Ghost Admin

1. **Get a handwriting font**:
   - Visit [Google Fonts](https://fonts.google.com/?category=Handwriting)
   - Popular choices: Kalam, Caveat, Permanent Marker, Shadows Into Light

2. **Go to Ghost Admin**:
   - Visit https://commonplace.inquiry.institute/ghost
   - Settings → Code Injection

3. **Add to Site Header**:
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

4. **Save** and refresh your site

## Popular Handwriting Fonts

### Kalam
- **Style**: Casual, readable
- **Best for**: General use, readable handwriting
- **URL**: `https://fonts.googleapis.com/css2?family=Kalam:wght@300;400;700&display=swap`
- **CSS**: `'Kalam', cursive`

### Caveat
- **Style**: Elegant, script-like
- **Best for**: Formal, literary feel
- **URL**: `https://fonts.googleapis.com/css2?family=Caveat:wght@400;700&display=swap`
- **CSS**: `'Caveat', cursive`

### Permanent Marker
- **Style**: Bold, marker-style
- **Best for**: Bold, attention-grabbing headings
- **URL**: `https://fonts.googleapis.com/css2?family=Permanent+Marker&display=swap`
- **CSS**: `'Permanent Marker', cursive`

### Shadows Into Light
- **Style**: Casual, friendly
- **Best for**: Approachable, warm feel
- **URL**: `https://fonts.googleapis.com/css2?family=Shadows+Into+Light&display=swap`
- **CSS**: `'Shadows Into Light', cursive`

### Indie Flower
- **Style**: Playful, rounded
- **Best for**: Light, friendly content
- **URL**: `https://fonts.googleapis.com/css2?family=Indie+Flower&display=swap`
- **CSS**: `'Indie Flower', cursive`

## Customization

### Apply to Different Elements

**Headings Only** (default):
```css
h1, h2, h3, h4, h5, h6,
.post-title,
.post-card-title {
  font-family: var(--font-handwriting) !important;
}
```

**Headings + Navigation**:
```css
h1, h2, h3, h4, h5, h6,
.post-title,
.post-card-title,
.gh-head-title,
.gh-head-menu a {
  font-family: var(--font-handwriting) !important;
}
```

**All Text** (use sparingly):
```css
body, p, .post-content {
  font-family: var(--font-handwriting) !important;
}
```

**Specific Elements Only**:
```css
.post-meta,
.post-author,
.post-date {
  font-family: var(--font-handwriting) !important;
}
```

### Font Weight

Adjust font weight for different elements:
```css
h1, .post-title {
  font-family: var(--font-handwriting) !important;
  font-weight: 700; /* Bold */
}

h2, h3 {
  font-family: var(--font-handwriting) !important;
  font-weight: 400; /* Regular */
}
```

### Font Size Adjustments

Some handwriting fonts may need size adjustments:
```css
h1 {
  font-family: var(--font-handwriting) !important;
  font-size: 2.5rem; /* Adjust as needed */
}
```

## Using Custom Fonts

### Self-Hosted Font

1. Upload font files to your theme or use a CDN
2. Add `@font-face` declaration:

```html
<style>
@font-face {
  font-family: 'Custom Handwriting';
  src: url('https://your-cdn.com/fonts/handwriting.woff2') format('woff2'),
       url('https://your-cdn.com/fonts/handwriting.woff') format('woff');
  font-weight: normal;
  font-style: normal;
}

:root {
  --font-handwriting: 'Custom Handwriting', cursive;
}
</style>
```

### Font Services

- **Google Fonts**: https://fonts.google.com/?category=Handwriting
- **Adobe Fonts**: Requires subscription
- **Font Squirrel**: Free fonts with web font generator

## Best Practices

1. **Readability First**: Choose fonts that are readable at body text sizes
2. **Use Sparingly**: Handwriting fonts work best for headings, not body text
3. **Test on Mobile**: Ensure font is readable on small screens
4. **Fallback Fonts**: Always include fallback (e.g., `cursive`)
5. **Performance**: Use `font-display: swap` for better loading

## Troubleshooting

### Font Not Appearing

1. **Check Code Injection**: Ensure code is in Site Header, not Site Footer
2. **Clear Cache**: Clear browser cache and Ghost cache
3. **Check Font URL**: Verify Google Fonts URL is correct
4. **Inspect Element**: Use browser dev tools to see if font is loading

### Font Too Small/Large

Adjust font sizes in CSS:
```css
h1 { font-size: 2.5rem; }
h2 { font-size: 2rem; }
```

### Font Not Loading

1. Check network tab in browser dev tools
2. Verify font URL is accessible
3. Check for CORS issues with custom fonts
4. Ensure `preconnect` links are present

## Current Configuration

To check current font settings:
1. Visit Ghost Admin → Settings → Code Injection
2. View Site Header section
3. Look for `--font-handwriting` variable

## Changing Fonts

To change the font:
1. Run the setup script again: `./scripts/add-handwriting-font.sh`
2. Or manually edit Settings → Code Injection → Site Header
3. Update the font URL and CSS variable

## Examples

See the site at https://commonplace.inquiry.institute to see the handwriting font in action.

## Related Documentation

- Google Fonts: https://fonts.google.com/
- Ghost Code Injection: https://ghost.org/docs/themes/code-injection/
- CSS Custom Properties: https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties
