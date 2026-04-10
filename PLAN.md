# Fix pin offset direction when selecting a map pin

**What's wrong:** When you tap a map pin, the map pans in the wrong direction, pushing the pin behind the listing card at the bottom of the screen instead of keeping it visible above the card.

**Fix:** Reverse the offset direction in the `panToListing` function so the pin shifts upward on screen (away from the card) instead of downward (behind the card).

Specifically, change `coord.latitude + cardOffset` to `coord.latitude - cardOffset` on the non-sheet code path.