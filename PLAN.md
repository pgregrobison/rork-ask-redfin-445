# Fix map card dismiss animation — slide out reliably

**Problem**: Tapping X on the map listing card makes it instantly disappear instead of sliding down with a spring animation (the reverse of how it entered).

**Root Cause**: The card uses a conditional `if let` with `.transition()`, which is unreliable for removal animations with Observable state. SwiftUI often skips removal transitions.

**Fix**:
- Instead of conditionally showing/hiding the card (which relies on fragile `.transition()`), keep the card in the view hierarchy and animate it in/out using a vertical **offset**
- Add a separate `isCardVisible` flag to the view model that controls the slide position
- When showing the card: set the listing data, then animate `isCardVisible = true` (card slides up)
- When dismissing: animate `isCardVisible = false` (card slides down), then clear the listing data after the animation completes
- This guarantees the slide-down animation plays every time because the view is never removed mid-animation
- The entrance and dismiss animations will use the same spring values from the debug panel