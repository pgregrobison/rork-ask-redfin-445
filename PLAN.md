# Fix map shift direction and zoom in closer

**What's wrong:**
- The map center is shifted upward (north) instead of downward (south), causing pins to land underneath the home card instead of above it
- The zoom level isn't tight enough

**Changes:**
- Reverse the center offset so the map shifts **down**, pushing the pins into the visible area **above** the card
- Increase zoom by reducing the padding multiplier so pins fill more of the screen
- Slightly increase the offset ratio to better account for the card height