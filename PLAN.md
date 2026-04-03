# New "Redfin-Style" Detail Page + Debug Panel Style Switcher

## Overview
Add a **DP Style** option to the Debug Panel that lets you switch between the current detail page layout ("Sheet" style) and a brand-new Redfin-inspired vertical scroll layout ("Redfin" style). The current design is preserved as-is. The new style is a ground-up reimagination.

---

## Features

### Debug Panel
- New **"DP Style"** section in the Debug Panel with two options:
  - **Sheet** (current) — the bottom-sheet-over-photos layout we have today
  - **Redfin** — the new full vertical scroll layout inspired by the reference image
- Selecting a style takes effect the next time you open a detail page

### New Redfin-Style Detail Page — Sections (top to bottom)

1. **Hero Photo Carousel** — full-width swipeable photo gallery with page indicator dots. Badges ("HOT HOME", "LISTED BY REDFIN", etc.) overlaid on the top-left. Photo counter ("1 of 5") on the top-right.

2. **Navigation Bar** — transparent over the photo, transitions to a solid bar with the address as you scroll down. Heart (save) and share buttons in the trailing toolbar area (native toolbar items).

3. **Price & Address Header** — large bold price centered, bed/bath/sqft stats below, full address underneath.

4. **Rate & Estimate Row** — estimated monthly payment pill on the left ("Rates dropped" style) with an "Estimate my rate" button on the right. Uses computed mortgage estimate from price.

5. **Request Showing Button** — full-width outlined button, inline in the scroll (not sticky). Keeps the existing liquid glass treatment on iOS 26+.

6. **Action Buttons Row** — horizontal row of icon buttons: share, save (heart), and more actions. Styled as outlined circles.

7. **Property Details Grid** — 2-column grid showing property type, year built, lot size, price per sqft, Redfin Estimate (using listing price), and HOA dues — each with an icon.

8. **Highlights Tags** — listing tags displayed as rounded pill chips in a wrapping grid layout.

9. **Description** — the listing description text with a "Full property details" disclosure button below it.

10. **Monthly Payment Breakdown** — section showing estimated monthly cost broken into principal & interest, property taxes, homeowners insurance, and HOA dues. Includes a colored stacked bar chart and editable fields for home price, down payment, and loan details.

11. **Estimate My Payment Button** — prominent green/red call-to-action button with "Takes about 3 minutes" and "Won't affect your credit score" reassurance text below.

12. **Take a Tour** — section with a house icon, "Tour in person" and "Tour via video chat" outlined action buttons, and a "It's free, cancel anytime" note.

13. **Ask Redfin** — section with a chat-bubble icon illustration, brief description text, and a "Let's chat" outlined button.

14. **Lifestyle** — walkability/bikeability/noise/calm scores displayed as labeled pills with small icons, with a "How is this calculated?" link.

15. **Sticky Ask Redfin FAB** — the sparkle button stays pinned to the bottom-right corner (identical behavior to current), floating over the scroll content. Tapping it opens the existing Ask Redfin chat sheet.

---

## Design

- **Layout**: Single continuous vertical scroll — no bottom sheet, no drag gestures. Clean, content-forward.
- **Colors**: White/system background. Redfin red accent (`Color(red: 0.78, green: 0.13, blue: 0.13)`) for key CTAs. Green accent for the Redfin Estimate badge. Semantic colors for text hierarchy.
- **Typography**: System font (Inter is unavailable in native iOS, so we use SF Pro, matching the existing app). Large bold price, standard body text, caption-weight labels. Varied weight hierarchy.
- **Buttons**: Outlined style (thin border, rounded corners) for "Request showing", "Tour in person", "Tour via video chat", "Let's chat", and "Full property details". Filled style for "Estimate my rate" and "Estimate my payment".
- **Cards/Sections**: Separated by generous whitespace rather than card backgrounds — the Redfin style uses a flat, clean white background with dividers between major sections.
- **Tags/Chips**: Rounded outlined pills with a light border, not filled backgrounds.
- **Payment Bar**: Thin horizontal stacked bar with distinct colors for each cost component (principal, taxes, insurance, HOA).
- **Icons**: SF Symbols throughout — `house`, `calendar`, `arrow.up.left.and.arrow.down.right`, `dollarsign.circle`, `shield`, `percent`, `person.2`, `video`, `bubble.left.and.bubble.right`, `figure.walk`, `bicycle`, `moon.zzz`, `leaf`.
- **Liquid Glass**: Navigation bar items and the floating Ask Redfin button use liquid glass on iOS 26+ (same as current).
- **Dark Mode**: Fully supported via semantic colors.

---

## Pages / Screens

- **Debug Panel** — gains a new "DP Style" section (Sheet vs. Redfin)
- **Listing Detail (Sheet)** — the existing detail page, completely untouched
- **Listing Detail (Redfin)** — the new Redfin-inspired vertical scroll detail page
- **Content View** — updated to check the debug style setting and show the appropriate detail view
