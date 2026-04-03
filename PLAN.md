# Migrate Find Tab to Use Theme Design System Tokens

**Goal:** Replace all hardcoded colors, spacing, radii, fonts, and shadows across the Find tab and its components with centralized Theme tokens — without changing the visual appearance at all.

---

### Theme Token Additions

- **New radius token:** `Theme.Radius.xs` (4pt) for small elements, and `Theme.Radius.full` as a large value (e.g. 9999) for fully-rounded / capsule-like corners
- **New spacing token:** None needed — existing `xxs` through `xxl` cover all current values
- **Badge colors:** Wire up `Theme.Colors.Badge` tokens (already defined) to replace hardcoded badge colors in `HomeCardBadge`
- **Map pin colors:** Wire up `Theme.Colors.MapPin` tokens (already defined) to replace hardcoded RGB values in `MapPinView`
- **Typography:** Map `HomeCardSize` fonts to `Theme.Typography` tokens (e.g. `.title2.bold()` → `Theme.Typography.sectionTitle`)
- **Card photo heights / widths:** Add `Theme.CardSize` tokens for the three card size variants (large/medium/compact photo heights, fixed widths, info padding)

---

### Files Changed

**Theme.swift** — Add new tokens:
- `Radius.xs` (4pt) and `Radius.full` (9999pt for fully rounded)
- `CardSize` enum with photo height, fixed width, info padding, and font mappings per size variant — centralizing what's currently in `HomeCardSize`
- Shadow: add an `overlay` shadow preset matching the current listing card overlay shadow

**FindListView.swift** — Replace:
- `spacing: 16` → `Theme.Spacing.md`
- `.padding(.horizontal, 16)` → `Theme.Spacing.md`
- `.padding(.bottom, 100)` → leave as-is (layout-specific, not a design token)
- `Color(.systemBackground)` → `Theme.Colors.background`

**FindMapView.swift** — Replace:
- `.padding(.trailing, 16)` → `Theme.Spacing.md`
- `.padding(.top, 8)` → `Theme.Spacing.xs`
- Animation spring values left as-is (motion, not a design token)

**HomeCard.swift** — Replace:
- `HomeCardSize` corner radii → `Theme.Radius` tokens
- Photo heights, fixed widths, fonts, info padding → `Theme.CardSize` tokens
- `Color(.secondarySystemBackground)` → `Theme.Colors.secondaryBackground`
- `Color(.tertiarySystemBackground)` → `Theme.Colors.tertiaryBackground`
- Badge padding and corner radius → `Theme.Spacing` and `Theme.Radius` tokens
- `HomeCardBadge.color` → `Theme.Colors.Badge` tokens

**HomeCardInfoSection.swift** — Replace:
- Spacing values (6, 8) → `Theme.Spacing` tokens
- `.padding(.trailing, 12)` → `Theme.Spacing.sm`
- Tag background `Color(.tertiarySystemBackground)` → `Theme.Colors.tertiaryBackground`
- Tag padding → `Theme.Spacing` tokens

**ListingCardOverlay.swift** — Replace:
- `Color(.secondarySystemBackground)` → `Theme.Colors.secondaryBackground`
- `Color(.tertiarySystemBackground)` → `Theme.Colors.tertiaryBackground`
- Card shadow → `Theme.Shadow.overlay` (new token)
- `.frame(height: 220)` → card size photo height token
- Padding values (8, 12, 20) → `Theme.Spacing` tokens
- Badge styling → same Theme tokens as HomeCard

**MapPinView.swift** — Replace:
- Hardcoded RGB colors → `Theme.Colors.MapPin` tokens (already defined, just not wired up)
- Font size 13 → closest Theme token or keep as map-pin-specific
- Padding values → `Theme.Spacing` tokens
- Shadow → `Theme.Shadow.subtle` (close match)

**UserLocationDot.swift** — Replace:
- Frame sizes (44, 16, 12) → Theme tokens where applicable
- `Color.blue` left as-is (system semantic color, appropriate for location)

**GlassActionButton.swift** — Replace:
- `size: CGFloat = 44` → `Theme.IconSize.mediumTap`
- Divider frame widths/heights (32) → Theme token
- `.rect(cornerRadius: 25)` → `Theme.Radius.full` (fully rounded)

---

### What Stays the Same
- Navigation toolbar icons — handled natively by the system, no custom styling
- Animation/spring values — motion parameters, not design tokens
- Map style and camera behavior — MapKit native
- The visual appearance — pixel-identical output before and after
