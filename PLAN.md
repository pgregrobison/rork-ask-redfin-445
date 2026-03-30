# Fix unresponsive locate button

**Problem**
The tap gesture used to dismiss the listing card overlay is applied directly to the Map, which intercepts taps on the action buttons (locate, layers, draw) in the overlay — making them unresponsive.

**Fix**
- Move the dismiss-on-tap behavior so it only covers the map area without blocking the action buttons
- The action buttons will respond to taps normally again
- All existing behavior (dismissing the card by tapping the map, locate, etc.) continues to work as before