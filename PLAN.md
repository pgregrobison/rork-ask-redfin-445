# Fix card overlay and map pan animation sync + dismiss animation

Two fixes for the listing card overlay animations:

**Fix 1 — Card and map pan start together**
- Currently the card appears via a SwiftUI `.animation()` modifier while the map pan runs as a separate manual frame-by-frame animation — they start at slightly different times
- Switch to a single `withAnimation` block that shows the card, then immediately kick off the map pan in the same frame so both feel simultaneous

**Fix 2 — Card dismiss animates out instead of vanishing**
- Currently there are two competing animation sources (a `withAnimation` in the dismiss function AND an `.animation()` modifier on the card container) — they conflict and the card disappears instantly
- Remove the `.animation()` modifier and use explicit `withAnimation` for both show and dismiss, so the slide-out transition plays correctly
