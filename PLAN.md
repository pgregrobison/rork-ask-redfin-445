# Create a comprehensive Design System (Theme.swift)

## Overview

Expand the existing `Theme.swift` into a full design system with all the tokens needed for consistency across the app. This is **definition only** — no existing screens will be migrated in this step.

---

### **Colors**

- **Brand accent (Redfin red):** Updated to `(red: 0.87, green: 0.2, blue: 0.25)` — replaces all current hardcoded red values
- **Green accent:** Keep current `redfinGreenColor`
- **Semantic backgrounds:** Named references for `systemBackground`, `secondarySystemBackground`, `tertiarySystemBackground`
- **Semantic fills:** `tertiarySystemFill`, `separator`
- **Primary button colors:** `Color.primary` foreground on `Color(.systemBackground)` — auto-adapts light/dark
- **Chart/payment breakdown colors:** Named set of 4 data visualization colors (blue, green, amber, purple)
- **Map pin colors:** Named tokens for default, selected, and seen states (light + dark)
- **Badge colors:** Named tokens for hot, listed-by-redfin, compass, days-ago

---

### **Corner Radius (4 levels)**

| Token | Value | Use case |
|-------|-------|----------|
| `small` | 8pt | Badges, small tags, inputs |
| `medium` | 12pt | Cards, thumbnails, info panels |
| `large` | 16pt | Large cards, widgets, sections |
| `xl` | 20pt | Modals, expanded pill overlays, empty state icons |

---

### **Spacing (4pt scale)**

| Token | Value |
|-------|-------|
| `xxs` | 4pt |
| `xs` | 8pt |
| `sm` | 12pt |
| `md` | 16pt |
| `lg` | 20pt |
| `xl` | 24pt |
| `xxl` | 32pt |

---

### **Shadows (3 levels)**

| Token | Opacity | Radius | Y offset | Use case |
|-------|---------|--------|-----------|----------|
| `subtle` | 0.08 | 4pt | 2pt | Map pins, small elements |
| `medium` | 0.12 | 10pt | 4pt | Nudge bubbles, floating elements |
| `elevated` | 0.20 | 16pt | 6pt | Card overlays, bottom sheets |

Defined as a reusable `.shadow()` ViewModifier or extension for easy application.

---

### **Typography**

All typography tokens use native Dynamic Type styles — no raw point sizes.

| Token | Style | Use case |
|-------|-------|----------|
| `heroPrice` | `.largeTitle.bold()` | Detail page price |
| `sectionTitle` | `.title2.bold()` | Section headers |
| `cardTitle` | `.title3.bold()` | Card titles, subsection headers |
| `headline` | `.headline` | Buttons, emphasis |
| `body` | `.body` | Body text |
| `secondary` | `.subheadline` | Stats, addresses, descriptions |
| `secondaryBold` | `.subheadline.bold()` | Links, inline emphasis |
| `caption` | `.caption` | Labels, metadata |
| `captionBold` | `.caption.bold()` | Badge text, small emphasis |
| `micro` | `.caption2` | Smallest text, home counts |

---

### **Icon Sizes (keep existing + add)**

- `small`: 15pt (tap target 36pt)
- `medium`: 17pt (tap target 44pt)
- Existing values preserved for backward compatibility

---

### **Button Styles**

Reusable `ButtonStyle` definitions:

- **Primary:** `Color.primary` background, `Color(.systemBackground)` text, full capsule shape, 14pt vertical padding
- **Secondary (outline):** Transparent background, `Color(.separator)` 1pt capsule border, `.primary` text
- **Glass action:** Existing glass button pattern, formalized as a style token

---

### **What won't change**

- No existing views will be modified
- The current `Theme.IconSize` remains in place for backward compatibility
- All new tokens are additive — nothing is removed
