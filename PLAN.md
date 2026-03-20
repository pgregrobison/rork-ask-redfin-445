# Standardize all icons to 20pt semibold with 44pt tap targets and SF Symbol transitions

## What's changing

Update every icon across the app (excluding the tab bar and Ask Redfin floating button) to follow a consistent standard:

- **Size**: 20pt for all action/interactive icons
- **Weight**: Semibold across the board
- **Tap targets**: 44×44pt hit area on every tappable icon
- **Transitions**: Smooth SF Symbol replace transitions when icons toggle between filled/unfilled states (e.g. heart → heart.fill), plus a subtle bounce effect on tap

### Files being updated

**Toolbar & navigation icons**
- **Find screen** — List/map toggle, filter, sort, and profile icons get explicit 20pt semibold styling with symbol replace transitions on the list/map toggle
- **Listing detail** — Share and heart toolbar icons get 20pt semibold + 44pt tap areas + heart fill transition
- **Photo viewer** — Close (xmark) icon updated to 20pt semibold

**Card action icons**
- **Listing card overlay** (map popup card) — Share and heart icons updated to 20pt semibold with 44pt tap targets and heart fill transition
- **Listing list card** — Share and heart icons updated to 20pt semibold with 44pt tap targets and heart fill transition
- **Chat listing cards** — Heart icon on chat result cards updated to 20pt semibold

**Chat & input icons**
- **Ask Redfin close button** — Updated to 20pt semibold with 44pt tap area
- **Chat feedback thumbs** — Updated to 20pt semibold with symbol replace transitions
- **Input bar icons** (sparkle, mic, stop) — Updated to 20pt semibold

**Widget header icons**
- **Mortgage widget** — Banknote header icon → 20pt semibold
- **Tour scheduler widget** — Calendar header icon → 20pt semibold
- **Tour route widget** — Map header icon → 20pt semibold
- **Confirmation checkmarks** — Updated to 20pt semibold

**Decorative/informational icons** (non-tappable)
- **Key facts grid** — Updated to 20pt semibold
- **Disclosure rows** (neighborhood, price history, schools) — Row icons to 20pt semibold, chevron kept smaller as a disclosure indicator
- **Hot home badge flame** — Updated to 20pt semibold
- **Market insight icon** — Updated to 20pt semibold
- **My Home feature tiles** — Updated to 20pt semibold
- **Map pin overlays** on listing photos — Updated to 20pt semibold

**Empty state icons** (large decorative) — Kept at their larger sizes (40pt+) since these are hero illustrations, not action icons

### Transition details
- Heart icons: `.contentTransition(.symbolEffect(.replace))` for smooth fill/unfill animation
- List/map toggle: `.contentTransition(.symbolEffect(.replace))` for smooth icon swap
- Feedback thumbs: `.contentTransition(.symbolEffect(.replace))` for fill transition
- Tappable icons: `.sensoryFeedback(.selection, trigger:)` where appropriate for haptic feedback on toggle
