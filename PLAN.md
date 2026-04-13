# Fix map card tags animating separately from the card

**Problem**
When the map home card slides up, the tags (and potentially other sub-elements) spring-bounce independently from the card itself, creating a staggered/jittery look.

**Fix**
- Add a compositing group to the card so it animates as a single visual unit instead of each child element animating on its own
- This is applied to the card container in the map view, right before the offset/opacity modifiers
- No visual or behavioral changes — the card just moves as one cohesive piece now