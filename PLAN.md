# Fix map card zoom transition

**Problem**
When tapping a listing card on the map, the zoom transition doesn't smoothly grow from the card like it does in the list and "For You" tabs. The animation source is incorrectly set to the full screen area instead of just the card itself.

**Fix**
- Move the zoom transition source so it's attached directly to the card (the inner `VStack` with the photo and info), not the outer full-screen wrapper
- This makes the transition animate from the card's actual position at the bottom of the screen, matching the smooth behavior of the other tabs