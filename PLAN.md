# Fix map responsiveness and smooth compass zoom animation

## What's changing

### Fix 1: Unblock map interaction during pin selection
- Remove the broad animation modifier wrapping the entire map area — this is what freezes panning, zooming, and pin tapping during the camera move
- Only animate the home card overlay appearing/disappearing, not the map itself
- Remove the `isPanning` flag and sleep-based timer that artificially blocks region updates — instead, use a simpler approach that lets the map stay interactive at all times
- Pin taps, panning, and zooming will work immediately even while the map is moving to a selected pin

### Fix 2: Smooth compass coming soon zoom
- Instead of jumping instantly to the final zoomed-in position, animate the map camera smoothly over a longer duration so it feels like a fly-in
- Use a slower, more gentle spring animation for the compass zoom so the transition from a wide view to a tight view feels natural and cinematic rather than jarring