# Restore slide-in and slide-out animation for map home card

**Problem**
The card appears instantly because the listing and the "visible" flag are set at the same time. By the time the card renders, it's already in its final position — no animation plays.

**Fix**
- When a pin is tapped, set the listing first (so the card view enters the tree at the off-screen position), then on the next frame flip the "visible" flag to trigger the slide-in spring animation
- This ensures the animation modifier sees the value change from "hidden" to "visible" and plays the slide-up spring
- The slide-out (dismiss) should already work since the flag changes while the card is still on screen — but I'll verify and fix if needed