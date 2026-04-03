# Phase 3: Migrate Chat, Widgets & Filters to Theme Tokens

## Scope

Migrate the remaining views — chat/AI views, interactive widgets, filter sheets, and location menu — to use the design system tokens. Everything should LOOK the same after this change.

### Files to update

**Chat & AI views:**
- **Ask Redfin** (chat sheet) — replace hardcoded spacing, colors, corner radii, and font sizes with Theme tokens
- **Chat Message Bubble** — replace hardcoded padding, bubble colors, and corner radii with tokens
- **Chat Listing Cards** — replace hardcoded spacing, button padding, and raw colors with tokens and existing button styles
- **Thinking Indicator** — replace hardcoded spacing and padding with tokens
- **Nudge Bubble** — replace hardcoded padding, background color, corner radius, and shadow with tokens
- **Voice Orb** — update legacy `Theme.redfinGreenColor` reference to `Theme.Colors.brandGreen`

**Interactive widgets (in chat):**
- **Tour Scheduler Widget** — replace hardcoded padding, background colors, corner radii, and font sizes with tokens; use button styles where applicable
- **Mortgage Prequalification Widget** — same treatment as Tour Scheduler
- **Tour Route Map Widget** — replace hardcoded colors (`Color(white: 0.15)`) and spacing with tokens

**Filters & Location:**
- **Filter Sheet** — replace hardcoded spacing, `Color(.tertiarySystemFill)`, and corner radii with tokens
- **Location Menu** — replace hardcoded spacing, colors, font sizes, and corner radii with tokens

### Theme additions (if needed)
- Add a `Theme.Colors.Chat` namespace for chat-specific colors (user bubble background, assistant bubble background) to keep them consistent
- Add a `Theme.Radius.chat` token for chat bubble corner radius
- Add `Theme.Colors.stepIndicator` for the dark circle color used in widgets (`Color(white: 0.15)`)

### What stays the same
- **Debug Panel** — intentionally left with system List styling (it's a developer tool, not user-facing)
- No visual changes — same colors, spacing, and fonts, just routed through the design system
