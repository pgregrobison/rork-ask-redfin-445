# Persistent Ask Redfin input bar on hybrid detail page

## What changes

Rebuild the hybrid home detail page to use the same in-page sheet behavior as the current detail page style. This unlocks a floating "Ask anything…" input bar pinned to the bottom that stays visible no matter what — whether you're scrolling photos, expanding the detail sheet, or viewing a photo fullscreen.

## Behavior

- **Sheet** — The detail sheet on the hybrid page now drags between a small peek (showing price, address, beds/baths) and fully expanded, with a drag handle and snap-to-position, just like the current detail page.
- **Persistent Ask input** — A capsule "Ask anything…" bar with a sparkle icon sits fixed at the bottom of the screen across all states: photo scroll, peek sheet, expanded sheet, and fullscreen photo view. Tapping it opens Ask Redfin.
- **Photo fullscreen** — When a photo is tapped, the fullscreen viewer appears with the Ask input still floating above it. Tapping the input still opens Ask Redfin.
- **Accessory variant** — In the Accessory variant the in-page input stays hidden (the bottom tab accessory handles it instead), matching today's behavior. The "Request showing" button is also removed in that variant, as before.
- **Request showing** — In non-Accessory variants, "Request showing" stays inside the scrolling sheet content (not as a sticky footer), so the Ask input is the only persistent bottom element.
