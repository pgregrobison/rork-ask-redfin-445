# Fix map card dismiss animation

**Problem:** Tapping the X button on the map listing card makes it vanish instantly instead of sliding down with a spring animation.

**Root cause:** The `matchedTransitionSource` modifier on the card likely consumes the removal transition, and having both `.animation()` on the parent and `withAnimation` in the dismiss function creates a conflict.

**Fix:**
- Remove the `matchedTransitionSource` modifier from the overlay card (it's meant for navigation zoom transitions, not for the card's entrance/exit)
- Remove the explicit `.animation()` modifier from the parent ZStack so `withAnimation` in `dismissOverlay()` is the sole animation driver — this prevents conflicts
- Wrap the card's conditional block so the `withAnimation` from `dismissOverlay()` cleanly drives the slide-down + fade transition