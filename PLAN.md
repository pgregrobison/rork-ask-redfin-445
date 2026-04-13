# Fix map home card slide-in/out animation

**Problem**
The map listing card appears and disappears instantly instead of sliding up/down with a spring animation. An internal animation-stripping modifier is canceling the slide animation.

**Fix**
- Move the animation control into the app logic so the slide-up and slide-down are explicitly animated when a pin is tapped or the card is dismissed
- Remove the conflicting animation-stripping modifier that was killing the slide motion
- The card will continue to animate as a single unit (no individual element bouncing) thanks to the compositing approach already in place

**Result**
- Tapping a pin → card slides up from the bottom with a spring
- Tapping X → card slides back down and out with a matching spring
- Internal card content (tags, text) moves together as one piece, no independent bouncing