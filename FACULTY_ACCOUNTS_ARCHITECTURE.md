# Faculty Accounts Architecture

## Question: Should Faculty Personas Have Ghost Accounts?

### Current Situation

The essay generation system creates essays in the persona of historical faculty (Locke, Arendt, Marx, Austen). These are:
- **Historical figures** (not living people)
- **AI-generated content** in their style
- **Attributed to them** but not actually written by them

### Options

#### Option 1: No Accounts for Historical Personas (Recommended)

**Approach**: Essays are published under a generic "Commonplace" author or the actual faculty member who commissioned them.

**Pros**:
- Clear that these are AI-generated, not authentic historical writings
- No confusion about who actually wrote them
- Simpler account management
- Historical figures don't need login credentials

**Cons**:
- Less clear attribution in Ghost UI
- Need to handle attribution in content/tags instead

**Implementation**:
- Publish essays under a "Commonplace Editor" or "AI Generated" author account
- Use tags (`faculty-locke`, `faculty-arendt`) for attribution
- Include attribution in essay content: "By John Locke (persona)" or "In the style of John Locke"

#### Option 2: Create Accounts for Personas

**Approach**: Create Ghost user accounts for each historical faculty persona.

**Pros**:
- Clear attribution in Ghost
- Can have dedicated author pages
- Better organization

**Cons**:
- Confusing (these aren't real people who can log in)
- Clutters user list
- May mislead readers about authenticity

#### Option 3: Hybrid - Real Faculty Accounts Only

**Approach**: Only create accounts for actual living faculty members. Historical persona essays are published under the commissioning faculty member's account.

**Pros**:
- Clear who commissioned/generated the content
- Real faculty can manage their generated essays
- Historical personas are clearly AI-generated

**Cons**:
- Attribution to historical figure is less prominent
- Need to track who commissioned what

### Recommended Approach

**Option 1 with Enhancement**:

1. **Create a "Commonplace" or "AI Generated" author account** for persona essays
2. **Use tags for attribution**: `faculty-locke`, `faculty-arendt`, etc.
3. **Include clear attribution in content**: "In the persona of John Locke" or "By John Locke (AI-generated persona)"
4. **For real faculty**: Create actual accounts when they join
5. **Real faculty can commission essays** in historical personas, and they appear under their account OR the Commonplace account

### Implementation

#### For Historical Persona Essays:
- Author: "Commonplace" or "AI Generated" account
- Tags: `faculty-locke`, `essay`, `Faculty`
- Content: Includes "By John Locke (persona)" or "In the style of John Locke"

#### For Real Faculty Essays:
- Author: Actual faculty member's account
- Tags: `faculty-[lastname]`, `essay`, `Faculty`, plus college/format tags
- Content: Written by the actual faculty member

### Questions to Consider

1. **Who is the audience?** 
   - If it's clear these are AI-generated persona essays, Option 1 works
   - If you want to present them as "written by" the historical figure, Option 2 might be better

2. **Will real faculty use this?**
   - If yes, they should have accounts
   - Historical personas probably shouldn't

3. **Attribution clarity?**
   - Tags + content attribution (Option 1) vs. Author account (Option 2)

### Recommendation

**Use Option 1**: 
- Create one "Commonplace" author account for AI-generated persona essays
- Create real accounts only for actual faculty members
- Use tags and content attribution to indicate the historical persona
- This keeps it clear that persona essays are AI-generated, not authentic historical writings
