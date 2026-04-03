# Phase 2: Button System + Detail Pages Theme Migration

## Overview

Migrate all 6 button patterns to Theme-backed styles, update detail pages to use theme tokens, and retroactively fix buttons in Phase 1 files.

---

### Part A: Expand Theme + Create Button Styles

**Theme.swift additions:**

- Add `Theme.Colors.brandRed` reference for button use (already exists, just ensuring consistency)
- Add `Theme.ButtonSize.verticalPadding` (14pt for full-width, 12pt for compact)
- Add `Theme.ButtonSize.minHeight` (44pt touch target)

**ButtonStyles.swift — 6 new/updated styles:**

1. **PrimaryButtonStyle** (update existing) — Full-width capsule, `Color.primary` fill, inverted text, 14pt vertical padding, pressed opacity 0.85
2. **SecondaryButtonStyle** (update existing) — Full-width capsule, 1pt separator stroke, 14pt vertical padding, pressed opacity 0.7
3. **TextLinkButtonStyle** (new) — No background, `brandRed` foreground, bold subheadline, with chevron icon support
4. **SmallPillButtonStyle** (new) — Inline capsule, `Color.primary` fill, inverted text, 12pt vertical / 18pt horizontal padding (for "Estimate my rate" type buttons)
5. **ActionCircleButtonStyle** (new) — 44×44 circle with 1pt separator stroke, 16pt medium icon (for share/save/more row)
6. **IconCircleButtonStyle** (new) — 44×44 solid circle, `Color.primary` fill, inverted icon (for send/stop/waveform buttons in chat input)

Each will use Theme tokens for spacing, typography, colors, and radius.

---

### Part B: Retroactive Button Migration (Phase 1 files)

**MyHomeView.swift:**

- "Add address" button → use `PrimaryButtonStyle` variant or Theme tokens for its inline styling (currently uses `Color(white: 0.15)` with hardcoded corner radius)

---

### Part C: Detail Page Migration — ListingDetailView.swift

Replace hardcoded values with Theme tokens:

- `Color(.systemBackground)` → `Theme.Colors.background`
- `Color(.secondarySystemBackground)` → `Theme.Colors.secondaryBackground`
- `Color(.tertiarySystemBackground)` → `Theme.Colors.tertiaryBackground`
- Corner radii (`12`, `16`, `18`) → `Theme.Radius.medium`, `.large`, `.xl`
- Spacing values (`6`, `8`, `10`, `12`, `16`, `20`) → `Theme.Spacing` tokens
- Typography (`.largeTitle.bold()`, `.title3.bold()`, `.subheadline`, etc.) → `Theme.Typography` tokens
- Shadow → `Theme.Shadow` tokens
- `Color(red: 0.78, green: 0.13, blue: 0.13)` → `Theme.Colors.brandRed`
- "Request showing" button → Theme button tokens
- "Continue reading" link → `TextLinkButtonStyle` or Theme tokens
- Disclosure rows → Theme spacing/typography tokens
- Key facts card, hot home badge, highlights section → Theme tokens

---

### Part D: Detail Page Migration — RedfinDetailView.swift

Replace hardcoded values with Theme tokens:

- `private let redfinRed` → `Theme.Colors.brandRed`
- All `Color(.systemBackground)`, `Color(.secondarySystemBackground)`, `Color(.separator)` → Theme color tokens
- All inline button styles:
  - "Request showing" → `PrimaryButtonStyle`
  - "Estimate my rate" → `SmallPillButtonStyle`
  - "Tour in person" / "Estimate my payment & rate" → `PrimaryButtonStyle`
  - "Tour via video chat" / "Full property details" / "Let's chat" → `SecondaryButtonStyle`
  - "Continue reading" → `TextLinkButtonStyle`
  - "How is this calculated?" → text link with Theme tokens
  - Share/save/more action circles → `ActionCircleButtonStyle`
- Chart colors → `Theme.Colors.Chart` tokens (already defined)
- Spacing, typography, corner radii → Theme tokens throughout
- Lifestyle pills stroke → Theme separator/radius tokens
- Section divider padding → Theme spacing

---

### Part E: PhotoViewerView.swift Migration

- "Request showing" button → Theme tokens + `Theme.Colors.brandRed`
- Spacing values → Theme tokens
- Already uses `GlassActionButton` (which uses Theme) — minimal changes needed

---

### What stays the same visually

Everything should look identical after migration. The only possible micro-differences:

- MyHomeView "Add address" button corner radius (currently 10pt) will snap to nearest theme token or get a new one
- Any `Color(red: 0.78, green: 0.13, blue: 0.13)` replaced with `Theme.Colors.brandRed` (same color value)

