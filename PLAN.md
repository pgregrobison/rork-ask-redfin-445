# Fix zoom transition for map and chat home cards

## The Problem

The zoom transition is set up for list/grid cards (Find list, For You, Saved), but two spots were never wired up:

- **Map home card** — the card that appears at the bottom of the map when you tap a pin has no zoom anchor, so tapping it falls back to a plain slide-in.
- **Chat home cards** — the horizontal cards inside the Ask Redfin chat also have no zoom anchor.

On top of that, the map card slides away the moment you tap it, so even if we added the anchor, there would be nothing for the detail view to zoom back into on return.

## The Fix

**Map card — smooth zoom both ways**
- Give the map card a zoom anchor tied to the listing.
- Keep the map card visible on screen while the detail view is open, so when you swipe back the detail cleanly zooms back into the card.
- Only hide/slide the card away after the detail has fully dismissed (or when you explicitly tap the X to dismiss the card itself).

**Chat cards — smooth zoom on open**
- Pass the zoom anchor down into the chat so each horizontal card has a matching source.
- Opening a listing from chat will zoom smoothly into the detail.
- Closing the detail will fall back to a normal slide-down, since the chat sheet is already gone by then (as you noted, unavoidable).

**No visual changes** — same card designs, same layouts, same dismiss behavior for the user. The only difference is that tapping a card on the map or in chat now produces the same smooth zoom-into-detail animation you already get from the Find list and For You tabs, and the map card zooms back out on return.