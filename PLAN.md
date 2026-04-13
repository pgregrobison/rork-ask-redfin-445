# Fix tags bouncing independently inside map home card

**Problem**
When the map home card slides in, the tags (and other child elements) each animate with their own independent spring bounce, instead of moving rigidly with the card as a single unit.

**Root Cause**
The spring animation wrapping `isCardVisible` propagates into all child views. Each tag in the row receives its own spring, making them visually "jiggle" separately.

**Fix**
- Remove the `withAnimation` wrapper from `selectListing` and `dismissOverlay` in the view model — stop the spring from propagating globally
- Instead, apply an explicit `.animation(.spring(...), value: isCardVisible)` **only** to the `.offset` and `.opacity` modifiers on the card overlay in `FindMapView`
- This ensures only the card's position and opacity animate with the spring — the card's internal content (tags, text, etc.) stays rigid and moves as one solid unit