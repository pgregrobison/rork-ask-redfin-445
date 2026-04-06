# Create a reusable Tag component using theme tokens

## What's changing

A new reusable **Tag** component will be created and applied everywhere tags/chips appear in the app. All styling will use theme tokens — no hardcoded values.

### Tag Design
- **Background:** Filled with the tertiary background color
- **Corner radius:** Uses the smallest theme radius (`xs` = 4pt)
- **Font:** Single universal size — caption weight
- **Padding:** Horizontal `xs` (8pt), vertical `xxs` (4pt)
- **Shape:** Rounded rectangle (not capsule), using the `xs` radius

### New Theme Tokens
- A `Tag` section inside the Theme for tag-specific spacing and styling tokens (font, horizontal padding, vertical padding, radius, background color, grid minimum width, grid spacing) so everything is centralized

### New Reusable Component
- **`TagView`** — a single tag pill showing one text label, fully styled from theme tokens
- **`TagGrid`** — a wrapping grid layout of tags (used on detail pages where tags wrap into multiple rows)
- **`TagRow`** — a horizontal row of tags with a max count (used on home cards where space is limited)

### Where it gets applied
1. **Home cards** (list view & map overlay) — replace the inline tag styling in `HomeCardInfoSection` with `TagRow`
2. **`ListingDetailView`** highlights section — replace inline tag grid with `TagGrid`
3. **`RedfinDetailView`** highlights section — replace inline outlined tag grid with `TagGrid`
4. **Any other places** with similar patterns (e.g. `ListingCardOverlay` if applicable)

### Visual result
- Home cards look the same (filled tags, small size, horizontal row)
- Detail pages will now use the **filled + xs radius** style consistently (replacing the outlined style on `RedfinDetailView`)
- All tags across the app will look unified