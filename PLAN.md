# Phase 4: Migrate Remaining Views & Add Missing Theme Tokens

## Scope

Final migration pass — tokenize the remaining hardcoded values across detail pages, tab bar, map pins, and scattered one-offs. Same goal: everything looks identical, but uses the design system.

### New Theme tokens to add

- **Tab bar sizes** — icon size (19pt), FAB size (62pt), tab padding (11pt)
- **Tab bar clearance** — bottom padding (100pt) used by scrollable pages to clear the floating tab bar
- **Map pin** — font size (13pt), horizontal padding (10pt)
- **Detail page** — large decorative font sizes for empty states/hero numbers (48pt, 40pt, 36pt, 32pt, 28pt)
- **Divider inset** — standard leading inset for step indicators (48pt) and detail rows (42pt)

### Files to update

**Detail Pages (2 files):**
- **Listing Detail** — replace hardcoded padding values (10, 14, 42), `Color(.systemGray3)` dot indicator, font size 14 with tokens
- **Redfin Detail** — replace hardcoded padding (60, 10, 5, 14), hero number font sizes (32, 28, 48, 40, 36) with tokens

**Tab Bar & Navigation (1 file):**
- **Custom Tab Bar** — replace hardcoded icon size (19), FAB frame (62), vertical padding (11) with tokens

**Map (1 file):**
- **Map Pin** — replace hardcoded font size (13), padding (10, 2) with tokens

**Scrollable Pages (4 files):**
- **Find List, For You, Saved, My Home** — replace `padding(.bottom, 100)` with a `Theme.Spacing.tabBarClearance` token

**Remaining one-offs in already-migrated files (~6 files):**
- **Tour Scheduler / Mortgage Widget** — remaining hardcoded divider padding (48), font sizes (11, 12, 28)
- **Location Menu** — remaining font sizes (20, 9, 13)
- **Filter Sheet** — font size 9
- **Find Pill Overlay** — font size 14
- **My Home** — `Color(white: 0.15)` → `Theme.Colors.stepIndicator`

### What stays as-is
- `.foregroundStyle(.white)` on dark overlays/badges — these are intentional contrast colors, not theme-dependent
- Debug Panel — developer tool, not user-facing
- Animation-specific frame sizes in VoiceModeView — tied to animation logic, not design tokens
